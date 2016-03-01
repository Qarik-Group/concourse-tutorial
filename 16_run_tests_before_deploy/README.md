# Run units then deploy application

In this section we combine three ideas into a more advanced job:

1. trigger the job anytime the application repo is changed
1. run the internal unit tests of the application
1. if successful, deploy the web application immediately

![test-deploy](http://cl.ly/283i2x2y0z2h/download/Image%202016-03-01%20at%2010.34.14%20am.png)

We have previously seen steps 1 and 2 in [section 10](https://github.com/starkandwayne/concourse-tutorial#10---using-resource-inputs-in-job-tasks) and step 3 in the previous [section 15](https://github.com/starkandwayne/concourse-tutorial/tree/master/15_deploy_cloudfoundry_app). We are now combining them into one pipeline.

To the `deploy-app` pipeline with the additional trigger and unit test steps:

```
cd ../16_run_tests_before_deploy
fly sp -t tutorial -c pipeline.yml -p deploy-app -n -l ../credentials.yml
```

For convenience to us both, we're reusing the same task files from section 10 to run the tests for the :

```yaml
- name: job-deploy-app
  public: true
  serial: true
  plan:
  - get: resource-tutorial
  - get: resource-app
    trigger: true
  - task: web-app-tests
    file: resource-tutorial/10_job_inputs/task_run_tests.yml
  - put: resource-deploy-web-app
    params:
      manifest: resource-app/manifest.yml
      path: resource-app
```
