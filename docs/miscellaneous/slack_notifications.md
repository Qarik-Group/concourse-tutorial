# Slack Notifications

If a test fails in the woods and no one is there to see it turn red, did it really fail?

![test-sometimes-works](/images/test-sometimes-works.png)

Whilst your jobs can automatically trigger without a human, it isn't often helpful for them to fail without a human being notified. If you use [Slack](https://slack.com), or a different chat room where your team hangs out, then I suggest having your pipeline inform you of failures or successes.

Consider a job that quietly fails 50% of the time but doesn't notify anyone.

```yaml
resources:
- name: tutorial
  type: git
  source:
    uri: https://github.com/starkandwayne/concourse-tutorial.git
    branch: develop

jobs:
- name: test
  public: true
  serial: true
  plan:
  - do:
    - get: tutorial
      trigger: true
    - task: test-sometimes-works
      config:
        platform: linux
        image_resource:
          type: docker-image
          source: {repository: busybox}
        inputs:
        - name: tutorial
        run:
          path: tutorial/tutorials/miscellaneous/slack_notifications/test-sometimes-works.sh
```

Create this pipeline and run the `test` job a few times. Sometimes it will succeed and other times it will fail.

```
fly -t bucc sp -p slack_notifications -c pipeline-no-notifications.yml
fly -t bucc up -p slack_notifications
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
```

## Custom Resource Types

Specifically for Slack there is a custom Resource Type `cfcommunity/slack-notification-resource` ([see source on Github](https://github.com/cloudfoundry-community/slack-notification-resource)). We can add any custom Resource Types to our `pipeline.yml` with the top-level `resource_types`.

```yaml
resource_types:
- name: slack-notification
  type: docker-image
  source:
    repository: cfcommunity/slack-notification-resource
```


```yaml
resources:
- name: notify
  type: slack-notification
  source:
    url: ((slack-webhook))
```

## Slack Web Hooks

Visit the `/services/new/incoming-webhook` for your Slack organization. For example, for `cloudfoundry` organization:

https://cloudfoundry.slack.com/services/new/incoming-webhook/

Choose a public or private channel into which your notifications will be delivered. For this tutorial, choose your own personal channel "Privately to you".

![slack-webhook-private](/images/slack-webhook-private.png)

Click "Add Incoming WebHooks integration" button.

On the next page, you will be given a unique secret URL. Triple click to select, then copy it to your clipboard.

![slack-webhook-url](/images/slack-webhook-url.png)

Each pipeline might have its own `((slack-webhook))` parameter to send notifications to different Slack channels. So we will store the URL in a pipeline-specific location in Credhub (remember to run `bucc credhub` in your `bucc` project to re-login to Credhub):

```
credhub set -n /concourse/main/slack_notifications/slack-webhook -t value -v https://hooks.slack.com/services/T02FXXXXX/B8FLXXXXX/vfnkP8lwogK0uYDZCxxxxxxx
```

