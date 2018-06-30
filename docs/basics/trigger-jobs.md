description: Review the four ways to trigger a job.

# Trigger Jobs

There are four ways for a job to be triggered:

* Clicking the `+` button on the web UI of a job (as we did in previous sections)
* Input resource triggering a job (see the next lesson [Triggering Jobs with Resources](/basics/triggers/))
* `fly trigger-job -j pipeline/jobname` command
* Sending `POST` HTTP request to Concourse API

We can re-trigger our `hello-world` pipeline's `job-hello-world`:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world
```

Whilst the job is running, and after it has completed, you can then watch the output in your terminal using `fly watch`:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

Alternately, you can combine the two commands - trigger the job and watch the output with the `trigger-job -w` flag:

```
fly -t tutorial trigger-job -j hello-world/job-hello-world -w
```

In the next lesson we will learn to trigger jobs after changes to an input resource.
