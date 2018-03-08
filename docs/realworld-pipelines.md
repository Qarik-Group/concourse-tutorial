Real-world pipelines
====================

This list of example pipelines is sorted by complexity.

traveling-cf-admin
------------------

Tools for Cloud Foundry administrators

The pipeline triggers on new GitHub Releases for Cloud Foundry CLI, and publishes an installer for OS X/Linux that containers it and several other CLIs used by administrators of Cloud Foundry.

-	[Public Concourse](http://54.91.20.239:8080/pipelines/traveling-cf-admin)
-	[Project](https://github.com/cloudfoundry-community/traveling-cf-admin/)
-	[Base folder for CI scripts](https://github.com/cloudfoundry-community/traveling-cf-admin/tree/master/ci)
-	[pipeline.yml](https://github.com/cloudfoundry-community/traveling-cf-admin/blob/master/ci/pipeline.yml)

Inputs:

-	[CF CLI releases](https://github.com/cloudfoundry/cli/releases)

Outputs:

-	[traveling-cf-admin releases](https://github.com/cloudfoundry-community/traveling-cf-admin/releases)

The semver version for `traveling-cf-admin` releases is the same as the upstream CF CLI version. There are pros and cons to a downstream project using the version of an upstream dependency.

bosh-init
---------

bosh-init is a tool used to create and update the Director (its VM and persistent disk) in a BOSH environment.

-	[Public Concourse](https://concourse-1739433260.us-east-1.elb.amazonaws.com/)
-	[Project](https://github.com/cloudfoundry/bosh-init)
-	[Base folder for CI scripts](https://github.com/cloudfoundry/bosh-init/tree/master/ci)
-	[pipeline.yml](https://github.com/cloudfoundry/bosh-init/blob/master/ci/concourse/pipeline.yml)

bosh-lite
---------

A local development environment for BOSH using Warden containers in a Vagrant box.

-	[Public Concourse](http://lite.bosh-ci.cf-app.com:8080/)
-	[Project](https://github.com/cloudfoundry/bosh-lite)
-	[Base folder for CI scripts](https://github.com/cloudfoundry/bosh-lite/tree/master/ci)

No pipeline.yml available [![cloudfoundry/bosh-lite/issues/261](https://github-shields.com/github/cloudfoundry/bosh-lite/issues/261.svg)](https://github-shields.com/github/cloudfoundry/bosh-lite/issues/261)

concourse
---------

The Concourse project has two pipelines that combined to distribute version of Concourse itself.

-	[Public Concourse](https://ci.concourse-ci.org)
	-	[Main](https://ci.concourse-ci.org/pipelines/main)
	-	[Resources](https://ci.concourse-ci.org/pipelines/resources)
-	[Project](https://github.com/concourse/concourse)
-	[Base folder for CI scripts](https://github.com/concourse/concourse/tree/master/ci)
-	[pipelines](https://github.com/concourse/concourse/tree/master/ci/pipelines)
