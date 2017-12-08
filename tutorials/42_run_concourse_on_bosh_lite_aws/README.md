42 - Run Concourse on bosh-lite/AWS
===================================

As at the time of writing, [BOSH](https://bosh.io) is the only production method for deploying, upgrading, scaling Concourse.

The next few tutorial stages will demonstrate creating and deploying BOSH releases. BOSH is an open source tool chain for release engineering, deployment and lifecycle management of large scale distributed services. Concourse itself is published as a BOSH release and is very easy to deploy into a single-VM version of BOSH called bosh-lite.

**ProTip:** Once Concourse is running within bosh-lite, or managed by a normal BOSH, it becomes very easy to upgrade between new Concourse releases. Indeed in a later stage we will create a pipeline to do this automatically.

Deployment
----------

The deployment instructions for this section have been moved into a dedicated repository:

https://github.com/starkandwayne/concourse-bosh-lite
