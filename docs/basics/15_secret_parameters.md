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

The Concourse dashboard UI is now at https://192.168.50.6/

## Setup pipeline with parameters

Deploy the pipeline from the preceding section to our new `bucc` concourse environment. Do not provide any explicit values for the parameters:

```
cd ../14_parameters
fly -t bucc sp -p parameters -c pipeline.yml
fly -t bucc up -p parameters
```

## Insert values into Credentials Manager

```
credhub set -n /concourse/main/parameters/cat-name --type value --value garfield
credhub set -n /concourse/main/parameters/dog-name --type value --value oddie
```

Alternately, if you'd classify the values as passwords then switch the `--type` and use the `--password` flag:

```
credhub delete -n /concourse/main/parameters/cat-name
credhub delete -n /concourse/main/parameters/dog-name
credhub set -n /concourse/main/parameters/cat-name --type password --password garfield
credhub set -n /concourse/main/parameters/dog-name --type password --password oddie
```

Run the pipeline job to confirm that it dynamically fetched the secrets from Credhub:

```
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Credential Lookup Rules

When resolving a parameter such as `((cat-name))`, it will look in the following paths, in order:

* `/concourse/TEAM_NAME/PIPELINE_NAME/cat-name`
* `/concourse/TEAM_NAME/cat-name`

So, if the `((cat-name))` credential is to be shared across all pipelines in the `main` team, then the `credhub set` commands would become:

```
credhub delete -n /concourse/main/parameters/cat-name
credhub delete -n /concourse/main/parameters/dog-name
credhub set -n /concourse/main/cat-name --type password --password garfield
credhub set -n /concourse/main/dog-name --type password --password oddie
```

Again, run the pipeline job to confirm that it dynamically fetched the team's shared secrets from Credhub:

```
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Rotating Secrets

A great feature of Concourse Credentials Manager - regardless if backed by Cloud Foundry Credhub or Hashicorp Vault - is that you can now update secrets/parameters and the new values will automatically be used the next time a job is run.

```
credhub delete -n /concourse/main/cat-name
credhub delete -n /concourse/main/dog-name
credhub set -n /concourse/main/cat-name --type password --password milo
credhub set -n /concourse/main/dog-name --type password --password otis

fly -t bucc trigger-job -j parameters/show-animal-names -w
```

The output will include the two new parameter values:

```
CAT_NAME=milo
DOG_NAME=otis
```