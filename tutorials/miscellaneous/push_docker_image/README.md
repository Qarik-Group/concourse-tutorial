35 - Push Docker image
======================

This section will show how to take a Dockerfile project, build it and push to Docker Hub.

Define a docker image
---------------------

![created-image](http://cl.ly/image/2g3T2s0G0z2b/drnic_hello-world_image.png)

This section's subfolder `docker` containers a `Dockerfile` and a simple `hello-world` command:

```dockerfile
FROM busybox

ADD hello-world /bin/hello-world

ENTRYPOINT ["/bin/hello-world"]
CMD ["world"]
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
  - put: hello-world-docker-image
    params:
      build: resource-tutorial/35_push_docker_image/docker

resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/drnic/concourse-tutorial.git

- name: hello-world-docker-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: {{docker-hub-image-hello-world}}
```

Since the source `Dockerfile` is actually within this tutorial's own git repo, we will use this tutorial repo as the input resource called `resource-tutorial`. In the job `job-publish` build plan we `get` it first; and it is used by the `hello-world-docker-image` docker-image resource next.

This means the `docker` subfolder in this tutorial section will be available at folder `resource-tutorial/35_push_docker_image/docker` during the build plan (`resource-tutorial` is the name of the resource within the job build plan; and `35_push_docker_image/docker` is the subfolder where the `Dockerfile` is located).

Running the pipeline
--------------------

Your `credentials.yml` now needs your Docker Hub account credentials (see `credentials.example.yml`\):

```yaml
docker-hub-email: EMAIL
docker-hub-username: USERNAME
docker-hub-password: PASSWORD
docker-hub-image-hello-world: USERNAME/hello-world
```

The `run.sh` will create the pipeline.yml and upload it to Concourse,
and trigger the job:

```
cd ../35_push_docker_image
./run.sh ../credentials.yml
```

This will create a docker image `<username>/hello-world` on Docker Hub.

Using the docker image
----------------------

In the next tutorial section we will fetch and run the `<username>/hello-world` container image.
