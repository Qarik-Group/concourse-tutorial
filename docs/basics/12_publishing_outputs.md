# Publishing outputs

So far we have used the `git` resource to fetch down a git repository, and used `git` & `time` resources as triggers. The [`git` resource](https://github.com/concourse/git-resource) can also be used to push a modified git repository to a remote endpoint (possibly different than where the git repo was originally cloned from).

```
cd ../12_publishing_outputs
fly sp -t tutorial -c pipeline.yml -p publishing-outputs -n
fly up -t tutorial -p publishing-outputs
```

Pipeline dashboard http://192.168.100.4:8080/pipelines/publishing-outputs shows that the input resource is erroring (see orange in key):

![broken-resource](http://cl.ly/330n473y3X1s/download/Image%202016-02-28%20at%206.33.26%20pm.png)

The `pipeline.yml` does not yet have a git repo nor its write-access private key credentials.

[Create a Github Gist](https://gist.github.com/) with a single file `bumpme`, and press "Create public gist":

![gist](http://cl.ly/3P1m1m272B2h/download/Image%202016-02-28%20at%206.35.10%20pm.png)

Copy the "SSH" git URL:

![ssh](http://cl.ly/2m303j1r3E3b/download/Image%202016-02-28%20at%206.36.52%20pm.png)

And paste it into the `pipeline.yml` file:

```
---
resources:
- name: resource-gist
  type: git
  source:
    uri: git@gist.github.com:0c2e172346cb8b0197a9.git
    branch: master
    private_key: |-
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAuvUl9YU...
      ...
      HBstYQubAQy4oAEHu8osRhH...
      -----END RSA PRIVATE KEY-----
```

Also paste in your `~/.ssh/id_rsa` private key (or which ever you have registered with github) into the `private_key` section.

Update the pipeline:

```
fly sp -t tutorial -c pipeline.yml -p publishing-outputs -n
```

Revisit the dashboard UI and the orange resource will change to black if it can successfully fetch the new `git@gist.github.com:XXXX.git` repo.

After running the `job-bump-date` job, refresh your gist:

![bumped](http://cl.ly/2w0E3U0y0735/download/Image%202016-02-28%20at%208.47.54%20pm.png)

This pipeline is an example of updating a resource. It has pushed up new git commits to the git repo (your github gist).

_Where did the new commit come from?_

The `bump-timestamp-file.yml` task file describes a single output `updated-gist`:

```yaml
outputs:
  - name: updated-gist
```

The `bump-timestamp-file` task runs the following `bump-timestamp-file.sh` script:

```bash
git clone resource-gist updated-gist

cd updated-gist
echo $(date) > bumpme

git config --global user.email "nobody@concourse.ci"
git config --global user.name "Concourse"

git add .
git commit -m "Bumped date"
```

First, it copied the input resource `resource-gist` into the output resource `updated-gist` (using `git clone` as the preferred `git` way to do this). The modifications are subsequently made to the `updated-gist` directory, including a `git commit`. It is this `updated-gist` and its additional `git commit` that is subsequently pushed back to the gist by the pipeline step:

```yaml
- put: resource-gist
  params: {repository: updated-gist}
```

The `updated-gist` output from the `bump-timestamp-file` task becomes the `updated-gist` input to the `resource-gist` resource (see the [`git` resource](https://github.com/concourse/git-resource) for additional configuration) because their names match.

The `bump-timestamp-file.sh` script needed the `git` CLI tool. It could have installed it each time via `apt-get install git` or similar, but this would have made the task very slow. Instead `bump-timestamp-file.yml` task file uses a different base image `concourse/concourse-ci` that contains `git` CLI (and many other pre-installed packages). The contents of this Docker image are described at https://github.com/concourse/concourse/blob/master/ci/dockerfiles/concourse-ci/Dockerfile

