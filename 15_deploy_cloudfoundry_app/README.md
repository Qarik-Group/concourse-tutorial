# Deploying applications to Cloud Foundry

Whilst Concourse could be used to push applications to any remote system for deployment, it is particularly easy to deploy to a Cloud Foundry with the built-in [`cf` resource](https://github.com/concourse/cf-resource).

*NOTE*: - See later section on using and writing custom resources if you are deploying to a different target environment/platform, such as Herkou.

Add the following key/values to your `credentials.yml` file:

```yaml
cf-api: https://api.yourcf.com
cf-username: your@email.com
cf-password: yourpassword
cf-organization: yourcompany
cf-space: concourse-tutorial
```

You can now create the pipeline and unpause it.

```
cd ../15_deploy_cloudfoundry_app
fly sp -t tutorial -c pipeline.yml -p deploy-app -n -l ../credentials.yml
fly up -t tutorial -p deploy-app
```

## Bonus exercise

In this example the `manifest.yml` was pre-defined in the application git resource. This might not be the `cf` manifest that works best for you.

Insert an additional task step before the `put: resource-deploy-web-app` step that outputs an alternate `manifest.yml`. Then change `manifest: resource-web-app/manifest.yml` to this alternate.

For example, if your new task declares an output `- name: cf-manifest` and places a `manifest.yml` into it, then the final `put:` step will be:

```yaml
- put: resource-deploy-web-app
  params:
    manifest: cf-manifest/manifest.yml
    path: resource-web-app
```
