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

```yaml
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

A common pattern is for Concourse tasks to `run:` complex shell scripts rather than directly invoking commands as we did above (we ran `uname` command with arguments `-a`).

Let's refactor `01_task_hello_world/task_ubuntu_uname.yml` into a new task `03_task_scripts/task_show_uname.yml` with a separated task script `03_task_scripts/task_show_uname.sh`

```
cd ../03_task_scripts
fly -t tutorial e -c task_show_uname.yml
```

The former specifies the latter as its task script:

```yaml
run:
  path: ./03_task_scripts/task_show_uname.sh
```

_Where does the `./03_task_scripts/task_show_uname.sh` file come from?_

From section 2 we learned that we could pass `inputs` into the task. The task configuration `03_task_scripts/task_show_uname.yml` specifies one input:

```
inputs:
- name: 03_task_scripts
```

Since input `03_task_scripts` matches the current directory `03_task_scripts` we did not need to specify `fly execute -i 03_task_scripts=.`.

The current directory was uploaded to the Concourse task container and placed inside the `03_task_scripts` directory.

Therefore its file `task_show_uname.sh` is available within the Concourse task container at `03_task_scripts/task_show_uname.sh`.

The only further requirement is that `task_show_uname.sh` is an executable script.

### 04 - Basic pipeline

1% of tasks that Concourse runs are via `fly execute`. 99% of tasks that Concourse runs are within "pipelines".

```
cd ../04_basic_pipeline
fly -t tutorial set-pipeline -c pipeline.yml -p helloworld
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
apply configuration? [yN]:
```

Press `y`.

You should see:

```
pipeline created!
you can view your pipeline here: http://192.168.100.4:8080/pipelines/helloworld

the pipeline is currently paused. to unpause, either:
  - run the unpause-pipeline command
  - click play next to the pipeline in the web ui
```

As suggested, un-pause a pipeline from the `fly` CLI:

```
fly -t tutorial unpause-pipeline -p helloworld
```

Next, as suggested, visit the web UI http://192.168.100.4:8080/pipelines/helloworld.

Your first pipeline is unimpressive - a single job `job-hello-world` with no inputs from the left and no outputs to its right, no jobs feeding into it, nor jobs feeding from it. It is the most basic pipeline. The job is gray colour because it has never been run before.

Click on `job-hello-world` and then click on the large `+` in the top right corner. Your job will run.

![job](http://cl.ly/image/3i2e0k0v3O2l/02-job-hello-world.gif)

Clicking the top-left "Home" icon will show the status of our pipeline. The job `job-hello-world` is now green. This means that the last time the job ran it completed successfully.

### 05 - Tasks extracted into Resources

It is very fast to iterate on a job's tasks by configuring them in the `pipeline.yml` as above. You edit the `pipeline.yml`, run `fly set-pipeline`, and the entire pipeline is updated atomically.

But, as per section 3, if a task becomes complex then its `run:` command can be extracted into a task script, and the task itself can be extracted into a `yml` task file.

In section 3 we uploaded the task file and task script from our local computer with the `fly execute` command.

Unlike section 3, with a pipeline we now need to store the task file and task script somewhere outside of Concourse.

Concourse offers no services for storing/retrieving your data. No git repositories. No blobstores. No build numbers. Every input and output must be provided externally. Concourse calls them "Resources". Example resources are `git`, `s3` and `semver` respectively.

See the section "Available concourse resources" below for the list of available built-in resources and how to find community resources. Send messages to Slack. Bump a version number from 0.5.6 to 1.0.0. Create a ticket on Pivotal Tracker. It is all possible with Concourse resources.

The most common resource to store our task files and task scripts is the `git` resource.

This tutorial's source repository is a Git repo, and it contains many task files (and their task scripts). For example, the original `01_task_hello_world/task_hello_world.yml`.

The following pipeline will load this task file and run it. We will update the previous `helloworld` pipeline:

```
cd ../05_pipeline_task_hello_world
fly sp -t tutorial -c pipeline.yml -p helloworld
```

The output will show the delta between the two pipelines and request confirmation. Type `y`. If successful, it will show:

```
apply configuration? [yN]: y
configuration updated
```

The [`helloworld` pipeline](http://192.168.100.4:8080/pipelines/helloworld) now shows an input resource `resource-tutorial` feeding into the job `job-hello-world`.

![pipeline-task-hello-world](http://cl.ly/image/271z3T322l25/03-resource-job.gif)

This tutorial verbosely prefixes `resource-` to resource names, and `job-` to job names, to help you identify one versus the other whilst learning. Eventually you will know one from the other and can remove the extraneous text.

After manually triggering the job via the UI, the output will look like:

![job-task-from-task](http://cl.ly/image/0Q3m223v2l3M/job-task-from-task.png)

The in-progress or newly-completed `job-hello-world` job UI has three sections:

* Preparation for running the job - collecting inputs and dependencies
* `resource-tutorial` resource is fetched
* `hello-world` task is executed

The latter two are "steps" in the job's [build plan](http://concourse.ci/build-plans.html). A build plan is a sequence of steps to execute. These steps may fetch down or update Resources, or execute Tasks.

The first build plan step fetches down (note the down arrow to the left) a `git` repository for these training materials and tutorials. The pipeline named this resource `resource-tutorial`.

The `pipeline.yml` documents this single resource:

```yaml
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git
```

The resource name `resource-tutorial` is then used in the build plan for the job:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
```

Any fetched resource can now be an input to any task in the job build plan. As discussed in section 3 & section 4, task inputs can be used as task scripts.

The second step runs a user-defined task. The pipeline named the task `hello-world`. The task itself is not described in the pipeline. Instead it is described in a file `01_task_hello_world/task_hello_world.yml` from the `resource-tutorial` input.

