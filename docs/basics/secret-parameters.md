# Secret Parameters with Credentials Manager

Concourse can be extended with a credentials manager to allow values and secrets to be set and rotated without any changes to your pipelines. No more variable files containing secrets on your file system. No more updating multiple pipelines whenever you need to change common variables.

Concourse supports Cloud Foundry Credhub and Hashicorp Vault. They have a common behaviour within Concourse. For the simplicity of the Concourse Tutorial book we will use the simplest tool to re-deploy Concourse with a credentials manager - [bucc](https://github.com/starkandwayne/bucc) - which includes Credhub. Credhub is very simple to interact with via its own CLI and is 100% open source.

## Redeploy Concourse with Credhub

First, delete initial `tutorial` concourse:

```
cd ../../..
bosh delete-env manifests/concourse-lite.yml --state tmp/state.json
```

Now, switch to [bucc](https://github.com/starkandwayne/bucc) to deploy a local single VM version of Concourse that has the Credhub credentials manager.

In another terminal:

```
git clone https://github.com/starkandwayne/bucc ~/workspace/bucc
cd ~/workspace/bucc
```

Now run:

```
bucc up --lite
```

If this fails with `command not found: bucc`, then perhaps you do not have [`direnv`](https://direnv.net/) installed. Never fear. Run to update your `$PATH` to add the `bin/bucc` command.

```
source .envrc
```

Now run:

```
bucc up --lite
```

The `bucc up --lite` command is similar to `bosh create-env` but adds Credhub to the same VM. The `bucc` command also includes subcommands for logging in to Concourse and Credhub.

## Concourse & Credhub

To target and login to your new Concourse:

```
bucc fly
```

Instead of `fly -t tutorial` you will now use `fly -t bucc`.

The Concourse dashboard UI is now at https://192.168.50.6/

To target and login to Credhub, the credentials manager included in `bucc`:

```
bucc credhub
```

## Reauthentication

Credhub will enthusiastically and frequently drop your login session:

```
You are not currently authenticated. Please log in to continue.
```

Anytime your `credhub` authentication runs out, return to `~/workspace/bucc` and run `bucc credhub` again to re-login.

Similarly, `fly -t bucc` sessions will timeout. To re-authenticate, return to `~/workspace/bucc` and run `bucc fly` again.

## Setup pipeline with parameters

Back in your main `concourse-tutorial` terminal window, return to the `tutorials/basic/parameters` folder, and install the pipeline from the preceding section to our new `bucc` concourse environment. Do not provide any explicit values for the parameters as these will come from the Credhub credentials manager:

```
cd ../parameters
fly -t bucc sp -p parameters -c pipeline.yml
fly -t bucc up -p parameters
```

## Insert values into Credentials Manager

```
credhub set -n /concourse/main/parameters/cat-name --type value --value garfield
credhub set -n /concourse/main/parameters/dog-name --type value --value oddie
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
credhub set -n /concourse/main/cat-name --type value --value garfield
credhub set -n /concourse/main/dog-name --type value --value oddie
```

Again, run the pipeline job to confirm that it dynamically fetched the team's shared secrets from Credhub:

```
fly -t bucc trigger-job -j parameters/show-animal-names -w
```

## Rotating Secrets

A great feature of Concourse Credentials Manager - regardless if backed by Cloud Foundry Credhub or Hashicorp Vault - is that you can now update secrets/parameters and the new values will automatically be used the next time a job is run.

```
credhub set -n /concourse/main/cat-name --type value --value milo
credhub set -n /concourse/main/dog-name --type value --value otis

fly -t bucc trigger-job -j parameters/show-animal-names -w
```

The output will include the two new parameter values:

```
CAT_NAME=milo
DOG_NAME=otis
```