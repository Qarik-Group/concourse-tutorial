description: Concourse can be extended with a credentials manager to allow values and secrets to be set and rotated without any changes to your pipelines. No more variable files containing secrets on your file system. No more updating multiple pipelines whenever you need to change common variables.

# Secret Parameters with Credentials Manager

Concourse can be extended with a credentials manager to allow values and secrets to be set and rotated without any changes to your pipelines. No more variable files containing secrets on your file system. No more updating multiple pipelines whenever you need to change common variables.

Concourse supports Cloud Foundry Credhub, Hashicorp Vault, Amazon SSM, and Amazon Secrets Manager. They have a common behaviour within Concourse. For the simplicity of the Concourse Tutorial book we will use the simplest tool to re-deploy Concourse with a credentials manager - [bucc](https://github.com/starkandwayne/bucc) - which includes Credhub. Credhub is very simple to interact with via its own CLI and is 100% open source.

## Redeploy Concourse with Credhub

We will now switch from our `docker-compose up` deployment of Concourse to [bucc](https://github.com/starkandwayne/bucc) to deploy a local single VM version of Concourse that has the Credhub credentials manager. As a bonus, `bucc` will allow you to deploy a production-version of Concourse to any public or private cloud. In this tutorial we will deploy `bucc` to your local machine.

First, you need to install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (for the local deployment of `bucc`).
If you are running Ubuntu, macOS or CentOS, there are [additional dependencies](https://bosh.io/docs/cli-v2-install/#additional-dependencies) that need to be installed before the local deployment of `bucc`.

Next:

```plain
git clone https://github.com/starkandwayne/bucc ~/workspace/bucc
cd ~/workspace/bucc
```

Now run the following to deploy `bucc` to your local machine using VirtualBox:

```plain
bucc up --lite
```

If this fails with `command not found: bucc`, then perhaps you do not have [`direnv`](https://direnv.net/) installed. Never fear. Run to update your `$PATH` to add the `bin/bucc` command.

```plain
source .envrc
```

Now run:

```plain
bucc up --lite
```

The `bucc up --lite` command is similar to `bosh create-env` but adds Credhub to the same VM. The `bucc` command also includes subcommands for logging in to Concourse and Credhub.

## Concourse & Credhub

To target and login to your new Concourse:

```plain
bucc fly
```

Instead of `fly -t tutorial` you will now use `fly -t bucc`.

The Concourse dashboard UI is now at https://192.168.50.6/

To target and login to Credhub, the credentials manager included in `bucc`:

```plain
bucc credhub
```

## Reauthentication

Credhub will enthusiastically and frequently drop your login session:

```plain
You are not currently authenticated. Please log in to continue.
```

Anytime your `credhub` authentication runs out, return to `~/workspace/bucc` and run `bucc credhub` again to re-login.

Similarly, `fly -t bucc` sessions will timeout. To re-authenticate, return to `~/workspace/bucc` and run `bucc fly` again.

## Setup pipeline with parameters

Back in your main `concourse-tutorial` terminal window, return to the `tutorials/basic/parameters` folder, and install the pipeline from the preceding section to our new `bucc` concourse environment. Do not provide any explicit values for the parameters as these will come from the Credhub credentials manager:

```plain
cd ../parameters
fly -t bucc sp -p parameters -c pipeline.yml
fly -t bucc up -p parameters
```

## Insert values into Credentials Manager

```plain
credhub set -n /concourse/main/parameters/cat-name --type value --value garfield
credhub set -n /concourse/main/parameters/dog-name --type value --value odie
```

Run the pipeline job to confirm that it dynamically fetched the secrets from Credhub:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Credential Lookup Rules

When resolving a parameter such as `((cat-name))`, it will look in the following paths, in order:

* `/concourse/TEAM_NAME/PIPELINE_NAME/cat-name`
* `/concourse/TEAM_NAME/cat-name`

So, if the `((cat-name))` credential is to be shared across all pipelines in the `main` team, then the `credhub set` commands would become:

```plain
credhub delete -n /concourse/main/parameters/cat-name
credhub delete -n /concourse/main/parameters/dog-name
credhub set -n /concourse/main/cat-name --type value --value garfield
credhub set -n /concourse/main/dog-name --type value --value odie
```

Again, run the pipeline job to confirm that it dynamically fetched the team's shared secrets from Credhub:

```plain
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Rotating Secrets

A great feature of Concourse Credentials Manager - regardless if backed by Cloud Foundry Credhub or Hashicorp Vault - is that you can now update secrets/parameters and the new values will automatically be used the next time a job is run.

```plain
credhub set -n /concourse/main/cat-name --type value --value milo
credhub set -n /concourse/main/dog-name --type value --value otis

fly -t bucc trigger-job -j parameters/show-animal-names -w
```

The output will include the two new parameter values:

```plain
CAT_NAME=milo
DOG_NAME=otis
```