The completed job looks like:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

The task `{task: hello-world, file: resource-tutorial/...}` has access to all fetched resources (and later, to the outputs from tasks).

The name of resources, and later the name of task outputs, determines the name used to access them by other tasks (and later, by updated resources).

So, `hello-world` can access anything from `resource-tutorial` (this tutorial's `git` repository) under the `resource-tutorial/` path. Since the relative path of `task_hello_world.yml` task file inside this repo is `01_task_hello_world/task_hello_world.yml`, the `task: hello-world` references it by joining the two: `file: resource-tutorial/01_task_hello_world/task_hello_world.yml`


There is a benefit and a downside to abstracting tasks into YAML files outside of the pipeline.

One benefit is that the behavior of the task can be kept in sync with the primary input resource (for example, a software project with tasks for running tests, building binaries, etc).

One downside is that the `pipeline.yml` no longer explains exactly what commands will be invoked. Comprehension of pipeline behavior is potentially reduced.

But one benefit of extracting inline tasks into task files is that `pipeline.yml` files can get long and it can be hard to read and comprehend all the YAML. Instead, give tasks long names so that readers can understand what the purpose and expectation of the task is at a glance.

But one downside of extracting inline tasks into files is that `fly set-pipeline` is no longer the only step to updating a pipeline.

From now onwards, any change to your pipeline might require you to do one or both:

* `fly set-pipeline` to update Concourse on a change to the job build plan and/or input/output resources
* `git commit` and `git push` your primary resource that contains the task files and task scripts

If a pipeline is not performing new behaviour then it might be you skipped one of the two steps above.

### 06 - View job output in terminal

The `job-hello-world` had terminal output from its resource fetch of a git repo and of the `hello-world` task running.

In addition to the Concourse web ui you can also view this output from the terminal with `fly`:

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

The `--build NUM` option allows you to see the output of a specific build number, rather than the latest build output.


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

### 07 - Trigger jobs with the Concourse API

There are three ways for a job to be triggered:

* Clicking the `+` button on the web UI of a job (as we did in previous sections)
* Input resource triggering a job (see section 8 below)
* Sending `POST` HTTP request to Concourse API

NOTE: As at writing there is not a `fly` command to trigger a job to run.

Currently our Concourse in Vagrant has an API running at `http://192.168.100.4:8080`. If you do not remember the API endpoint it might be stored in the `~/.flyrc` file.

We can trigger a job to be run using that API. For example, using `curl`:

```
curl http://192.168.100.4:8080/pipelines/helloworld/jobs/job-hello-world/builds -X POST
```

Whilst the job is running, and after it has completed, you can then watch the output in your terminal using `fly watch`:

```
fly -t tutorial watch -j helloworld/job-hello-world
```

### 08 - Triggering jobs with resources

The primary way that Concourse jobs will be triggered to run will be by resources changing. A `git` repo has a new commit? Run a job to test it. A GitHub project cuts a new release? Run a job to pull down its attached files and do something with them.

Triggering resources are defined the same as non-triggering resources, such as the `resource-tutorial` defined earlier.

The difference is in the job build plan where triggering is desired.

By default, including `get: my-resource` in a build plan does not trigger its job.

To mark a fetched resource as a trigger add `trigger: true`

```yaml
jobs:
- name: job-demo
  plan:
  - get: resource-tutorial
    trigger: true
```

In the above example the `job-demo` job would trigger anytime the remote `resource-tutorial` had a new version. For a `git` resource this would be new git commits.

The `time` resource has express purpose of triggering jobs.

If you want a job to trigger every few minutes then there is the [`time` resource](https://github.com/concourse/time-resource#readme).

```yaml
resources:
- name: my-timer
  type: time
  source:
    interval: 2m
```

Now upgrade the `helloworld` pipeline with the `time` trigger.

```
cd ../08_triggers
fly sp -t tutorial -c pipeline.yml -p helloworld
```

This adds a new resource named `my-timer` which triggers `job-hello-world` approximately every 2 minutes.

Visit the pipeline dashboard http://192.168.100.4:8080/pipelines/helloworld and wait a few minutes and eventually the job will start running automatically.

![my-timer](http://cl.ly/3M3A2n1e2i2s/download/Image%202016-02-28%20at%2010.39.37%20am.png)

The dashboard UI makes non-triggering resources distinct with a hyphenated line connecting them into the job. Triggering resources have a full line.

Why does `time` resource configured with `interval: 2m` trigger "approximately" every 2 minutes?

> "resources are checked every minute, but there's a shorter (10sec) interval for determining when a build should run; time resource is to just ensure a build runs on some rough periodicity; we use it to e.g. continuously run integration/acceptance tests to weed out flakiness" - alex

The net result is that a timer of `2m` will trigger every 2 to 3 minutes.

### 09 - Destroying pipelines

The current `helloworld` pipeline will now keep triggering every 2-3 minutes for ever. If you want to destroy a pipeline - and lose all its build history - then may the power be granted to you.

You can delete the `helloworld` pipeline:

```
fly destroy-pipeline -t tutorial -p helloworld
```

### 10 - Using resource inputs in job tasks

Note, the topic of running unit tests in your pipeline will be covered in more detail in future sections.

Consider a simple application that has unit tests. In order to run those tests inside a pipeline we need:

* a `resource` containing the task script that knows how to run the tests
* a `resource` containing the application source code
* a task `image` that contains any dependencies

For the example Go application [simple-go-web-app](https://github.com/cloudfoundry-community/simple-go-web-app), the task image needs to include the Go programming language. We will use the Docker image https://hub.docker.com/_/golang/


### 11 - Publishing outputs

So far we have used the `git` resource to fetch down a git repository, in which it contained the task file and task scripts.

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
