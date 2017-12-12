# Tasks extracted into Resources

It is very fast to iterate on a job's tasks by configuring them in the `pipeline.yml` as above. You edit the `pipeline.yml`, run `fly set-pipeline`, and the entire pipeline is updated atomically.

But, as per section 3, if a task becomes complex then its `run:` command can be extracted into a task script, and the task itself can be extracted into a `yml` task file.

In section 3 we uploaded the task file and task script from our local computer with the `fly execute` command.

Unlike section 3, with a pipeline we now need to store the task file and task script somewhere outside of Concourse.

Concourse offers no services for storing/retrieving your data. No git repositories. No blobstores. No build numbers. Every input and output must be provided externally. Concourse calls them "Resources". Example resources are `git`, `s3` and `semver` respectively.

See the section "Available concourse resources" below for the list of available built-in resources and how to find community resources. Send messages to Slack. Bump a version number from 0.5.6 to 1.0.0. Create a ticket on Pivotal Tracker. It is all possible with Concourse resources.

The most common resource to store our task files and task scripts is the `git` resource.

This tutorial's source repository is a Git repo, and it contains many task files (and their task scripts). For example, the original `01_task_hello_world/task_hello_world.yml`.

The following pipeline will load this task file and run it. We will update the previous `helloworld` pipeline:

```
cd ../05_pipeline_task_hello_world
fly sp -t tutorial -c pipeline.yml -p helloworld
```

The output will show the delta between the two pipelines and request confirmation. Type `y`. If successful, it will show:

```
apply configuration? [yN]: y
configuration updated
```

The [`helloworld` pipeline](http://192.168.100.4:8080/teams/main/pipelines/helloworld) now shows an input resource `resource-tutorial` feeding into the job `job-hello-world`.

![pipeline-task-hello-world](/images/03-resource-job.gif)

This tutorial verbosely prefixes `resource-` to resource names, and `job-` to job names, to help you identify one versus the other whilst learning. Eventually you will know one from the other and can remove the extraneous text.

After manually triggering the job via the UI, the output will look like:

![job-task-from-task](/images/job-task-from-task.png)

The in-progress or newly-completed `job-hello-world` job UI has three sections:

* Preparation for running the job - collecting inputs and dependencies
* `resource-tutorial` resource is fetched
* `hello-world` task is executed

The latter two are "steps" in the job's [build plan](http://concourse.ci/build-plans.html). A build plan is a sequence of steps to execute. These steps may fetch down or update Resources, or execute Tasks.

The first build plan step fetches down (note the down arrow to the left) a `git` repository for these training materials and tutorials. The pipeline named this resource `resource-tutorial`.

The `pipeline.yml` documents this single resource:

```yaml
resources:
- name: resource-tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git
    branch: develop
```

The resource name `resource-tutorial` is then used in the build plan for the job:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
```

Any fetched resource can now be an input to any task in the job build plan. As discussed in section 3 & section 4, task inputs can be used as task scripts.

The second step runs a user-defined task. The pipeline named the task `hello-world`. The task itself is not described in the pipeline. Instead it is described in a file `01_task_hello_world/task_hello_world.yml` from the `resource-tutorial` input.

The completed job looks like:

```yaml
jobs:
- name: job-hello-world
  public: true
  plan:
  - get: resource-tutorial
  - task: hello-world
    file: resource-tutorial/01_task_hello_world/task_hello_world.yml
```

The task `{task: hello-world, file: resource-tutorial/...}` has access to all fetched resources (and later, to the outputs from tasks).

The name of resources, and later the name of task outputs, determines the name used to access them by other tasks (and later, by updated resources).

So, `hello-world` can access anything from `resource-tutorial` (this tutorial's `git` repository) under the `resource-tutorial/` path. Since the relative path of `task_hello_world.yml` task file inside this repo is `01_task_hello_world/task_hello_world.yml`, the `task: hello-world` references it by joining the two: `file: resource-tutorial/01_task_hello_world/task_hello_world.yml`


There is a benefit and a downside to abstracting tasks into YAML files outside of the pipeline.

One benefit is that the behavior of the task can be kept in sync with the primary input resource (for example, a software project with tasks for running tests, building binaries, etc).

One downside is that the `pipeline.yml` no longer explains exactly what commands will be invoked. Comprehension of pipeline behavior is potentially reduced.

But one benefit of extracting inline tasks into task files is that `pipeline.yml` files can get long and it can be hard to read and comprehend all the YAML. Instead, give tasks long names so that readers can understand what the purpose and expectation of the task is at a glance.

But one downside of extracting inline tasks into files is that `fly set-pipeline` is no longer the only step to updating a pipeline.

From now onwards, any change to your pipeline might require you to do one or both:

* `fly set-pipeline` to update Concourse on a change to the job build plan and/or input/output resources
* `git commit` and `git push` your primary resource that contains the task files and task scripts

If a pipeline is not performing new behaviour then it might be you skipped one of the two steps above.

