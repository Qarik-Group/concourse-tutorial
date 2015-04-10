44 - BOSH Stemcells & Releases
==============================

This section will show how to get BOSH releases and stemcells. It will also show how they are laid out in the build plan pool filesystem.

Stemcells
---------

To target a latest stemcell, the resource only needs to reference it by name:

```yaml
resources:
- name: bosh-stemcell-aws
  type: bosh-io-stemcell
  source:
    name: bosh-aws-xen-ubuntu-trusty-go_agent
```

This is now simply referenced in a job as a `get` input:

```yaml
- get: bosh-stemcell-aws
```

The input resource will create three files:

```
./bosh-stemcell-aws:
total 16
-rw-r--r-- 1 vcap 5662 Apr 10 06:16 stemcell.tgz
-rw-r--r-- 1 vcap  116 Apr 10 06:16 url
-rw-r--r-- 1 vcap    5 Apr 10 06:16 version
```

The `stemcell.tgz` is the file that can be uploaded to a BOSH as a stemcell.

The `version` contains the version of the stemcell that corresponds to http://bosh.io/stemcells such as `2915`.

The `url` contains the URL of the stemcell such as `https://d26ekeud912fhb.cloudfront.net/bosh-stemcell/aws/light-bosh-stemcell-2915-aws-xen-ubuntu-trusty-go_agent.tgz`.

If your build plan does not require the `stemcell.tgz` can set the parameter `tarball` to `false`.

```yaml
- get: bosh-stemcell-aws
  params:
    tarball: false
```

Releases
--------

To target a release the resource only needs to reference it by `repository` name, corresponding to an item on http://bosh.io/releases:

```yaml
- name: bosh-release-redis
  type: bosh-io-release
  source:
    repository: cloudfoundry-community/redis-boshrelease
```

The resource above matches to http://bosh.io/releases/github.com/cloudfoundry-community/redis-boshrelease

This is now simply referenced in a job as a `get` input:

```yaml
- get: bosh-release-redis
```

The input resource will create three files:

```
./bosh-release-redis:
total 1048
-rw-r--r-- 1 vcap 1061202 Apr 10 06:16 release.tgz
-rw-r--r-- 1 vcap      74 Apr 10 06:16 url
-rw-r--r-- 1 vcap       2 Apr 10 06:16 version
```

The `release.tgz` is the file that can be uploaded to a BOSH as a release.

The `version` contains the version of the release tarball that corresponds to http://bosh.io/stemcells such as `9`.

The `url` contains the URL of the release tarball such as `https://bosh.io/d/github.com/cloudfoundry-community/redis-boshrelease?v=9`.

If your build plan does not require the `release.tgz` can set the parameter `tarball` to `false`.

```yaml
- get: bosh-release-redis
  params:
    tarball: false
```

Example
-------

The `pipeline.yml` for this tutorial section demonstrates both fetching stemcells and releases and shows the example output above.
