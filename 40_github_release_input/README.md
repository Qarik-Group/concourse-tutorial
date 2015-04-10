40 - Github Release Input
=========================

This section will show how to use a Github Release as an input to a job.

Pipeline
--------

The `github-release` resource type requires a `source.user` and `source.repository`. The following example is for the https://github.com/cloudfoundry-incubator/spiff/releases latest release.

```yaml
resources:
- name: github-release-spiff
  type: github-release
  source:
    user: cloudfoundry-incubator
    repository: spiff
```

For a job build plan to fetch the latest release and any attached files, make the following the first step in the job plan (or part of an `aggregate` first step):

```yaml
- get: github-release-spiff
```

When running the job, the `github-release` resource will download the attached files:

```
./github-release-spiff:
total 2712
-rw-r--r-- 1 vcap 1383910 Apr 10 06:54 spiff_darwin_amd64.zip
-rw-r--r-- 1 vcap 1390253 Apr 10 06:54 spiff_linux_amd64.zip
```
