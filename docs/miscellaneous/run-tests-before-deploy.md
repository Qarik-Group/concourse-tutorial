# Run Tests Then Deploy

![test-and-cf-deploy](/images/test-and-cf-deploy.png)

In this section we combine four ideas into a more advanced job:

1. trigger the job anytime the application repo is changed
1. run the internal unit tests of the application
1. if successful, deploy the web application immediately
1. use secret parameters for the target deployment platform

The resulting pipeline is a combination of the preceding lessons:

* [Triggers](/basics/triggers/)
* [Job Inputs](/basics/job-inputs/)
* [Outputs to Inputs](/basics/task-outputs-to-inputs/)
* [Secrets with Credentials Manager](/basics/secret-parameters/)

In the lesson we will deploy a sample Golang application to a Cloud Foundry platform. In your own Concourse pipelines you could deploy any application to any target platform.

For convenience, we're reusing the `tutorials/basic/job-inputs/task-run-tests.sh` test script from lesson [Job Inputs](/basics/job-inputs/).

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
        source: {repository: golang, tag: 1.9-alpine}

      inputs:
      - name: tutorial
      - name: app
        path: gopath/src/github.com/cloudfoundry-community/simple-go-web-app

      run:
        path: tutorial/tutorials/basic/job-inputs/task-run-tests.sh
  - put: deploy-web-app
    params:
      manifest: resource-app/manifest.yml
      path: app
```

To deploy the `run-tests-before-deploy` pipeline, and trigger/watch the job:

```
cd tutorials/miscellaneous/run-tests-before-deploy
fly -t bucc set-pipeline -p run-tests-before-deploy -c pipeline.yml
fly -t bucc unpause-pipeline -p run-tests-before-deploy
fly -t bucc trigger-job -j run-tests-before-deploy/deploy-app -w
```

This will fail due to missing parameters.

## Free Cloud Foundry for Lesson

To complete this lesson you will need access to a Cloud Foundry. I'd like to suggest you try [Pivotal Web Services](https://run.pivotal.io/) which is run by Pivotal, the company who funds the core Concourse CI dev team. They offer free trial credit which will be more than sufficient for this lesson.

After signup, visit https://console.run.pivotal.io/, and after navigating to your "org", create a new "space" called `run-tests-before-deploy`. This lesson's pipeline will deploy a sample app into this space.

The sample application being deployed by the pipeline is https://github.com/cloudfoundry-community/simple-go-web-app

## Required Parameters

![cf-push-expected-variables](/images/cf-push-expected-variables.png)

The example `pipeline.yml` in the lesson folder uses the `cf` resource for deploying the application via `put: deploy-web-app`. You could use any resource (or a handcrafted task) to deploy your application instead. Declarative deployment platforms like Cloud Foundry and Kubernetes can trivialise our pipeline implementation. They are the "Just Do It" of CI/CD deployment orchestration.

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
    skip-cert-check: true
```

As introduced in [Parameters](/basics/parameters/) and [Secrets with Credentials Manager](/basics/secret-parameters/)
, the `((cf-api))` syntax is for late-binding variable, secret, or credential. This allows `pipeline.yml` to be generically useful and published in public. It also allows an operator to update variables in a central place and then all jobs will dynamically use the new variable values on demand.

It is likely that `cf-api`, `cf-username`, `cf-password`, and `cf-organization` are common credentials for many pipelines, but `cf-space` might be specific to this pipeline. Example `credhub set` commands might be:

```
credhub set -n /concourse/main/cf-api          -t value -v https://api.run.pivotal.io
credhub set -n /concourse/main/cf-username     -t value -v drnic+ci@starkandwayne
credhub set -n /concourse/main/cf-password     -t value -v secret-password
credhub set -n /concourse/main/cf-organization -t value -v starkandwayne

credhub set -n /concourse/main/run-tests-before-deploy/cf-space -t value -v run-tests-before-deploy
```

Once you've set your parameters in your Concourse credentials manager, or re-run `fly set-pipeline` to pass them in as variables, you can re-trigger the job:

```
fly -t bucc trigger-job -j run-tests-before-deploy/deploy-app -w
```

## Cleanup

You can now delete the sample app from your Cloud Foundry account.

If you are using Pivotal Web Services, visit https://console.run.pivotal.io/ and navigate to the `run-tests-before-deploy` space to find your application and delete it.
