# Versioned artifacts

See also http://concourse.ci/versioned-s3-artifacts.html

In the tutorial so far we have fetched down `git` repositories, `git push` changes update to a `git` repo, deployed a web application whose source came from a `git` repo, and bumped along a version number with the `semver` resource (which was backed by a `git` repository). But `git` repositories are only one of the many ways in which your Concourse pipelines can interact with the world.

It is a common requirement of a CI/CD pipeline to fetch down source code from your projects and publish compiled/built artifacts. Examples include executables, shared libraries and published documentation.
