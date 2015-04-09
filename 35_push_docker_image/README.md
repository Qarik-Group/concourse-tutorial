35 - Push Docker image
======================

This section will show how to take a Dockerfile project, build it and push to Docker Hub.

Define a docker image
---------------------

This section's subfolder `docker` containers a `Dockerfile` to embed our dummy `out` script into `/opt/resource/out` within the container:

```dockerfile
FROM busybox

ADD out /opt/resource/out
```

Create a docker container image
-------------------------------

We could manually create a docker image and push it to Docker Hub. But since we have concourse we will use it instead.

The pipeline for this section is to `put` a docker-image resource.

The pipeline is below:

```yaml
jobs:
- name: job-publish
  public: true
  serial: true
  plan:
  - get: resource-tutorial
  - put: resource-41-docker-image
    params:
      build: resource-tutorial/41_dummy_resource_docker_image/docker

resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/drnic/concourse-tutorial.git

- name: resource-41-docker-image
  type: docker-image
  source:
    email: DOCKER_EMAIL
    username: DOCKER_USERNAME
    password: DOCKER_PASSWORD
    repository: drnic/resource-41-docker-image
```

Since the source `Dockerfile` is actually within this tutorial's own git repo, we will use it as the input/`get` resource called `resource-tutorial`.

This means the `docker` subfolder in this tutorial section will be available at folder `resource-tutorial/41_dummy_resource_docker_image/docker` during the build plan (`resource-tutorial` is the name of the resource within the job build plan; and `41_dummy_resource_docker_image/docker` is the subfolder where the `Dockerfile` is located).

Your `stub.yml` now needs your Docker Hub account credentials (see `stub.example.yml`\):

```yaml
meta:
  docker:
    email: EMAIL
    username: USERNAME
    password: PASSWORD
```

The `run.sh` will create the pipeline.yml and upload it to Concourse:

```
./41_*/run.sh stub.yml
```

This will create a docker image `<username>/resource-41-docker-image` on Docker Hub.

Worker references remote docker image
-------------------------------------

On the Vagrant VM (or Worker VM) change `/var/vcap/jobs/groundcrew/config/worker.json`.

Where we had added the following `resource_type` in section 40:

```
{"image":"/var/vcap/packages/dummy","type":"dummy"}
```

Change it to the following (replacing `<username>` with your Docker Hub username):

```
{"image":"docker:///<username>/resource-41-docker-image","type":"dummy"}
```

Or use a pre-existing Docker image:

```
{"image":"docker:///drnic/resource-41-docker-image","type":"dummy"}
```

Restart the monit process to re-register the `dummy` resource type:

```
monit restart beacon
```

The folder `/var/vcap/packages/dummy` can now be deleted:

```
rm -rf /var/vcap/packages/dummy
```

Re-run pipeline to use dummy resource type
------------------------------------------

The pipeline in section 40 can now be reused to use test our `dummy` resource type:

```
./40_*/run.sh
```
