# Actual pipeline - passing resources between jobs

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
fly sp -t tutorial -c pipeline.yml -p publishing-outputs -n
```

The dashboard UI displays the additional job and its trigger/non-trigger resources. Importantly, it shows our first pipeline:

![pipeline](http://cl.ly/3y0i0Z2v2b2F/download/Image%202016-02-28%20at%209.09.14%20pm.png)

The latest `resource-gist` commit fetched down in `job-show-date` will be the exact commit used in the last successful `job-bump-date` job. If you manually created a new git commit in your gist and manually ran the `job-show-date` job it would continue to use the previous commit it used, and ignore your new commit. *This is the power of pipelines.*

![trigger](http://cl.ly/3x1t0T450g1h/download/pipeline-flow.gif)

