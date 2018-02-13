description: Finally, it is time to make an actual pipeline - one job passing results to another job upon success.
image_path: /images/pipeline.png

# Actual Pipeline - Passing Resources Between Jobs

Finally, it is time to make an actual pipeline - one job passing results to another job upon success.

In all previous sections our pipelines have only had a single job. For all their wonderfulness, they haven't yet felt like actual pipelines. Jobs passing results between jobs. This is where Concourse shines even brighter.

Update the `publishing-outputs` pipeline with a second job `job-show-date` which will run whenever the first job successfully completes:

```yaml
- name: job-show-date
  plan:
  - get: resource-tutorial
  - get: resource-gist
    passed: [job-bump-date]
    trigger: true
  - task: show-date
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      inputs:
        - name: resource-gist
      run:
        path: cat
        args: [resource-gist/bumpme]
```

Update the pipeline:

```
cd ../pipeline-jobs
fly -t tutorial sp -p publishing-outputs -c pipeline.yml -l ../publishing-outputs/credentials.yml
fly -t tutorial trigger-job -w -j publishing-outputs/job-bump-date
```

If you are missing `../publishing-outputs/credentials.yml`, visit the section [Revisiting Publishing Outputs](/basics/parameters/#revisting-publishing-outputs) from the previous lesson.

The dashboard UI displays the additional job and its trigger/non-trigger resources. Importantly, it shows our first multi-job pipeline:

![pipeline](/images/pipeline.png)

The latest `resource-gist` commit fetched down in `job-show-date` will be the exact commit used in the last successful `job-bump-date` job. If you manually created a new git commit in your gist and manually ran the `job-show-date` job it would continue to use the previous commit it used, and ignore your new commit. *This is the power of pipelines.*

![trigger](/images/trigger.png)

