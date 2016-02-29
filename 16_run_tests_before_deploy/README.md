# Run units then deploy application

In this section we combine three ideas into a more advanced job:

1. trigger the job anytime the application repo is changed
1. run the internal unit tests of the application
1. if successful, deploy the web application immediately

We have previously seen steps 1 and 2 in [section 10](https://github.com/starkandwayne/concourse-tutorial#10---using-resource-inputs-in-job-tasks) and step 3 in the previous [section 15](https://github.com/starkandwayne/concourse-tutorial/tree/master/15_deploy_cloudfoundry_app). We are now combining them into one pipeline.

To the `deploy-app` pipeline with the additional trigger and unit test steps:

```
cd ../16_run_tests_before_deploy
fly sp -t tutorial -c pipeline.yml -p deploy-app -n -l ../credentials.yml
```
