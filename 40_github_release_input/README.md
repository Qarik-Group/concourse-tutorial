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
-rw-r--r-- 1 vcap 1384411 May  5 19:08 spiff_darwin_amd64.zip
-rw-r--r-- 1 vcap 1390871 May  5 19:08 spiff_linux_amd64.zip
-rw-r--r-- 1 vcap       6 May  5 19:08 tag
-rw-r--r-- 1 vcap       5 May  5 19:08 version
```

Also included are files `tag` and `version`.

-	`tag` is the original git tag used for the Github release
-	`version` is an extrapolated semver version number from the tag (removes first `v` if it exists)

The example job also outputs the contents of this file:

```
initializing
running cat github-release-spiff/version
1.0.6
```

The `run.sh` will create the pipeline.yml and upload it to Concourse,
and trigger the job:

```
cd ../40_github_release_input
./run.sh

```
