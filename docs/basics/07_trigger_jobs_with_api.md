# Trigger jobs with the Concourse API

There are four ways for a job to be triggered:

* Clicking the `+` button on the web UI of a job (as we did in previous sections)
* Input resource triggering a job (see section 8 below)
* `fly trigger-job -j pipeline/jobname` command
* Sending `POST` HTTP request to Concourse API

Currently our Concourse in Vagrant has an API running at `http://192.168.100.4:8080`. If you do not remember the API endpoint it might be stored in the `~/.flyrc` file.

We can trigger a job to be run using that API. For example, using `curl`:

```
fly -t tutorial trigger-job -j helloworld/jobs/job-hello-world
```

Whilst the job is running, and after it has completed, you can then watch the output in your terminal using `fly watch`:

```
fly -t tutorial watch -j helloworld/job-hello-world
```

