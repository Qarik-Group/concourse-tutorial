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

## Join Concourse CI Slack organization!

Now seems like a great time to mention the Concourse CI Slack organization!

Visit http://slack.concourse.ci/ to sign up.

## Slack Web Hooks

Visit the `/services/new/incoming-webhook` for your Slack organization. For example, for `concourseci` organization:

https://concourseci.slack.com/services/new/incoming-webhook/

Choose a public or private channel into which your notifications will be delivered. For this tutorial, choose your own personal channel "Privately to you".

![slack-webhook-private](/images/slack-webhook-private.png)

Click "Add Incoming WebHooks integration" button.

On the next page, you will be given a unique secret URL. Triple click to select, then copy it to your clipboard.

![slack-webhook-url](/images/slack-webhook-url.png)

Each pipeline might have its own `((slack-webhook))` parameter to send notifications to different Slack channels. So we will store the URL in a pipeline-specific location in Credhub (remember to run `bucc credhub` in your `bucc` project to re-login to Credhub):

```
credhub set -n /concourse/main/slack_notifications/slack-webhook -t value -v https://hooks.slack.com/services/T02FXXXXX/B8FLXXXXX/vfnkP8lwogK0uYDZCxxxxxxx
```

## Notification on Job Failure

If you haven't already, add to your `pipeline.yml` the `resource_types` section and additional `resources` section introduced in [Custom Resource Types](#custom-resource-types) above.

Next, we need to introduce the `on_failure` section of all build plan steps.

Any `get`, `put`, or `task` step of a build plan can catch failures and do something interesting. From the [Concourse CI documentation](https://concourse.ci/on-failure-step.html):

```yaml
plan:
- get: foo
- task: unit
  file: foo/unit.yml
  on_failure:
    task: alert
    file: foo/alert.yml
```

In our pipeline, we will add `on_failure` to our `task: test-sometimes-works`:

```yaml
  - task: test-sometimes-works
    config:
      ...
      run:
        path: tutorial/tutorials/miscellaneous/slack_notifications/test-sometimes-works.sh
    on_failure:
      put: notify
      params:
        text: "Job 'test' failed"
```

We use the `on_failure` to invoke the `slack-notification` resource named `notify` which will send a message to our `((slack-webhook))` web hook.

Update your pipeline and trigger the `test` job until you get a failure:

```
fly -t bucc sp -p slack_notifications -c pipeline-slack-failures.yml
fly -t bucc trigger-job -j slack_notifications/test -w
```

Your lovely failure will now appear as a notification in Slack:

![slack-webhook-test-failed](/images/slack-webhook-test-failed.png)

## Dynamic Notification Messages

In the preceding section the notification text was hardcoded within the `pipeline-slack-failures.yml` file. It is possible to generate dynamic messages for your notifications.

It is also possible to emit success notifications.

![slack-webhook-dynamic-messages](/images/slack-webhook-dynamic-messages.png)

From the README of the `slack-notification-resource` being used, we can see there is a `text` and a `text_file` parameter https://github.com/cloudfoundry-community/slack-notification-resource#out-sends-message-to-slack

We will switch from the former to the latter, and add an `on_success` step hook to explicit catch both success and failure outcomes of the `task: test-sometimes-works` step.

```yaml
jobs:
- name: test
  public: true
  serial: true
  plan:
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
      outputs:
      - name: notify_message
      run:
        path: tutorial/tutorials/miscellaneous/slack_notifications/test-sometimes-works-notify-message.sh
    on_success:
      put: notify
      params:
        text_file: notify_message/message
    on_failure:
      put: notify
      params:
        text_file: notify_message/message
```

Above, the `notify_message` folder is created by the `task: test-sometimes-works` step as an output, and consumed by `put: notify` resource. See the Basics section on [Passing task outputs to another task](/basics/11_task_outputs_to_inputs/) to revise this topic.

To upgrade your pipeline and run the `test` job a few times to see success and failure notifications:

```
fly -t bucc sp -p slack_notifications -c pipeline-dynamic-messages.yml
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
fly -t bucc trigger-job -j slack_notifications/test -w
```

