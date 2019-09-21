description: The central concept of Concourse is to run tasks. You can run them directly from the command line as below, or from within pipeline jobs (as per every other section of the tutorial).
image_path: /images/build-output-hello-world.png


# Hello World

The central concept of Concourse is to run tasks. You can run them directly from the command line as below, or from within pipeline jobs (as per every other section of the tutorial).

From the same directory in which you previously deployed the Docker Concourse image (verify by running `ls -l` and looking for the `docker-compose.yml` file), start the local Concourse server.

```
docker-compose up
```

Now clone the Concourse Tutorial repo, switch to the task-hello-world directory, and run the command to execute the `task_hello_world.yml` task.

```
git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial/tutorials/basic/task-hello-world
fly -t tutorial execute -c task_hello_world.yml
```

The output starts with

```
executing build 1 at http://127.0.0.1:8080/builds/1
initializing
```

Every task in Concourse runs within a "container" (as best available on the target platform). The `task_hello_world.yml` configuration shows that we are running on a `linux` platform using the `busybox` container image.  You will see it downloading a Docker image `busybox`. It will only need to do this once; though will recheck every time that it has the latest `busybox` image.

Within this container it will run the command `echo hello world`.

The `task_hello_world.yml` task file looks like:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: busybox}

run:
  path: echo
  args: [hello world]
```


Eventually it will continue and invoke the command `echo hello world` successfully:

```
running echo hello world
hello world
succeeded
```

The URL http://127.0.0.1:8080/builds/1 is viewable in the browser. It is another view of the same task.

![build-output-hello-world](/images/build-output-hello-world.png)

## Task Docker Images

Try changing the `image_resource:` and the `run:` and run a different task:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: ubuntu}

run:
  path: uname
  args: [-a]
```

This task file is provided for convenience:

```
fly -t tutorial execute -c task_ubuntu_uname.yml
```

The output looks like:

```
executing build 2 at http://127.0.0.1:8080/builds/2
initializing
...
running uname -a
Linux fdfa0821-fbc9-42bc-5f2f-219ff09d8ede 4.4.0-101-generic #124~14.04.1-Ubuntu SMP Fri Nov 10 19:05:36 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

The reason that you can select any base `image` (or `image_resource` when [configuring a task](http://concourse-ci.org/running-tasks.html)) is that this allows your task to have any prepared dependencies that it needs to run. Instead of installing dependencies each time during a task you might choose to pre-bake them into an `image` to make your tasks much faster.

## Miscellaneous

If you're interested in creating new Docker images using Concourse (of course you are), then there is a future section [Create and Use Docker Images](/miscellaneous/docker-images).
