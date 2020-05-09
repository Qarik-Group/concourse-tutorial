description: The git resource can also be used to push a modified git repository to a remote endpoint (possibly different than where the git repo was originally cloned from).
image_path: /images/broken-resource.png

# Publishing Outputs

So far we have used the `git` resource to fetch down a git repository, and used `git` & `time` resources as triggers. The [`git` resource](https://github.com/concourse/git-resource) can also be used to push a modified git repository to a remote endpoint (possibly different than where the git repo was originally cloned from).

```
cd ../publishing-outputs
cp pipeline-missing-credentials.yml pipeline.yml
fly -t tutorial sp -p publishing-outputs -c pipeline.yml
fly -t tutorial up -p publishing-outputs
```

Pipeline dashboard http://127.0.0.1:8080/teams/main/pipelines/publishing-outputs shows that the input resource is erroring (see orange in key):

![broken-resource](/images/broken-resource.png)

The `pipeline.yml` does not yet have a git repo nor its write-access private key credentials.

[Create a Github Gist](https://gist.github.com/) with a single file `bumpme`, and press "Create public gist":

![gist](/images/gist.png)

Click the "Embed" dropdown, select "Clone via SSH", and copy the git URL:

![ssh](/images/ssh.png)

And modify the `resource-gist` section of `pipeline.yml`:

```
- name: resource-gist
  type: git
  source:
    uri: git@gist.github.com:e028e491e42b9fb08447a3bafcf884e5.git
    branch: master
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpQIBAAKCAQEAuvUl9YU...
      ...
      HBstYQubAQy4oAEHu8osRhH...
      -----END RSA PRIVATE KEY-----
```

Also paste in your `~/.ssh/id_rsa` private key (or which ever you have registered with github) into the `private_key` section.
_Note: Please make sure that the key used here is not generated using a passphrase. Otherwise, the key will not be accepted and you would get an error._

Update the pipeline, force Concourse to quickly re-check the new Gist credentials, and then run the job:

```
fly -t tutorial sp -p publishing-outputs -c pipeline.yml
fly -t tutorial check-resource -r publishing-outputs/resource-gist
fly -t tutorial trigger-job -j publishing-outputs/job-bump-date -w
```

Revisit the Web UI and the orange resource will change to black if it can successfully fetch the new `git@gist.github.com:XXXX.git` repo.

After the `job-bump-date` job completes, refresh your gist:

![gist-bumped](/images/gist-bumped.png)

This pipeline is an example of updating a resource. It has pushed up new git commits to the git repo (your github gist).

_Where did the new commit come from?_

The `task: bump-timestamp-file` task configuration describes a single output `updated-gist`:

```yaml
outputs:
  - name: updated-gist
```

The `bump-timestamp-file` task runs the following `bump-timestamp-file.sh` script:

```bash
git clone resource-gist updated-gist

cd updated-gist
date > bumpme

git config --global user.email "nobody@concourse-ci.org"
git config --global user.name "Concourse"

git add .
git commit -m "Bumped date"
```

First, it copied the input resource `resource-gist` into the output resource `updated-gist` (using `git clone` as a preferred `git` way to do this). A trivial modification is made to the `updated-gist` directory, followed by a `git commit` to modify the `updated-gist` folder's Git repository. It is this `updated-gist` folder and its additional `git commit` that is subsequently pushed back to the gist by the pipeline step:

```yaml
- put: resource-gist
  params:
    repository: updated-gist
```

The `updated-gist` output from the `task: bump-timestamp-file` step becomes the `updated-gist` input to the `resource-gist` resource because their names match (see the [`git` resource](https://github.com/concourse/git-resource) for additional configuration).

## Dependencies within Tasks

The `bump-timestamp-file.sh` script needed the `git` CLI.

It could have been installed at the top of the script using `apt-get update; apt-get install git` or similar, but this would have made the task very slow - each time it ran it would have reinstalled the CLI.

Instead, the `bump-timestamp-file.sh` step assumes its base Docker image already contains the `git` CLI.

The Docker image being used is described in the `image_resources` section of the task's configuration:

```yaml
  - task: bump-timestamp-file
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: { repository: starkandwayne/concourse }
```

The Docker image [`starkandwayne/concourse`](https://hub.docker.com/r/starkandwayne/concourse) is described at https://github.com/starkandwayne/dockerfiles/ and is common base Docker image used by many Stark & Wayne pipelines.

Your organisation may wish to curate its own base Docker images to be shared across pipelines. After finishing the Basics lessons, visit Lesson [Create and Use Docker Images](/miscellaneous/docker-images/) for creating pipelines to create your own Docker images using Concourse.

## Tragic Security

If you're feeling ill from copying your private keys into a plain text file (`pipeline.yml`) and then seeing them printed to the screen (during `fly set-pipeline -c pipeline.yml`), then fear not. We will get to [Secret with Credential Manager](/basics/secret-parameters/) soon.
