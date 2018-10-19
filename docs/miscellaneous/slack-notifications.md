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
          path: tutorial/tutorials/miscellaneous/slack-notifications/test-sometimes-works.sh
```

Create this pipeline and run the `test` job a few times. Sometimes it will succeed and other times it will fail.

```
cd tutorials/miscellaneous/slack-notifications
fly -t bucc sp -p slack-notifications -c pipeline-no-notifications.yml
fly -t bucc up -p slack-notifications
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
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

## Join a Slack organization

You want to send slack notifications. First you'll need to create an organization or be invited.

In the examples below I will use the defunct `https://concourseci.slack.com` organization. Update `concourseci` to your organization.

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
credhub set -n /concourse/main/slack-notifications/slack-webhook -t value -v https://hooks.slack.com/services/T02FXXXXX/B8FLXXXXX/vfnkP8lwogK0uYDZCxxxxxxx
```

## Notification on Job Failure

If you haven't already, add to your `pipeline.yml` the `resource_types` section and additional `resources` section introduced in [Custom Resource Types](#custom-resource-types) above.

Next, we need to introduce the `on_failure` section of all build plan steps.

Any `get`, `put`, or `task` step of a build plan can catch failures and do something interesting. From the [Concourse CI documentation](https://concourse-ci.org/on-failure-step-hook.html):

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
        path: tutorial/tutorials/miscellaneous/slack-notifications/test-sometimes-works.sh
    on_failure:
      put: notify
      params:
        text: "Job 'test' failed"
```

We use the `on_failure` to invoke the `slack-notification` resource named `notify` which will send a message to our `((slack-webhook))` web hook.

Update your pipeline and trigger the `test` job until you get a failure:

```
fly -t bucc sp -p slack-notifications -c pipeline-slack-failures.yml
fly -t bucc trigger-job -j slack-notifications/test -w
```

Your lovely failure will now appear as a notification in Slack:

![slack-webhook-test-failed](/images/slack-webhook-test-failed.png)

## Dynamic Notification Messages

In the preceding section the notification text was hardcoded within the `pipeline-slack-failures.yml` file. It is possible to generate dynamic messages for your notifications.

It is also possible to emit success notifications.

In the example below there are two notifications (Slack combines messages from the same sender to save space). Each message contains information that is dynamically 

![slack-webhook-dynamic-messages](/images/slack-webhook-dynamic-messages.png)

From the README of the `slack-notification-resource` being used, we can see there is a `text` and a `text_file` parameter https://github.com/cloudfoundry-community/slack-notification-resource#out-sends-message-to-slack

* `text`: Static text of the message to send.
* `text_file`: File that contains the message to send. This allows the message to be generated by a previous task step in the Concourse job.

We will switch from `text` to `text_file`.

We will also add an `on_success` step hook to explicitly catch both success and failure outcomes of the `task: test-sometimes-works` step and display a message.

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
        path: tutorial/tutorials/miscellaneous/slack-notifications/test-sometimes-works-notify-message.sh
    on_success:
      put: notify
      params:
        text_file: notify_message/message
    on_failure:
      put: notify
      params:
        text_file: notify_message/message
```

Above, the `notify-message` folder is created by the `task: test-sometimes-works` step as an output, and consumed by `put: notify` resource. See the Basics section on [Passing task outputs to another task](/basics/task-outputs-to-inputs/) to revise this topic.

The `task: test-sometimes-works` step runs the `test-sometimes-works-notify-message.sh` script, which is the same as `test-sometimes-works.sh` but also creates a file `notify_message/message`.

```bash
value=$RANDOM
if [[ $value -gt 16384 ]]; then
  cat > notify_message/message <<EOF
Unfortunately the \`test\` job failed. The random value $value needed to be less than 16384 to succeed.
EOF
  exit 1
else
  cat > notify_message/message <<EOF
Hurray! The \`test\` job succeeded. The random value $value needed to be less than 16384 to succeed.
EOF
  exit 0
fi
```

On failure, the message will start with "Unfortunately...". On success, the message will start with "Harray!".

![slack-webhook-dynamic-messages](/images/slack-webhook-dynamic-messages.png)

Visit https://api.slack.com/incoming-webhooks to learn more about contents of Slack messages.

To upgrade your pipeline and run the `test` job a few times to see success and failure notifications:

```
fly -t bucc sp -p slack-notifications -c pipeline-dynamic-messages.yml
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
```

## Custom Slack Message Metadata

Our Slack notifications above are pretty bland:

![slack-webhook-dynamic-messages](/images/slack-webhook-dynamic-messages.png)

Let's spice them up with custom image and username:

![slack-webhook-custom-metadata](/images/slack-webhook-custom-metadata.png)

Also, we can condense the `on_success` and `on_failure` sections into a shared `ensure` block:

```yaml
  - task: test-sometimes-works
    ...
    ensure:
      put: notify
      params:
        username:  starkandwayne-ci
        icon_url:  https://www.starkandwayne.com/assets/images/shield-blue-50x50.png
        text_file: notify_message/message
```

To upgrade your pipeline and run the `test` job a few times to see success and failure notifications:

```
fly -t bucc sp -p slack-notifications -c pipeline-custom-metadata.yml
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
fly -t bucc trigger-job -j slack-notifications/test -w
```

