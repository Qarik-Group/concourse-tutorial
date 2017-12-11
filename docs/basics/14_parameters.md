# Parameterized pipelines

In the preceding sections you were asked to private credentials and personal git URLs into the `pipeline.yml` files. This would make it difficult to share your `pipeline.yml` with anyone who had access to the repository. Not everyone needs nor should have access to the shared secrets.

Concourse pipelines can include `((parameter))` parameters for any value in the pipeline YAML file.

Parameters are all mandatory:

```
cd ../14_parameters
fly sp -t tutorial -c pipeline.yml -p publishing-outputs -n
```

The error output will be like:

```
targeting http://192.168.100.4:8080

failed to evaluate variables into template: 2 error(s) occurred:

* unbound variable in template: 'gist-url'
* unbound variable in template: 'github-private-key'
```

Somewhere secret on laptop create a `credentials.yml` file with keys `gist-url` and `github-private-key`. The values come from your previous `pipeline.yml` files:

```
gist-url: git@gist.github.com:xxxxxxx.git
github-private-key: |-
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpQIBAAKCAQEAuvUl9YUlDHWBMVcuu0FH9u2gSi83PkL4o9TS+F185qDTlfUY
  fGLxDo/bn8ws8B88oNbRKBZR6yig9anIB4Hym2mSwuMOUAg5qsA9zm5ArXQBGoAr
  ...
  iSHcGbKdWqpObR7oau2LIR6UtLvevUXNu80XNy+jaXltqo7MSSBYJjbnLTmdUFwp
  HBstYQubAQy4oAEHu8osRhH1VX8AR/atewdHHTm48DN74M/FX3/HeJo=
  -----END RSA PRIVATE KEY-----
```

To pass in your `credentials.yml` file use the `--load-vars-from` or `-l` options:

```
fly sp -t tutorial -c pipeline.yml -p publishing-outputs -n -l ../credentials.yml
```

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
