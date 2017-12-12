# Basic pipeline

1% of tasks that Concourse runs are via `fly execute`. 99% of tasks that Concourse runs are within "pipelines".

```
cd ../04_basic_pipeline
fly -t tutorial set-pipeline -c pipeline.yml -p helloworld
```

It will display the concourse pipeline (or any changes) and request confirmation:

```yaml
jobs:
  job job-hello-world has been added:
    name: job-hello-world
    public: true
    plan:
    - task: hello-world
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: {repository: busybox}
        run:
          path: echo
          args:
          - hello world
```

You will be prompted to apply any configuration changes each time you run `fly set-pipeline` (or its alias `fly sp`)

```
apply configuration? [yN]:
```

Press `y`.

You should see:

```
pipeline created!
you can view your pipeline here: http://192.168.100.4:8080/teams/main/pipelines/helloworld

the pipeline is currently paused. to unpause, either:
  - run the unpause-pipeline command
  - click play next to the pipeline in the web ui
```

As suggested, un-pause a pipeline from the `fly` CLI:

```
fly -t tutorial unpause-pipeline -p helloworld
```

Next, as suggested, visit the web UI http://192.168.100.4:8080/teams/main/pipelines/helloworld.

Your first pipeline is unimpressive - a single job `job-hello-world` with no inputs from the left and no outputs to its right, no jobs feeding into it, nor jobs feeding from it. It is the most basic pipeline. The job is gray colour because it has never been run before.

Click on `job-hello-world` and then click on the large `+` in the top right corner. Your job will run.

![job](/images/02-job-hello-world.gif)

Clicking the top-left "Home" icon will show the status of our pipeline. The job `job-hello-world` is now green. This means that the last time the job ran it completed successfully.

