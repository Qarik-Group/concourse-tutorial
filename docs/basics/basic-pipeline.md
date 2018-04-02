description: Our first look at a 'hello world' Concourse pipeline.
image_path: /images/job-hello-world.gif

# Basic Pipeline

1% of tasks that Concourse runs are via `fly execute`. 99% of tasks that Concourse runs are within "pipelines".

```
cd ../basic-pipeline
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
you can view your pipeline here: http://127.0.0.1:8080/teams/main/pipelines/helloworld

the pipeline is currently paused. to unpause, either:
  - run the unpause-pipeline command
  - click play next to the pipeline in the web ui
```

## Login to Concourse Web UI

Visit the pipeline URL http://127.0.0.1:8080/teams/main/pipelines/helloworld

It is a private pipeline and currently you are not logged in to the Concourse Web UI. You will be redirected to a login page.

![dashboard-login](/images/dashboard-login.png)

Click "Login" and you'll be redirected back to your pipeline.

Why did you not have to enter any username/password? Excellent question, indeed. It's because your current `fly -t tutorial` deployment of Concourse has had authentication disabled. In a future lesson we will upgrade to a more robust installation of Concourse with passwords and fanciness.

## Unpausing Pipelines

Your pipeline has a blue bar across the top. This means it is paused. New pipelines start paused as you might not yet be ready for triggers to fire and start jobs running.

![dashboard-pipeline-paused](/images/dashboard-pipeline-paused.png)

There are two ways to unpause (or re-pause) a pipeline.

1. Open the hamburger menu and click the `>` unpause/play button for your pipeline. Then click the hamburger menu icon to close the sidebar of pipelines.

    ![dashboard-hamburger-menu](/images/dashboard-hamburger-menu.png)

    

2. Using the `fly unpause-pipeline` command (or its alias `fly up`):

    ```
    fly -t tutorial unpause-pipeline -p helloworld
    ```

## First Pipeline

This first pipeline is unimpressive - a single job `job-hello-world` with no inputs from the left and no outputs to its right, no jobs feeding into it, nor jobs feeding from it. It is the most basic pipeline. The job is gray colour because it has never been run before.

Click on `job-hello-world` and then click on the large `+` in the top right corner. Your job will run.

![job](/images/job-hello-world.gif)

Clicking the top-left "Home" icon will show the status of our pipeline. The job `job-hello-world` is now green. This means that the last time the job ran it completed successfully.

Note: this animated gif has aged slightly. The current Concourse Web UI looks slightly different.