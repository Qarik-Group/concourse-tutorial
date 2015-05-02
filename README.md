Concourse Tutorial
==================

Learn to use https://concourse.ci with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

Getting started
---------------

Install Vagrant/Virtualbox.

```
vagrant up
```

Open http://192.168.100.4:8080/ in the browser:

[![initial](http://cl.ly/image/221Y1F3V2s0e/concourse_initial.png)](http://192.168.100.4:8080/)

Download the `fly` CLI from the bottom right hand corner:

![cli](http://cl.ly/image/1r462S1m1j1H/fly_cli.png)

Place it in your path (`$PATH`), such as `/usr/bin` or `~/bin`.

Tutorials
---------

### 01 - Hello World task

```
$ cd 01_task_hello_world
$ fly execute -c task_hello_world.yml
Connecting to 10.244.8.2:8080 (10.244.8.2:8080)
-                    100% |*******************************| 10240   0:00:00 ETA
initializing with docker:///busybox
```

At this point it is downloading a large Docker image `busybox`. It will only need to do this once.

Eventually it will continue:

```
running echo hello world
hello world
succeeded
```

### 02 - Hello World job

```
$ cd ../02_job_hello_world
$ fly configure -c pipeline.yml
```

It will display the concourse pipeline (or any changes) and request confirmation:

```yaml
jobs:
  job job-hello-world has been added:
    name: job-hello-world
    public: true
    serial: true
    plan:
    - task: hello-world
      config:
        platform: linux
        image: docker:///ubuntu#14.04
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
  serial: true
  plan:
  - aggregate:
    - get: resource-tutorial
      trigger: false
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

Our `plan:` specifies that first we need to `get` the resource `resource-tutorial`.

Second we use the `01_task_hello_world/task_hello_world.yml` file from `resource-tutorial` as the task configuration.

Apply the updated pipeline using `fly c -c pipeline.yml`.

Or run the pre-created pipeline from the tutorial:

```
cd ../03_resource_job
fly c -c pipeline.yml
```

![resource-job](http://cl.ly/image/271z3T322l25/03-resource-job.gif)

### 04 - Get job output in terminal

The `job-hello-world` had terminal output from its resource fetch of a git repo and of the `hello-world` task running.

You can also view this output from the terminal with `fly`:

```
$ fly watch -j job-hello-world
Cloning into '/tmp/build/src'...
d6f8e75 02 now embeds task; 03 extracts it into resource to be fetched
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
initializing with docker:///ubuntu#14.04
running echo hello world
hello world
succeeded
```

### 05 - The Concourse API and trigger a job via the API

Our concourse in vagrant has an API running at `http://192.168.100.4:8080`. The `fly` CLI targets this endpoint by default.

We can trigger a job to be run using that API. For example, using `curl`:

```
curl http://192.168.100.4:8080/jobs/job-hello-world/builds -X POST
```

If your concourse API is running somewhere else, you can set the environment variable `$ATC_URL`:

```
export ATC_URL=http://myproject.concourse.mycompany.com:8080
```

`fly` will automatically target this API.

### 06 - triggering jobs - the time resource

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
