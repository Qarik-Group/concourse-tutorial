# 20 - Versioning and Build numbers

The title of this section mentions "build numbers" because they are a common concept in other CI/CD systems. A sequentially incrementing number that can be used to differentiate by-products/updated resources. Concourse does not have them. There is no "build number" concept in Concourse.

Instead, we have the flexible concept of the [`semver` resource](https://github.com/concourse/semver-resource#readme) and all the flexibility of Concourse to determine when to increment a `semver` value and by how much.

## Semver - semantic versioning

`semver` is short for "semantic versioning" and is documented at http://semver.org/. In summary,

Given a version number `MAJOR.MINOR.PATCH`, increment the:

* MAJOR version when you make incompatible API changes,
* MINOR version when you add functionality in a backwards-compatible manner, and
* PATCH version when you make backwards-compatible bug fixes.

Additional labels for pre-release and build metadata are available as extensions to the `MAJOR.MINOR.PATCH` format.

Instead of a semantically meaningless build number, with a `semver` resource you can give meaning to your version numbers.

## Setup with a git branch

A simple way to get started is to use the same `git` repository you might be already using for your project, create a new branch (say `version`), and store the current `semver` value in a file (say `version`). The new `version` branch will never be merged into your `master` branch - it exists only to bump along a version value.

To setup this new branch in your repository you could run:

```
git checkout -b version
git rm -rf *
git commit -m "remove unnecessary files for version branch"
git push origin version
```

In your pipeline you now add a `semver` resource:

```yaml
- name: resource-version
  type: semver
  source:
    driver: git
    initial_version: 0.0.1
    uri: {{git-uri-bump-semver}}
    branch: version
    file: version
    private_key: {{github-private-key}}    
```

Any place in your pipeline where you want to know the current `semver` you simply `get: resource-version`:

```yaml
jobs:
- name: job-versioning
  public: true
  serial: true
  plan:
  - get: resource-version
```

Add `git-uri-bump-semver` to your tutorial's `credentials.yml` file and deploy this simple pipeline:

```
cd ../20_versions_and_buildnumbers
fly sp -t tutorial -p versioning -n -l ../credentials.yml -c pipeline-get-version.yml
fly up -t tutorial -p versioning
```

The pipeline is at http://192.168.100.4:8080/pipelines/versioning

After you run the `job-versioning` job, it will fetch the `resource-version` resource and give it its `initial_version` of `0.0.1` (defined above):

![initial-version](http://cl.ly/2i0j2K2W2Q0M/download/Image%202016-03-01%20at%2011.32.09%20am.png)

## Access version value

When you `get` a `semver` resource (see the step `- get: resource-version` above), then the version value is stored in a file `number` (note, this is not the name of the file into which the value is stored in the git repository).

Subsequent tasks can access the `number` value via the name of the resource:

```yaml
jobs:
- name: job-versioning
  public: true
  serial: true
  plan:
  - get: resource-version
  - task: display-version
    config:
      platform: linux
      image: docker:///busybox
      inputs:
      - name: resource-version
      run:
        path: cat
        args: [resource-version/number]
```

Update our `versioning` pipeline:

```
fly sp -t tutorial -p versioning -n -l ../credentials.yml -c pipeline-display-version.yml
```

Then re-run the `job-versioning` job:

![display-resource-value](http://cl.ly/3a1y3J3v2K3P/download/Image%202016-03-01%20at%2011.49.28%20am.png)

## Bumping the version

Whilst you could manually create and modify the `version` file outside of Concourse, typically you will bump the version within Concourse jobs: automatically at the start of jobs (say pre-release or release-candidate versions), or manually when preparing to release `MAJOR.MINOR.PATCH` releases.

The `semver`-resource can be bumped when it is first fetched down. See [examples](https://github.com/concourse/semver-resource#example).

Its new value only exists within the job's build plan, being passed between containers via `inputs` into tasks.

## Saving new version

Finally, if the new `version` of some software or an artifact is sufficient then the job can update the version via `put: resource-version` step.
