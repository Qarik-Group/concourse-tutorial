# Trigger Jobs

There are four ways for a job to be triggered:

* Clicking the `+` button on the web UI of a job (as we did in previous sections)
* Input resource triggering a job (see section 8 below)
* `fly trigger-job -j pipeline/jobname` command
* Sending `POST` HTTP request to Concourse API


We can re-trigger our `helloworld` pipeline's `job-hello-world`:

```
fly -t tutorial trigger-job -j helloworld/job-hello-world
```

Whilst the job is running, and after it has completed, you can then watch the output in your terminal using `fly watch`:

```
fly -t tutorial watch -j helloworld/job-hello-world
```

Alternately, you can combine the two commands - trigger the job and watch the output with the `trigger-job -w` flag:

```
fly -t tutorial trigger-job -j helloworld/job-hello-world -w
```
