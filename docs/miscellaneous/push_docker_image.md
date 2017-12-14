# Push Docker image

This section will show how to take a Dockerfile project, build it and push to Docker Hub.

```
cd tutorials/miscellaneous/push_docker_image
```

Define a docker image
---------------------

![created-image](http://cl.ly/image/2g3T2s0G0z2b/drnic_hello-world_image.png)

This section's subfolder `docker` containers a `Dockerfile` and a simple `hello-world` command. 

```dockerfile
FROM busybox

ADD hello-world /bin/hello-world

ENTRYPOINT ["/bin/hello-world"]
CMD ["world"]
```

Create a docker container image
-------------------------------

We could manually create a docker image and push it to Docker Hub. But since we have Concourse we will use it instead.

The purpose of this lesson's `pipeline.yml` is to `put` a `docker-image` resource.

```yaml
resources:
- name: tutorial
  type: git
  source:
    uri: https://github.com/drnic/concourse-tutorial.git
    branch: develop

- name: hello-world-docker-image
  type: docker-image
  source:
    email: ((docker-hub-email))
    username: ((docker-hub-username))
    password: ((docker-hub-password))
    repository: repository: ((docker-hub-username))/concourse-tutorial-hello-world

jobs:
- name: publish
  public: true
  serial: true
  plan:
  - get: tutorial
  - put: hello-world-docker-image
    params:
      build: tutorial/tutorials/miscellaneous/push_docker_image/docker
```

You can see there are parameters that are required.

## Parameters and Credhub

If you are using `bucc` then use `credhub` to store them.

```
credhub set -n /concourse/main/push_docker_image/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/push_docker_image/docker-hub-username -t value -v you
credhub set -n /concourse/main/push_docker_image/docker-hub-password -t value -v yourpassword
```

Since your Docker Hub credentials are probably common amongst many pipelines, you can register them within your Concourse `main` team, rather than just the pipeline:

```
credhub set -n /concourse/main/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/docker-hub-username -t value -v you
credhub set -n /concourse/main/docker-hub-password -t value -v yourpassword
```

Then setup the pipeline and run the `publish` job:

```
fly -t bucc sp -p push_docker_image -c pipeline.yml -n
fly -t bucc up -p push_docker_image
fly -t bucc trigger-job -j push_docker_image/publish -w
```

The output will include:

```
Successfully built c987adeb0ff8
Successfully tagged you/concourse-tutorial-hello-world:latest
The push refers to a repository [docker.io/you/concourse-tutorial-hello-world]
```
