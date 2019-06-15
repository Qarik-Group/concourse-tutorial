description: The primary way that Concourse jobs will be triggered to run will be by resources changing. A 'git' repo has a new commit? Run a job to test it. A GitHub project cuts a new release? Run a job to pull down its attached files and do something with them.
image_path: /images/resource-trigger.png

# Triggering Jobs with Resources

The primary way that Concourse jobs will be triggered to run will be by resources changing. A `git` repo has a new commit? Run a job to test it. A GitHub project cuts a new release? Run a job to pull down its attached files and do something with them.

Triggering resources are defined the same as non-triggering resources, such as the `resource-tutorial` defined earlier.

The difference is in the job build plan where triggering is desired.

By default, including `get: my-resource` in a build plan does not trigger its job.

To mark a fetched resource as a trigger add `trigger: true`

```yaml
jobs:
- name: job-demo
  plan:
  - get: resource-tutorial
    trigger: true
```

In the above example the `job-demo` job would trigger anytime the remote `resource-tutorial` had a new version. For a `git` resource this would be new git commits.

The `time` resource has intrinsic purpose of triggering jobs.

If you want a job to trigger every few minutes then there is the [`time` resource](https://github.com/concourse/time-resource#readme).

```yaml
resources:
- name: my-timer
  type: time
  source:
    interval: 2m
```

Now upgrade the `hello-world` pipeline with the `time` trigger and unpause it.

```
cd ../triggers
fly sp -t tutorial -c pipeline.yml -p hello-world
fly up -t tutorial -p hello-world
```

This adds a new resource named `my-timer` which triggers `job-hello-world` approximately every 2 minutes.

Visit the pipeline dashboard http://127.0.0.1:8080/teams/main/pipelines/hello-world and wait a few minutes and eventually the job will start running automatically.

![resource-trigger](/images/resource-trigger.png)

The dashboard UI makes non-triggering resources distinct with a hyphenated line connecting them into the job. Triggering resources have a full line.

Why does `time` resource configured with `interval: 2m` trigger "approximately" every 2 minutes?

> "resources are checked every minute, but there's a shorter (10sec) interval for determining when a build should run; time resource is to just ensure a build runs on some rough periodicity; we use it to e.g. continuously run integration/acceptance tests to weed out flakiness" - alex

The net result is that a timer of `2m` will trigger every 2 to 3 minutes.

