Concourse Tutorial
==================

Learn to use https://concourse.ci with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

Getting started
---------------

Install Vagrant/Virtualbox.

```
vagrant up
```

Open http://192.168.100.4:8080/ in your browser:

[![initial](http://cl.ly/image/401b2z2B3w17/no-pipelines.png)](http://192.168.100.4:8080/)

Once the page loads in your browser, click to download the `fly` CLI appropriate for your operating system:

![cli](http://cl.ly/image/1r462S1m1j1H/fly_cli.png)

Once downloaded, copy the `fly` binary into your path (`$PATH`), such as `/usr/local/bin` or `~/bin`. Don't forget to also make it executable. For example, 
```
mv ~/Downloads/fly /usr/local/bin/fly
chmod 0755 /usr/local/bin/fly
```

Target Concourse
----------------

In the spirit of declaring absolutely everything you do to get absolutely the same result every time, the `fly` CLI requires that you specify the target API for every `fly` request.

First, alias it with a name `tutorial` (this name is used by all the tutorial wrapper scripts):

```
fly save-target tutorial --api http://192.168.100.4:8080
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
    username: ""
    password: ""
    cert: ""
```

When we use the `fly` command we will target this Concourse API using `fly -t tutorial`.

> @alexsuraci: I promise you'll end up liking it more than having an implicit target state :) Makes reusing commands from shell history much less dangerous (rogue fly configure can be bad)

Tutorials
---------

### 01 - Hello World task

```
cd 01_task_hello_world
fly -t tutorial execute -c task_hello_world.yml
```

The output starts with

```
Connecting to 192.168.100.4:8080 (192.168.100.4:8080)
-                    100% |*******************************| 10240   0:00:00 ETA
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

Eventually it will continue:

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
$ fly -t tutorial execute -c task_ubuntu_uname.yml
Connecting to 192.168.100.4:8080 (192.168.100.4:8080)
-                    100% |*******************************| 10240   0:00:00 ETA
initializing with docker:///ubuntu#14.04
running uname -a
Linux mjgia714efl 3.13.0-49-generic #83-Ubuntu SMP Fri Apr 10 20:11:33 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
succeeded
```

A common pattern is for Concourse tasks to `run:` wrapper shell scripts, rather than directly invoking commands.

As your tasks and wrapper scripts build up into complex pipelines you will appreciate the following pattern:

-	Give your task files and wrapper shell scripts the same base name

In the `01_task_hello_world` folder you can see two files:

-	`task_show_uname.yml`
-	`task_show_uname.sh`

When you execute a task file directly via `fly`, it will upload the current folder as an input to the task. This means the wrapper shell script is available for execution:

```
$ fly -t tutorial execute -c task_show_uname.yml
Connecting to 192.168.100.4:8080 (192.168.100.4:8080)
-                    100% |*******************************| 10240   0:00:00 ETA
initializing with docker:///busybox
running ./task_show_uname.sh
Linux mjgia714eg3 3.13.0-49-generic #83-Ubuntu SMP Fri Apr 10 20:11:33 UTC 2015 x86_64 GNU/Linux
succeeded
```

The output above `running ./task_show_uname.sh` shows that the `task_show_uname.yml` task delegated to a wrapper script to perform the task work.

The `task_show_uname.yml` task is:

```yaml
platform: linux
image: docker:///busybox

inputs:
- name: 01_task_hello_world
  path: .

run:
  path: ./task_show_uname.sh
```

The new concept above is `inputs:`.

In order for a task to run a wrapper script, it must be given access to the wrapper script. In order for a task to process data files, it must be given access to those data files.

In Concourse these are `inputs` to a task.

Given that we are running the task directly from the `fly` CLI, and we're running it from our host machine inside the `01_task_hello_world` folder, then the current host machine folder will be uploaded to Concourse and made available as an input called `01_task_hello_world`.

Later when we look at Jobs with inputs, tasks and outputs we'll return to passing `inputs` into tasks within a Job.

Consider the `inputs:` snippet above:

```yaml
inputs:
- name: 01_task_hello_world
  path: .
```

This is saying:

1.	I want to receive an input folder called `01_task_hello_world`
2.	I want it to be placed in the folder `.` (that is, the root folder of the task when its running)

By default, without `path:` an input will be placed in a folder with the same name as the input itself.

Given the list of `inputs`, we now know that the `task_show_uname.sh` script (which is in the same folder) will be available in the root folder of the running task.

This allows us to invoke it:

```yaml
run:
  path: ./task_show_uname.sh
```

### 02 - Hello World job

```
cd ../02_job_hello_world
fly -t tutorial configure -c pipeline.yml --paused=false 02helloworld
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

You will be prompted to apply any configuration changes each time you run `fly configure` (or its alias `fly c`\):

```
apply configuration? (y/n):
```

Press `y`.

You should see:

```
pipeline created!
you can view your pipeline here: http://192.168.100.4:8080/pipelines/02helloworld
```

Go back to your browser and start the job manually. Click on `job-hello-world` and then click on the large `+` in the top right corner. Your job will run.

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
    uri: https://github.com/drnic/concourse-tutorial.git
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

Apply the updated pipeline using `fly c -c pipeline.yml`.

Or run the pre-created pipeline from the tutorial:

```
cd ../03_resource_job
fly -t tutorial c -c pipeline.yml
```

![resource-job](http://cl.ly/image/271z3T322l25/03-resource-job.gif)

After manually triggering the job via the UI, the output will look like:

![job-task-from-wrapper](http://cl.ly/image/0Q3m223v2l3M/job-task-from-wrapper.png)

The `job-hello-world` job now has two steps in its build plan.

The first step fetches the git repository for these training materials and tutorials. This is a "resource" called `resource-tutorial`.

This resource can now be an input to any task in the job build plan.

The second step runs a user-defined task. We give the task a name `hello-world` which will be displayed in the UI output. The task itself is not described in the pipeline. Instead it is described in `01_task_hello_world/task_hello_world.yml` from the `resource-tutorial` input.

There is a benefit and a downside to abstracting tasks into YAML files outside of the pipeline.

The benefit is that the behavior of the task can be modified to match the input resource that it is operating upon. For example, if the input resource was a code repository with tests then the task file could be kept in sync with how the code repo needs to have its tests executed.

The downside is that the `pipeline.yml` no longer explains exactly what commands will be invoked. Comprehension is potentially reduced. `pipeline.yml` files can get long and it can be hard to read and comprehend all the YAML.

Consider comprehension of other team members when making these choices. "What does this pipeline actually do?!"

One idea is to consider how you name your task files, and thus how you name the wrapper scripts that they invoke.

Consider using (long) names that describe their purpose/behavior.

Try to make the `pipeline.yml` readable. It will become important orchestration within your team/company/project; and everyone needs to know how it actually works.

### 04 - Get job output in terminal

The `job-hello-world` had terminal output from its resource fetch of a git repo and of the `hello-world` task running.

You can also view this output from the terminal with `fly`:

```
fly -t tutorial watch -j job-hello-world
```

The output will be similar to:

```
Cloning into '/tmp/build/src'...
8cc9e48 deploy concourse to bosh-lite prior to bosh stages of tutorial
initializing with docker:///busybox
running echo hello world
hello world
succeeded
```

### 05 - Trigger a Job via the Concourse API

Our concourse in vagrant has an API running at `http://192.168.100.4:8080`. The `fly` CLI targets this endpoint by default.

We can trigger a job to be run using that API. For example, using `curl`:

```
curl http://192.168.100.4:8080/pipelines/main/jobs/job-hello-world/builds -X POST
```

You can then watch the output in your terminal using `fly watch` from above:

```
fly -t tutorial watch -j job-hello-world
```

### 06 - Triggering jobs - the `time` resource

"resources are checked every minute, but there's a shorter (10sec) interval for determining when a build should run; time resource is to just ensure a build runs on some rough periodicity; we use it to e.g. continuously run integration/acceptance tests to weed out flakiness" - alex

The net result is that a timer of `2m` will trigger every 2 to 3 minutes.

### 20 - Available concourse resources

https://github.com/concourse?query=resource

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
s3
semver
time
tracker
vagrant-cloud
```
