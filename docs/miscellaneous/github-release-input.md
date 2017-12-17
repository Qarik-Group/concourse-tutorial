# Github Release Input

One of the great features of Concourse is the ability to watch and trigger jobs based on other people's projects. For example you could update submodules and test your project against them; or you can watch for Github Releases as the trigger for your jobs.

This section will show how to use a Github Release as an input to a job.

![github-release](/images/github-release.png)

## Resource Type

The `github-release` resource type requires a `user` and `repository`. The following example is for the https://github.com/starkandwayne/shield/releases latest release.

```yaml
resources:
- name: github-release-shield
  type: github-release
  source:
    user: starkandwayne
    repository: shield
```

## What is SHIELD?

[SHIELD](https://shieldproject.io/) is a backup/recovery system for all your data services. It is multi-tenant and provides encryption in-flight and at-rest. Its open source and sponsored by Stark & Wayne, the lovely people who wrote this Concourse Tutorial book.

If new versions come out, you'd want to automatically test it and then roll it out, wouldn't you? Right. And Concourse is perfect for that.

## Pipeline Example

For a job build plan to fetch the latest release and any attached files, make the following the first step in the job plan (or part of an `aggregate` first step):

```yaml
- get: github-release-shield
```

Similarly, to automatically trigger the job whenever there is a new release of SHIELD:

```yaml
- get: github-release-shield
  trigger: true
```

Try out this pipeline:

```
cd tutorials/miscellaneous/github-release-input
fly -t bucc sp -p github-release-input -c pipeline.yml
fly -t bucc up -p github-release-input
fly -t bucc trigger-job -j github-release-input/shield -w
```

When running the job, the `github-release` resource will download the attached files from the Github Release:

```
./github-release-shield:
total 70328
-rw-r--r-- 1 root     1920 Dec 10 11:40 body
-rw-r--r-- 1 root  7781104 Dec 10 11:40 shield-darwin-amd64
-rw-r--r-- 1 root  7741099 Dec 10 11:40 shield-linux-amd64
-rw-r--r-- 1 root 56479093 Dec 10 11:41 shield-server-linux-amd64.tar.gz
-rw-r--r-- 1 root        6 Dec 10 11:40 tag
-rw-r--r-- 1 root        5 Dec 10 11:40 version
```

Also included are files `tag` and `version`.

-	`tag` is the original git tag used for the Github release
-	`version` is an extrapolated semver version number from the tag (removes first `v` if it exists)

The example job also outputs the contents of this file:

```
initializing
running cat github-release-shield/version
8.0.1succeeded
```

## Examples

If you'd like more examples of using the `github-release` resource type, check out https://github.com/starkandwayne/homebrew-cf/blob/master/ci/pipeline.yml

We maintain a Homebrew tap and a Debian repository https://apt.starkandwayne.com which package our own and 3rd party CLIs into Homebrew and Debian packages. Everytime a new version is released our pipeline automatically updates the Homebrew and Debian package.

[![github-release-debian-packages](/images/github-release-debian-packages.png)](http://ci.starkandwayne.com/teams/main/pipelines/homebrew-recipes?groups=debian)

