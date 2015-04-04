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
$ fly execute -c 01_task_hello_world.yml
Connecting to 10.0.2.15:8080 (10.0.2.15:8080)
-                    100% |[*****************************](https://github.com/concourse/*****************************)| 10240   0:00:00 ETA
initializing with docker:///ubuntu#14.04
running echo hello world
hello world
succeeded
```

On the first time this will trigger concourse to download the `ubuntu#14.04` docker image.

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
-	[broker-resource](https://github.com/concourse/broker-resource) - a resource for cloud foundry service brokers
