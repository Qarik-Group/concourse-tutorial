# Versioning and Build Numbers

The title of this section mentions "build numbers" because they are a common concept in other CI/CD systems. A sequentially incrementing number that can be used to differentiate by-products/updated resources. Concourse does not have them. There is no "build number" concept in Concourse that is available to your pipelines, jobs, and their steps.

Instead, we have the flexible concept of the [`semver` resource type](https://github.com/concourse/semver-resource#readme) and all the flexibility of Concourse to determine when to increment a `semver` value and by how much.

## SemVer - Semantic Versioning

`semver` is short for "semantic versioning" and is documented at http://semver.org/. In summary,

Given a version number `MAJOR.MINOR.PATCH`, such as `1.3.5`, increment the:

* MAJOR version when you make incompatible API changes,
* MINOR version when you add functionality in a backwards-compatible manner, and
* PATCH version when you make backwards-compatible bug fixes.

Additional labels for pre-release and build metadata are available as extensions to the `MAJOR.MINOR.PATCH` format.

Instead of a monotonically increasing internal build number, with a `semver` resource type you can control the meaning to your version numbers.

If you don't care about the semantic meaning of your `semver` resource type, then start at `0.0.1` and bump the PATCH version only. One day you'll have a value of `0.0.5000` and still have the ability to bump the MINOR value to `0.1.0`.

## Storing the SemVer Value

The simplicity of SemVer within Concourse is that is a simple file stored remotely and made available within a `version` file within your Concourse steps.

The complexity is in deciding how and where to store the version file.

The https://github.com/concourse/semver-resource source project offers the following "how" drivers for storing your SemVer value file:

* [`git`](https://github.com/concourse/semver-resource#git-driver)
* [`s3`](https://github.com/concourse/semver-resource#s3-driver)
* [`swift`](https://github.com/concourse/semver-resource#swift-driver)
* [`gcs`](https://github.com/concourse/semver-resource#gcs-driver)

Nearly all Concourse pipelines will be using a remote `git` repository already for task scripts, so it is convenient to reuse that git project to store a SemVer version file. But it is not common to see this use case of `semver` resource type.

Instead, most Concourse pipelines are already using an `s3`, `swift`, or `gcs` bucket for handling other larger assets, so it is convenient and simpler to reuse that bucket to store a single SemVer version file.

We only need to discuss one of the drivers to cover the topic of the `semver` resource type. The documentation for each is linked above for how to configure them. Since AWS S3 is relatively common and accessible to many Concourse Tutorial readers I will use the `s3` driver as an example.

## Create an AWS S3 bucket

Create or repurpose some AWS API credentials that have access to AWS S3. If you're a user of the `aws` CLI, then you can find some in `~/.aws/credentials`:

```
[youraccount]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = ACCESS_SECRET
```

Add these to your Credhub. Assuming you'll reuse the same credentials for different pipelines you could make them common for all pipelines in the `main` team.

Remember to run `bucc credhub` within your `bucc` project to re-authenticate with Credhub.

```
credhub set -n /concourse/main/aws-access-key-id     -t value -v ACCESS_KEY
credhub set -n /concourse/main/aws-secret-access-key -t value -v ACCESS_SECRET
```

Using the [AWS S3 web UI](https://console.aws.amazon.com/s3/home?region=us-east-1) or the `aws` CLI create a new bucket (or repurpose an existing bucket related to your pipeline).

Change `concourse-tutorial-versions-lesson` below as your bucket name needs to be globally unique, and I took this one.

```
aws --profile youraccount s3 mb s3://concourse-tutorial-versions-lesson
```

Now store your bucket name into Credhub. Typically you might hardcode the bucket name into your `pipeline.yml`. It is a parameter variable in these lessons because it will be different for all readers.

```
credhub set -n /concourse/main/versions-and-buildnumbers/version-aws-bucket -t value -v concourse-tutorial-versions-lesson
```

You can now add a `version` resource to your pipeline:

```yaml
resources:
- name: version
  type: semver
  source:
    driver: s3
    initial_version: 0.0.1
    access_key_id:     ((aws_access_key_id))
    secret_access_key: ((aws_secret_access_key))
    bucket:      ((version_aws_bucket))
    region_name: us-east-1
    key:         concourse-tutorial/version
```

## Display Version

If a step of your pipeline needs to know the current `semver` value you simply `get: version`:

```yaml
jobs:
- name: display-version
  plan:
  - get: version
  - task: display-version
    config:
      inputs:
      - name: version
      run:
        path: cat
        args: [version/number]
```

The `version` resource will store the current SemVer value in a file `number`. Therefore subsequent steps can look up the value within the file path `version/number`.

```
cd tutorials/mischellaneous/versions-and-buildnumbers
fly -t bucc sp -p versions-and-buildnumbers -c pipeline-display-version.yml
fly -t bucc up -p versions-and-buildnumbers
fly -t bucc trigger-job -j versions-and-buildnumbers/display-version -w
```

The job will look delightful in the Concourse dashboard:

![semver-display-version](/images/semver-display-version.png)

## Bumping the Version

Whilst you could manually create and modify the `version` file outside of Concourse, typically you will bump the version within Concourse jobs: automatically at the start of jobs (say pre-release or release-candidate versions), or manually when preparing to release `MAJOR.MINOR.PATCH` releases.

The `semver` resource type can be bumped when it is first fetched down. See [examples](https://github.com/concourse/semver-resource#example).

Its new value only exists within the job's build plan, being passed between containers via `inputs` into tasks.

![bump-version](/images/bump-version.png)

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
- get: version
  params: {pre: rc}
```

A subsequent step could then save this new value back to the remote `s3` version file:

```yaml
plan:
- get: version
  params: {pre: rc}
- put: version
  params: {file: version/number}
```

Apply this change to our pipeline, and trigger the `bump-version` job a few times to see it increment the `0.0.1-rc.3` value:

```
fly -t bucc sp -p versions-and-buildnumbers -c pipeline-bump-then-save.yml
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
```

Run the job to see the output in the image above.

## Delete And Restore Pipeline

Since all Concourse resources are stored outside of your Concourse, it becomes very easy to migrate pipelines or perform disaster recovery.

Delete your pipeline and recreate it:

```
fly -t bucc destroy-pipeline -p versions-and-buildnumbers

fly -t bucc sp -p versions-and-buildnumbers -c pipeline-bump-then-save.yml
fly -t bucc up -p versions-and-buildnumbers
fly -t bucc trigger-job -j versions-and-buildnumbers/bump-version -w
```

Our new pipeline will start its internal build numbers at `#1` again, but it restores the previous `version` value.

![bump-version-restoration](/images/bump-version-restoration.png)
