45 - BOSH deploy
================

This section will show how to deploy a simple manifest to an existing BOSH.

The deployment manifest being used is stored at this gist: https://gist.github.com/drnic/3ff87c465d483543c53d

![pipeline](http://cl.ly/image/1U1R2e1m412a/bosh-deploy-pipeline.png)

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

Since `bosh deploy` is a no-op if the manifest doesn't change, re-running the pipeline job succeeds:

![](http://cl.ly/image/2f0l1W200q3L/bosh-deploy-redis.png)

Notes
-----

For a normal BOSH with built-in SSL, you will need to set `source.ignore_ssl` to `true` in your `bosh-deployment` resource:

```yaml
- name: resource-redis-bosh-deployment
  type: bosh-deployment
  source:
    target: (( meta.bosh.target ))
    username: (( meta.bosh.username ))
    password: (( meta.bosh.password ))
    deployment: redis
    ignore_ssl: true
```
