# Concourse Tutorial

Learn to use https://concourse.ci with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

## Getting started

Install Vagrant/Virtualbox.

Fetch this tutorial and start a local Concourse server:

```
git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial
vagrant up
```

Open http://192.168.100.4:8080/ in your browser:

[![initial](http://cl.ly/image/401b2z2B3w17/no-pipelines.png)](http://192.168.100.4:8080/)

Once the page loads in your browser, click to download the `fly` CLI appropriate for your operating system:

![cli](http://cl.ly/image/1r462S1m1j1H/fly_cli.png)

Once downloaded, copy the `fly` binary into your path (`$PATH`), such as `/usr/local/bin` or `~/bin`. Don't forget to also make it executable. For example,
```
sudo mkdir -p /usr/local/bin
sudo mv ~/Downloads/fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly
```

Target Concourse
----------------

In the spirit of declaring absolutely everything you do to get absolutely the same result every time, the `fly` CLI requires that you specify the target API for every `fly` request.

First, alias it with a name `tutorial` (this name is used by all the tutorial task scripts):

```
fly --target tutorial login  --concourse-url http://192.168.100.4:8080
fly -t tutorial sync
```

You can now see this saved target Concourse API in a local file:

```
cat ~/.flyrc
```

Shows a simple YAML file with the API, credentials etc:

```yaml
targets:
  tutorial:
    api: http://192.168.100.4:8080
    token:
      type: ""
      value: ""
```

When we use the `fly` command we will target this Concourse API using `fly -t tutorial`.

> @alexsuraci: I promise you'll end up liking it more than having an implicit target state :) Makes reusing commands from shell history much less dangerous (rogue fly configure can be bad)

Tutorials
---------

### 01 - Hello World task

The central concept of Concourse is to run tasks. You can run them directly from the command line as below, or from within pipeline jobs (as per every other section of the tutorial).

```
cd 01_task_hello_world
fly -t tutorial execute -c task_hello_world.yml
```

The output starts with

```
executing build 1
initializing with docker:///busybox
```

Every task in Concourse runs within a "container" (as best available on the target platform). The `task_hello_world.yml` configuration shows that we are running on a `linux` platform using a container image defined by `docker:///busybox`.

Within this container it will run the command `echo hello world`:

```yaml
---
platform: linux

image: docker:///busybox

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

Try changing the `image:` and the `run:` and run a different task:

```yaml
---
platform: linux

image: docker:///ubuntu#14.04

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
initializing with docker:///ubuntu#14.04
running uname -a
Linux mjgia714efl 3.13.0-49-generic #83-Ubuntu SMP Fri Apr 10 20:11:33 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

The reason that you can select any base `image` (or `image_resource` when [configuring a task](http://concourse.ci/running-tasks.html)) is that this allows your task to have any prepared dependencies that it needs to run. Instead of installing dependencies each time during a task you might choose to pre-bake them into an `image` to make your tasks much faster.

### 02 - Task inputs

In the previous section the only inputs to the task container were the `image` used. Base images, such as Docker images, are relatively static and relatively big, slow things to create. So Concourse supports `inputs` into tasks to pass in files/folders for processing.

Consider the working directory of a task that explicitly has no inputs:

```
cd ../02_task_inputs
fly -t tutorial e -c no_inputs.yml
```

The task runs `ls -al` to show the (empty) contents of the working folder inside the container:

```
running ls -al
total 8
drwxr-xr-x    2 root     root          4096 Feb 27 07:23 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:23 ..
```

In the example task `inputs_required.yml` we add a single input:

```
inputs:
- name: some-important-input
```

When we try to execute the task:

```
fly -t tutorial e -c inputs_required.yml
```

It will fail:

```
error: missing required input `some-important-input`
```

Commonly if wanting to run `fly execute` we will want to pass in the local folder (`.`). Use `-i name=path` option to configure each of the required `inputs`:

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=.
```

Now the `fly execute` command will upload the `.` directory as an input to the container. It will be made available at the path `some-important-input`:

```
running ls -alR
.:
total 8
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 ..
drwxr-xr-x    1 501      20              64 Feb 27 07:27 some-important-input

./some-important-input:
total 12
drwxr-xr-x    1 501      20              64 Feb 27 07:27 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 ..
-rw-r--r--    1 501      20             112 Feb 27 07:30 input_parent_dir.yml
-rw-r--r--    1 501      20             118 Feb 27 07:27 inputs_required.yml
-rw-r--r--    1 501      20              79 Feb 27 07:18 no_inputs.yml
```

The `fly execute -i` option can be removed if the current directory is the same name as the required input.

The task `input_parent_dir.yml` contains an input `02_task_inputs` which is also the current directory. So the following command will work and return the same results as above:

```
fly -t tutorial e -c input_parent_dir.yml
```

### 03 - Task scripts

The `inputs` feature of a task allows us to pass in two types of inputs:

* requirements/dependencies to be processed/tested/compiled
* task scripts to be executed to perform complex behavior

A common pattern is for Concourse tasks to `run:` complex shell scripts rather than directly invoking commands as we did above (we ran `echo` command with arguments `hello` and `world`).

As your tasks and task scripts build up into complex pipelines you will appreciate the following pattern:

-	Give your task files and task shell scripts the same base name

In the `01_task_hello_world` folder you can see two files:

-	`task_show_uname.yml`
-	`task_show_uname.sh`

The former specifies the latter as its task script:

```
run:
  path: ./task_show_uname.sh
```

_Where does the `./task_show_uname.sh` file come from?_

When you `fly execute` a task file it will upload the current folder as an input to the task. Since the folder also contains `task_show_uname.sh` it is available to the task container to run:

```
$ fly -t tutorial execute -c task_show_uname.yml
executing build 3
initializing with docker:///busybox
running ./task_show_uname.sh
Linux djcb7scpeq0 3.19.0-49-generic #55~14.04.1-Ubuntu SMP Fri Jan 22 11:24:31 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

The output above `running ./task_show_uname.sh` shows that the `task_show_uname.yml` task delegated to a task script to perform the task work.

The `task_show_uname.yml` task is:

```yaml
platform: linux
image: docker:///busybox

inputs:
- {name: 01_task_hello_world, path: .}

run:
  path: ./task_show_uname.sh
```

The new concept above is `inputs:`.

In order for a task to run a task script, it must be given access to the task script. In order for a task to process data files, it must be given access to those data files.

In Concourse these are `inputs` to a task.

Given that we are running the task directly from the `fly` CLI, and we're running it from our host machine inside the `01_task_hello_world` folder, then the current host machine folder will be uploaded to Concourse and made available as an input called `01_task_hello_world`.

Later when we look at Jobs with inputs, tasks and outputs we'll return to passing `inputs` into tasks within a Job.

Consider the `inputs:` snippet above:

```yaml
inputs:
- {name: 01_task_hello_world, path: .}
```

This is saying:

1.	I want to receive an input folder called `01_task_hello_world`
2.	I want it to be placed in the folder `.` (that is, the root folder of the task when its running)

Given the list of `inputs`, we now know that the `task_show_uname.sh` script (which is in the same folder) will be available in the root folder of the running task.

This allows us to invoke it:

```yaml
run:
  path: ./task_show_uname.sh
```

By default, without `path:` an input will be placed in a folder with the same name as the input itself.

That is the following task gives the same results as above:

```yaml
platform: linux
image: docker:///busybox

inputs:
- {name: 01_task_hello_world}
run:
  path: ./01_task_hello_world/task_show_uname.sh
```

### 02 - Basic pipeline

```
cd ../02_job_hello_world
fly set-pipeline -t tutorial -c pipeline.yml -p helloworld
fly unpause-pipeline -t tutorial -p helloworld
```

It will display the concourse pipeline (or any changes) and request confirmation:

```yaml
jobs:
  job job-hello-world has been added:
    name: job-hello-world
    public: true
    plan:
    - task: hello-world
      config:
        platform: linux
        image: docker:///busybox
        run:
          path: echo
          args:
          - hello world
```

You will be prompted to apply any configuration changes each time you run `fly set-pipeline` (or its alias `fly sp`)

```
apply configuration? (y/n):
```

Press `y`.

You should see:

```
pipeline created!
you can view your pipeline here: http://192.168.100.4:8080/pipelines/02helloworld
```

Go back to your browser, refresh the page and start the job manually. Click on `job-hello-world` and then click on the large `+` in the top right corner. Your job will run.

![job](http://cl.ly/image/3i2e0k0v3O2l/02-job-hello-world.gif)

Clicking the top-left "Home" icon will show the status of our pipeline.

### 03 - Tasks extracted into resources

It is easy to iterate on a job's tasks by configuring them in the `pipeline.yml` as above. Eventually you might want to colocate a job task with one of the resources you are already pulling in.

This is a little convoluted example for our "hello world" task, but let's assume the task we want to run is the one from "01 - Hello World task" above. It's stored in a git repo.

In our `pipeline.yml` we add the tutorial's git repo as a resource:

```yaml
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git
```

Now we can consume that resource in our job. Update it to:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

Our `plan:` specifies that first we need to `get` the resource `resource-tutorial`.

Second we use the `01_task_hello_world/task_hello_world.yml` file from `resource-tutorial` as the task configuration.

Apply the updated pipeline using `fly set-pipeline -t tutorial -c pipeline.yml -p 03_resource_job`. #TODO find out how to do that better

Note: `fly` has shorter aliases for it's commands, `fly sp` is shorthand for `fly set-pipeline`

Or run the pre-created pipeline from the tutorial:

```
cd ../03_resource_job
fly sp -t tutorial -c pipeline.yml -p helloworld
```

![resource-job](http://cl.ly/image/271z3T322l25/03-resource-job.gif)

After manually triggering the job via the UI, the output will look like:

![job-task-from-task](http://cl.ly/image/0Q3m223v2l3M/job-task-from-task.png)

The `job-hello-world` job now has two steps in its build plan.

The first step fetches the git repository for these training materials and tutorials. This is a "resource" called `resource-tutorial`.

This resource can now be an input to any task in the job build plan.

The second step runs a user-defined task. We give the task a name `hello-world` which will be displayed in the UI output. The task itself is not described in the pipeline. Instead it is described in `01_task_hello_world/task_hello_world.yml` from the `resource-tutorial` input.

There is a benefit and a downside to abstracting tasks into YAML files outside of the pipeline.

The benefit is that the behavior of the task can be modified to match the input resource that it is operating upon. For example, if the input resource was a code repository with tests then the task file could be kept in sync with how the code repo needs to have its tests executed.

The downside is that the `pipeline.yml` no longer explains exactly what commands will be invoked. Comprehension is potentially reduced. `pipeline.yml` files can get long and it can be hard to read and comprehend all the YAML.

Consider comprehension of other team members when making these choices. "What does this pipeline actually do?!"

One idea is to consider how you name your task files, and thus how you name the task scripts that they invoke.

Consider using (long) names that describe their purpose/behavior.

Try to make the `pipeline.yml` readable. It will become important orchestration within your team/company/project; and everyone needs to know each pipeline actually works.

### 04 - Get job output in terminal

The `job-hello-world` had terminal output from its resource fetch of a git repo and of the `hello-world` task running.

You can also view this output from the terminal with `fly`:

```
fly -t tutorial watch -j helloworld/job-hello-world
```

The output will be similar to:

```
using version of resource found in cache
initializing with docker:///busybox
running echo hello world
hello world
succeeded
```

### 05 - Trigger a Job via the Concourse API

Our concourse in vagrant has an API running at `http://192.168.100.4:8080`. The `fly` CLI targets this endpoint by default.

We can trigger a job to be run using that API. For example, using `curl`:

```
curl http://192.168.100.4:8080/pipelines/helloworld/jobs/job-hello-world/builds -X POST
```

You can then watch the output in your terminal using `fly watch` from above:

```
fly -t tutorial watch -j helloworld/job-hello-world
```

You can see the results of recent builds across all pipelines with `fly builds`:

```
fly -t tutorial builds
```

The output will look like:

```
5   helloworld/job-hello-world    1      succeeded  2016-02-26@17:25:47+1000  2016-02-26@17:26:01+1000  14s
4   helloworld/job-hello-world    1      succeeded  2016-02-26@17:24:43+1000  2016-02-26@17:25:02+1000  19s
3   helloworld/job-hello-world    1      succeeded  2016-02-26@17:22:13+1000  2016-02-26@17:22:23+1000  10s
2   one-off                       n/a    succeeded  2016-02-26@17:15:02+1000  2016-02-26@17:16:36+1000  1m34s
1   one-off                       n/a    succeeded  2016-02-26@17:13:34+1000  2016-02-26@17:14:11+1000  37s
```

### 06 - Triggering jobs - the `time` resource

If you want a job to trigger every few minutes then there is the `time` resource.

```
cd ../06_triggers
fly sp -t tutorial -c pipeline.yml -p helloworld
```

"resources are checked every minute, but there's a shorter (10sec) interval for determining when a build should run; time resource is to just ensure a build runs on some rough periodicity; we use it to e.g. continuously run integration/acceptance tests to weed out flakiness" - alex

The net result is that a timer of `2m` will trigger every 2 to 3 minutes.

Wait a few minutes and you will see the job automatically restart.

### Deleting pipelines

You can delete the `helloworld` pipeline:

```
fly destroy-pipeline -t tutorial -p helloworld
```

## Continuing the tutorial

This tutorial now leaves this README and goes out to the dozens of subfolders. Each has its own README.

Why are there numerical gaps between the section numbers? Because renumbering is hard and so I just left gaps. If we had a cool way to renumber the sections then perhaps wouldn't need the gaps. Sorry :)

### Available concourse resources

In addition to the `git` resource and the `time` resource there are many ways to interact with the external world: getting objects/data or putting objects/data.

Two ideas for finding them:

* https://github.com/concourse?query=resource - the resources bundled with every concourse installation
* https://github.com/search?q=concourse+resource - additional resources shared by other concourse users

Some of the bundled resources include:

-	[bosh-deployment-resource](https://github.com/concourse/bosh-deployment-resource) - deploy bosh releases as part of your pipeline
-	[semver-resource](https://github.com/concourse/semver-resource) - automated semantic version bumping
-	[bosh-io-release-resource](https://github.com/concourse/bosh-io-release-resource) - Tracks the versions of a release on bosh.io
-	[s3-resource](https://github.com/concourse/s3-resource) - Concourse resource for interacting with AWS S3
-	[git-resource](https://github.com/concourse/git-resource) - Tracks the commits in a git repository.
-	[bosh-io-stemcell-resource](https://github.com/concourse/bosh-io-stemcell-resource) - Tracks the versions of a stemcell on bosh.io.
-	[vagrant-cloud-resource](https://github.com/concourse/vagrant-cloud-resource) - manages boxes in vagrant cloud, by provider
-	[docker-image-resource](https://github.com/concourse/docker-image-resource) - a resource for docker images
-	[archive-resource](https://github.com/concourse/archive-resource) - downloads and extracts an archive (currently tgz) from a uri
-	[github-release-resource](https://github.com/concourse/github-release-resource) - a resource for github releases
-	[tracker-resource](https://github.com/concourse/tracker-resource) - pivotal tracker output resource
-	[time-resource](https://github.com/concourse/time-resource) - a resource for triggering on an interval
-	[cf-resource](https://github.com/concourse/cf-resource) - Concourse resource for interacting with Cloud Foundry

To find out which resources are available on your target Concourse you can ask the API endpoint `/api/v1/workers`:

```
$ curl -s http://192.168.100.4:8080/api/v1/workers | jq -r ".[0].resource_types[].type" | sort
archive
bosh-deployment
bosh-io-release
bosh-io-stemcell
cf
docker-image
git
github-release
pool
s3
semver
time
tracker
vagrant-cloud
```
