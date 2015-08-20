51 - Dummy resource via Docker image
====================================

In section 50, we hacked in the core idea of a resource type into the worker VM (which is the shared Vagrant VM):

1.	manually created a `dummy` rootfs with a simple/dummy `opt/resource/{check,in,out}` scripts that satisfy Concourse's API
2.	edited `/var/vcap/jobs/groundcrew/config/worker.json` and ran `monit restart beacon`
3.	ran a pipeline that did a `put` to our `dummy` resource type

Create docker image
-------------------

As documented in http://concourse.ci/implementing-resources.html: a resource type is implemented by a container image with three scripts:

-	`/opt/resource/check` for checking for new versions of the resource
-	`/opt/resource/in` for pulling a version of the resource down
-	`/opt/resource/out` for idempotently pushing a version up

In section 50 we created simple `/opt/resource/{check, in, out}` scripts and put them into a container image at `/var/vcap/package/dummy` on the Vagrant VM.

In this section we will create a normal Docker image, host it on Docker Hub, and use it in our worker.

Define a docker image
---------------------

This section's subfolder `docker` containers a `Dockerfile` to add our dummy `check`, `in`, and `out` scripts into `/opt/resource/` within the container:

```dockerfile
FROM busybox

COPY check /opt/resource/check
COPY in /opt/resource/in
COPY out /opt/resource/out
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
  - put: resource-51-docker-image
    params:
      build: resource-tutorial/51_dummy_resource_docker_image/docker

resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/drnic/concourse-tutorial.git

- name: resource-51-docker-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: {{docker-hub-image-dummy-resource}}
```

Since the source `Dockerfile` is actually within this tutorial's own git repo, we will use it as the input/`get` resource called `resource-tutorial`.

This means the `docker` subfolder in this tutorial section will be available at folder `resource-tutorial/51_dummy_resource_docker_image/docker` during the build plan (`resource-tutorial` is the name of the resource within the job build plan; and `51_dummy_resource_docker_image/docker` is the subfolder where the `Dockerfile` is located).

Your `credentials.yml` now needs your Docker Hub account credentials (see `credentials.example.yml`):

```yaml
docker-hub-email: EMAIL
docker-hub-username: USERNAME
docker-hub-password: PASSWORD
docker-hub-image-dummy-resource: USERNAME/51_dummy_resource_docker_image
```

The `run.sh` script will create the pipeline.yml and upload it to Concourse:

```
./51_*/run.sh credentials.yml
```

You can also trigger the pipeline in the UI using the (+) icon.

This will create a docker image `USERNAME/resource-51-docker-image` on Docker Hub.

Worker references remote docker image
-------------------------------------

On the Vagrant VM (or Worker VM) change `/var/vcap/jobs/groundcrew/config/worker.json`.

Where we had added the following `resource_type` in section 50:

```
{"image":"/var/vcap/packages/dummy","type":"dummy"}
```

Change it to the following (replacing `USERNAME` with your Docker Hub username):

```
{"image":"docker:///USERNAME/resource-51-docker-image","type":"dummy"}
```

Or use a pre-existing Docker image:

```
{"image":"docker:///drnic/resource-51-docker-image","type":"dummy"}
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

The pipeline in section 50 can now be reused to use test our `dummy` resource type:

```
./50_*/run.sh
```
