# Create and Use Docker Images

This section will show how to take a Dockerfile project, build it and push to Docker Hub.

![docker-push](/images/docker-push.png)

You might have many uses for Docker images in your normal work; but you'll also want to curate Docker images for your Concourse pipelines. Your Concourse tasks will be a lot faster if any dependencies are preinstalled on the base image, rather than you downloading them each time from the Internet. Your team might start curating a set of Docker images to be used by all your pipelines.

At Stark & Wayne we maintain our pipeline's Docker images at https://github.com/starkandwayne/dockerfiles/ and convert them into various Docker images with our pipeline https://ci.starkandwayne.com/teams/main/pipelines/docker-images?groups=*

This lesson's `pipeline.yml` and Dockerfile example are found at:

```
cd tutorials/miscellaneous/docker-images
```

Define a docker image
---------------------

This section's subfolder `docker` contains a `Dockerfile` and a simple `hello-world` command. 

```dockerfile
FROM busybox

ADD hello-world /bin/hello-world

ENV NAME=world
ENTRYPOINT ["/bin/hello-world"]
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
    repository: ((docker-hub-username))/concourse-tutorial-hello-world

jobs:
- name: publish
  public: true
  serial: true
  plan:
  - get: tutorial
  - put: hello-world-docker-image
    params:
      build: tutorial/tutorials/miscellaneous/docker-images/docker
```

You can see there are parameters that are required.

## Parameters and Credhub

If you are using `bucc` then use `credhub` to store them.

```
credhub set -n /concourse/main/push-docker-image/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/push-docker-image/docker-hub-username -t value -v you
credhub set -n /concourse/main/push-docker-image/docker-hub-password -t value -v yourpassword
```

Since your Docker Hub credentials are probably common amongst many pipelines, you can register them within your Concourse `main` team, rather than just the pipeline:

```
credhub set -n /concourse/main/docker-hub-email    -t value -v you@email.com
credhub set -n /concourse/main/docker-hub-username -t value -v you
credhub set -n /concourse/main/docker-hub-password -t value -v yourpassword
```

Then setup the pipeline and run the `publish` job:

```
fly -t bucc sp -p push-docker-image -c pipeline.yml -n
fly -t bucc up -p push-docker-image
fly -t bucc trigger-job -j push-docker-image/publish -w
```

The output will include:

```
Successfully built c987adeb0ff8
Successfully tagged you/concourse-tutorial-hello-world:latest
The push refers to a repository [docker.io/you/concourse-tutorial-hello-world]
```

## Using the Docker image

We can now use the Docker image as the base image for tasks.

```
  - task: run
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: ((docker-hub-username))/concourse-tutorial-hello-world
      run:
        path: /bin/hello-world
        args: []
      params:
        NAME: ((docker-hub-username))
```
