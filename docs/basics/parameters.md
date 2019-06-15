description: Concourse pipelines can include ((parameter)) parameters for any value in the pipeline YAML file.


# Parameterized Pipelines

In the preceding section you were asked to place private credentials and personal git URLs into the `pipeline.yml` files. This would make it difficult to share your `pipeline.yml` with anyone who had access to the repository. Not everyone needs nor should have access to the shared secrets.

Concourse pipelines can include `((parameter))` parameters for any value in the pipeline YAML file.

Parameters are all mandatory. There are no default values for parameters.

In the lesson's `pipeline.yml` there are two parameters:

```
jobs:
- name: show-animal-names
  plan:
  - task: show-animal-names
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      run:
        path: env
        args: []
      params:
        CAT_NAME: ((cat-name))
        DOG_NAME: ((dog-name))
```

If we `fly set-pipeline` but do not provide the parameters, we see an error when the job is triggered to run:

```
cd ../parameters
fly -t tutorial sp -p parameters -c pipeline.yml
fly -t tutorial up -p parameters
fly -t tutorial trigger-job -j parameters/show-animal-names -w
```

This will fail with the following error:

```
Expected to find variables: cat-name
dog-name
errored
```

## Parameters from fly options

```
fly -t tutorial sp -p parameters -c pipeline.yml -v cat-name=garfield -v dog-name=odie
fly -t tutorial trigger-job -j parameters/show-animal-names -w
```

The output will show that the `-v` variables were passed into the `params` section of the `show-animal-names` task. Values in `params` sections  in turn become environment variables within the task:

```
initializing
running env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOME=/root
CAT_NAME=garfield
DOG_NAME=odie
USER=root
```

## Parameters from local file

Alternatively, you can store your parameter values in a local file.

```bash
cat > credentials.yml <<YAML
cat-name: garfield
dog-name: odie
YAML
```

Use the `--load-vars-from` flag (aliased `-l`) to pass in this file instead of the `-v` flag. The following command should not modify the pipeline from the preceding step as the resulting pipeline YAML is equivalent.

```
fly -t tutorial sp -p parameters -c pipeline.yml -l credentials.yml
```

## Revisiting Publishing Outputs

In the previous lesson [Publishing Outputs](/basics/publishing-outputs/), there were two user-provided changes to the `pipeline.yml`. These can now be changed to parameters.

```
cd ../publishing-outputs
```

There is an alternate `pipeline-parameters.yml` that offers two parameters for `resource-gist`:

```yaml
resources:
- name: resource-gist
  type: git
  source:
    branch:      master
    uri:         ((publishing-outputs-gist-uri))
    private_key: ((publishing-outputs-private-key))
```

Create a `credentials.yml` with the Gist URL and private key:

```yaml
publishing-outputs-gist-uri: git@gist.github.com:e028e491e42b9fb08447a3bafcf884e5.git
publishing-outputs-private-key: |-
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEAuvUl9YU...
    ...
    HBstYQubAQy4oAEHu8osRhH...
    -----END RSA PRIVATE KEY-----
```

Use the `--load-vars-from` or `-l` flag to pass the variables into the parameters:

```
fly -t tutorial sp -p publishing-outputs -c pipeline-parameters.yml -l credentials.yml
fly -t tutorial up -p publishing-outputs
fly -t tutorial trigger-job -j publishing-outputs/job-bump-date
```

## Dynamic Parameters and Secret Parameters

Parameters are very useful. They allow you to describe your `pipeline.yml` in public repositories without embedding variables nor secrets.

There are two downsides to the two approaches above.

* To change any parameter values requires you to rerun `fly set-pipeline`. If a value is common across many pipelines then you must rerun `fly set-pipeline` for them all.
* The parameter values are not very secret. Anyone with access to the pipeline's team is able to download the pipeline YAML and extract the secrets.

    ```
    fly -t tutorial get-pipeline -p parameters
    ```

    Shows that the two potentially secret parameters are visible in plain text:

    ```
    ...
    params:
      CAT_NAME: garfield
      DOG_NAME: odie
    run:
      path: env
    ```

The solution to both of these problems is to use a Concourse Credentials Manager and is discussed in lesson [Secret with Credential Manager](/basics/secret-parameters/).
