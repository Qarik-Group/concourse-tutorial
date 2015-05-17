Real-world pipelines
====================

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
