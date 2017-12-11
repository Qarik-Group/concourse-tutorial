# Github Release Input

This section will show how to use a Github Release as an input to a job.

![github-release](/images/github-release.png)

## Pipeline

The `github-release` resource type requires a `source.user` and `source.repository`. The following example is for the https://github.com/starkandwayne/shield/releases latest release.

```yaml
resources:
- name: github-release-shield
  type: github-release
  source:
    user: starkandwayne
    repository: shield
```

For a job build plan to fetch the latest release and any attached files, make the following the first step in the job plan (or part of an `aggregate` first step):

```yaml
- get: github-release-shield
```

When running the job, the `github-release` resource will download the attached files:

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
