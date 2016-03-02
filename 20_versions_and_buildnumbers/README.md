# Versioning and Build numbers

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
git checkout --orphan version
git rm --cached -r .
rm -rf *
rm .gitignore .gitmodules
touch version
git add .
git commit -m "new branch"
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
fly sp -t tutorial -p versioning -n -l ../credentials.yml \
  -c pipeline-get-version.yml
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
fly sp -t tutorial -p versioning -n -l ../credentials.yml \
  -c pipeline-display-version.yml
```

Then re-run the `job-versioning` job:

![display-resource-value](http://cl.ly/3a1y3J3v2K3P/download/Image%202016-03-01%20at%2011.49.28%20am.png)

## Bumping the version

Whilst you could manually create and modify the `version` file outside of Concourse, typically you will bump the version within Concourse jobs: automatically at the start of jobs (say pre-release or release-candidate versions), or manually when preparing to release `MAJOR.MINOR.PATCH` releases.

The `semver`-resource can be bumped when it is first fetched down. See [examples](https://github.com/concourse/semver-resource#example).

Its new value only exists within the job's build plan, being passed between containers via `inputs` into tasks.

![bump](http://cl.ly/2b0o3Y3Y3A2E/download/Image%202016-03-01%20at%201.02.34%20pm.png)

There are [two options](https://github.com/concourse/semver-resource#version-bumping-semantics) for bumping a `semver` value when fetching it:

* `bump`: Optional. Bump the version number semantically. The value must be one of:
  * `major`: Bump the major version number, e.g. `1.0.0` -> `2.0.0`.
  * `minor`: Bump the minor version number, e.g. `0.1.0` -> `0.2.0`.
  * `patch`: Bump the patch version number, e.g. `0.0.1` -> `0.0.2`.
  * `final`: Promote the version to a final version, e.g. `1.0.0-rc.1` -> `1.0.0`.
* `pre`: Optional. When bumping, bump to a prerelease (e.g. `rc` or `alpha`), or bump an existing prerelease.

In the pipeline example above we `pre` bumped the `rc` number:

```yaml
plan:
- get: resource-version
  params: {pre: rc}
```

Apply this change to our pipeline:

```
fly sp -t tutorial -p versioning -n -l ../credentials.yml \
  -c pipeline-bump.yml
```

Run the job to see the output in the image above.

## Saving new version

If you re-run the `job-versioning` job you observe that the value of the `version` resource has no actually changed:

![unchanged](http://cl.ly/3E363z3i1c0v/download/Image%202016-03-01%20at%201.06.49%20pm.png)

Most Concourse resources, including `semver`, support way of updating an external thing.

From the [`out` section](https://github.com/concourse/semver-resource#out-set-the-version-or-bump-the-current-one) of `semver` resource, to update the `version` value we need to specify the `file:` path to a preceding container.

In our pipeline above we observed that the `version` value is in the `resource-version/number` file.

To `put:` this value back up to `version` file, we add the following step to our job:

```yaml
  - put: resource-version
    params: {file: resource-version/number}
```

Apply this change to our pipeline:

```
fly sp -t tutorial -p versioning -n -l ../credentials.yml \
  -c pipeline-bump-then-save.yml
```

![bump-then-save](http://cl.ly/0G2x2n2W3q3y/download/Image%202016-03-01%20at%201.17.10%20pm.png)

Now, if you look in your git repository's `version` branch, there is now a `version` file that contains the `initial_version` with its `rc` attribute bumped:

![saved-file](http://cl.ly/2T0f3F1V3T0z/download/Image%202016-03-01%20at%201.19.43%20pm.png)

This `version` file is stored outside of Concourse (as all resources are), but its not really for the direct benefit of any other system. Only your pipeline is the user of this value - via the `semver` resource.

Now, if you run the job `job-versioning` over and over it will progressively increase the `rc` attribute.

![again](http://cl.ly/27460R2F3i3Z/download/Image%202016-03-01%20at%201.32.54%20pm.png)

## Bonus exercise

Create an additional job, called `bump-patch`, in the pipeline that bumps the `resource-version` value's `patch` attribute.

That is, regardless of the `rc` attribute (`0.0.1-rc.1` or `0.0.1-rc.2`), update the version to `0.0.2`.

See the [Version Bumping Semantics](https://github.com/concourse/semver-resource#version-bumping-semantics) readme for inforamtion on how to do this.

Next, create similar jobs called `bump-minor` and `bump-major`.
