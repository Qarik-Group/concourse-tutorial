# Secret Parameters with Credentials Manager

Concourse can be extended with a credentials manager to allow values and secrets to be set and rotated without any changes to your pipelines. No more variable files containing secrets on your file system. No more updating multiple pipelines whenever you need to change common variables.

Concourse supports Cloud Foundry Credhub and Hashicorp Vault. They have a common behaviour within Concourse. For the simplicity of the Concourse Tutorial book we will use the simplest tool to re-deploy Concourse with a credentials manager - [bucc](https://github.com/starkandwayne/bucc) - which includes Credhub. Credhub is very simple to interact with via its own CLI and is 100% open source.

## Redeploy Concourse with Credhub

First, delete initial `tutorial` concourse:

```
bosh delete-env manifests/concourse-lite.yml --state tmp/state.json
```

Now, switch to [bucc](https://github.com/starkandwayne/bucc) to deploy a local single VM version of Concourse that has the Credhub credentials manager.

```
git clone https://github.com/starkandwayne/bucc
cd bucc
bucc up --lite
```

The `bucc up --lite` command is similar to `bosh create-env` but adds Credhub to the same VM. The `bucc` command also includes subcommands for logging in to Concourse and Credhub.

To target and login to your new Concourse:

```
bucc fly
```

Instead of `fly -t tutorial` you will now use `fly -t bucc`.

To target and login to Credhub, the credentials manager included in `bucc`:

```
bucc credhub
```

## Setup Credentials Manager

```
credhub set -n /concourse/main/tutorial-pipeline/cf-api -t value -v https://api.18-220-96-60.sslip.io
credhub set -n /concourse/main/tutorial-pipeline/cf-username -t value -v admin
credhub set -n /concourse/main/tutorial-pipeline/cf-organization -t value -v system
credhub set -n /concourse/main/tutorial-pipeline/cf-space -t value -v dev
```

And passwords have a different `--type` and use the `--password` flag:

```
credhub set -n /concourse/main/tutorial-pipeline/cf-password --type password --password my-secret-password
```

## Credential Lookup Rules

When resolving a parameter such as `((foo_param))`, it will look in the following paths, in order:

* `/concourse/TEAM_NAME/PIPELINE_NAME/foo_param`
* `/concourse/TEAM_NAME/foo_param`

So, if the `cf` credentials above were to be shared across all pipelines in the `main` team, then the `credhub set` commands could be abbreviated to:

```
credhub set -n /concourse/main/cf-api -t value -v https://api.18-220-96-60.sslip.io
credhub set -n /concourse/main/cf-username -t value -v admin
credhub set -n /concourse/main/cf-organization -t value -v system
credhub set -n /concourse/main/cf-space -t value -v dev
credhub set -n /concourse/main/cf-password --type password --password my-secret-password
```
