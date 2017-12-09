# Hello World

The central concept of Concourse is to run tasks. You can run them directly from the command line as below, or from within pipeline jobs (as per every other section of the tutorial).

```
cd tutorials/basic/01_task_hello_world
fly -t tutorial execute -c task_hello_world.yml
```

The output starts with

```
executing build 1
initializing
```

Every task in Concourse runs within a "container" (as best available on the target platform). The `task_hello_world.yml` configuration shows that we are running on a `linux` platform using the `busybox` container image.

Within this container it will run the command `echo hello world`:

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

At this point in the output above it is downloading a Docker image `busybox`. It will only need to do this once; though will recheck every time that it has the latest `busybox` image.

Eventually it will continue and invoke the command `echo hello world` successfully:

```
running echo hello world
hello world
succeeded
```

Try changing the `image_resource:` and the `run:` and run a different task:

```yaml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: ubuntu, tag: "14.04"}

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
executing build 2
initializing
running uname -a
Linux mjgia714efl 3.13.0-49-generic #83-Ubuntu SMP Fri Apr 10 20:11:33 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

The reason that you can select any base `image` (or `image_resource` when [configuring a task](http://concourse.ci/running-tasks.html)) is that this allows your task to have any prepared dependencies that it needs to run. Instead of installing dependencies each time during a task you might choose to pre-bake them into an `image` to make your tasks much faster.

