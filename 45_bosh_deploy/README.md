45 - BOSH deploy
================

This section will show how to deploy a simple manifest to an existing BOSH.

The deployment manifest being used is stored at this gist: https://gist.github.com/drnic/3ff87c465d483543c53d

![pipeline](http://cl.ly/image/3E2b0I0D3t0Q/pipeline.png)

![job](http://cl.ly/image/3e2f0G1z3n2G/job-deploy__6_-_Concourse.png)

![job-done](http://cl.ly/image/2w0p1c2m2b3Y/job-deploy__6_-_Concourse.png)

It deploys a Redis cluster of 3-VMs to a BOSH in a bosh-lite hosted on AWS (which happens to also be running the Concourse being used).

Deploy
------

The `credentials.yml` now needs the target and credentials for a BOSH:

```yaml
---
bosh-target: https://54.2.3.4:25555
bosh-username: admin
bosh-password: admin
bosh-stemcell-name: bosh-warden-boshlite-ubuntu-trusty-go_agent
```

You will need to update the manifest with the UUID of your bosh.

- Fork the manifest gist at https://gist.github.com/drnic/3ff87c465d483543c53d
- Determine the UUID of your bosh with `bosh status --uuid`
- Update line 2 of the manifest with your UUID
- Update resource-manifest `pipeline.yml` with the URL of your forked gist

Push the pipeline to Concourse with:

```
cd ../45_bosh_deploy
./run.sh ../credentials.yml
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
    target: bosh-target
    username: bosh-username
    password: bosh-password
    deployment: redis
    ignore_ssl: true
```
