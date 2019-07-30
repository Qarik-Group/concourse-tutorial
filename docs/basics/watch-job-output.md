description: Use the fly CLI to watch the streaming output from a running job or a completed job.
image_path: /images/git-resource-in.png

# Watch Job Output in Terminal

It was very helpful that the `job-hello-world` [job build](http://127.0.0.1:8080/teams/main/pipelines/helloworld/jobs/job-hello-world/builds/1) included the terminal output from running `git` commands to clone the git repo and the output of the running `hello-world` task.

![git-resource-in](/images/git-resource-in.png)

You can also view this output from the terminal with `fly watch`:

```
fly -t tutorial watch -j hello-world/job-hello-world
```

The output will be similar to:

```
using version of resource found in cache
initializing
running echo hello world
hello world
succeeded
```

The `--build NUM` option allows you to see the output of a specific build number, rather than the latest build output.


You can see the results of recent builds across all pipelines with `fly builds`:

```
fly -t tutorial builds
```

The output will look like:

```
3   hello-world/job-hello-world    1      succeeded  2016-26@17:22:13+1000  2016-26@17:22:23+1000  10s
2   one-off                       n/a    succeeded  2016-26@17:15:02+1000  2016-26@17:16:36+1000  1m34s
1   one-off                       n/a    succeeded  2016-26@17:13:34+1000  2016-26@17:14:11+1000  37s
```

The `fly watch` command can also be a battery saver on your laptop. Hear me out: I've observed that watching jobs run in the Concourse Web UI uses a lot more battery power than running `fly watch` in a terminal. Your mileage may vary.
