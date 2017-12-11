# Run units then deploy application

![test-and-cf-deploy](/images/test-and-cf-deploy.png)

In this section we combine three ideas into a more advanced job:

1. trigger the job anytime the application repo is changed
1. run the internal unit tests of the application
1. if successful, deploy the web application immediately

![test-deploy](http://cl.ly/283i2x2y0z2h/download/Image%202016-03-01%20at%2010.34.14%20am.png)

We have previously seen steps 1 and 2 in [section 10](https://github.com/starkandwayne/concourse-tutorial#10---using-resource-inputs-in-job-tasks) and step 3 in the previous [section 15](https://github.com/starkandwayne/concourse-tutorial/tree/master/15_deploy_cloudfoundry_app). We are now combining them into one pipeline.

To the `deploy-app` pipeline with the additional trigger and unit test steps:

```
cd tutorials/miscellaneous/run_tests_before_deploy
fly sp -t tutorial -c pipeline.yml -p deploy-app -n -l ../../../credentials.yml
```

For convenience to us both, we're reusing the same task files from section 10 to run the tests for the :

```yaml
- name: deploy-app
  public: true
  serial: true
  plan:
  - get: tutorial
  - get: app
    trigger: true
  - task: web-app-tests
    config:
      platform: linux

      image_resource:
        type: docker-image
        source: {repository: golang, tag: 1.6-alpine}

      inputs:
      - name: tutorial
      - name: app
        path: gopath/src/github.com/cloudfoundry-community/simple-go-web-app

      run:
        path: tutorial/tutorials/basic/10_job_inputs/task_run_tests.sh
  - put: deploy-web-app
    params:
      manifest: resource-app/manifest.yml
      path: app
```

## Required variables

![cf-push-expected-variables](/images/cf-push-expected-variables.png)

The example `pipeline.yml` in the lesson folder uses the `cf` resource for deploying the application via `put: resource-deploy-web-app`. You could use any resource (or a handcrafted task) to deploy your application instead.

The `cf` resource deploys an application to Cloud Foundry. From the `pipeline.yml` it is:

```
- name: deploy-web-app
  type: cf
  source:
    api: ((cf-api))
    username: ((cf-username))
    password: ((cf-password))
    organization: ((cf-organization))
    space: ((cf-space))
    skip_cert_check: true
```

As introduced earlier, the `((cf-api))` syntax is for late-binding variable, secret, or credential. This allows `pipeline.yml` to be generically useful and published in public. It also allows an operator to update variables in a central place and then all jobs will dynamically use the new variable values on demand.

Alternately, you can provide the variables using a local file.
