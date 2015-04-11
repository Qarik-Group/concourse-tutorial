45 - BOSH deploy
================

This section will show how to deploy a simple manifest to an existing BOSH.

The deployment manifest being used is stored at this gist: https://gist.github.com/drnic/3ff87c465d483543c53d

It deploys a Redis cluster of 3-VMs to a BOSH in an AWS VPC.

Deploy
------

The `stub.yml` now needs the target and credentials for a BOSH:

```yaml
---
meta:
  ...
  bosh:
    target: https://54.149.109.239:25555
    username: admin
    password: admin
```

You will need to create your own BOSH deployment manifest, setup VPC networking, etc.

Create the `pipeline.yml` and run it in Concourse with:

```
./45_*/run.sh stub.yml
```
