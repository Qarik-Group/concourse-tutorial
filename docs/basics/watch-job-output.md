# View job output in terminal

The `job-hello-world` had terminal output from its resource fetch of a git repo and of the `hello-world` task running.

In addition to the Concourse web ui you can also view this output from the terminal with `fly`:

```
fly -t tutorial watch -j helloworld/job-hello-world
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
5   helloworld/job-hello-world    1      succeeded  2016-26@17:25:47+1000  2016-26@17:26:01+1000  14s
4   helloworld/job-hello-world    1      succeeded  2016-26@17:24:43+1000  2016-26@17:25:02+1000  19s
3   helloworld/job-hello-world    1      succeeded  2016-26@17:22:13+1000  2016-26@17:22:23+1000  10s
2   one-off                       n/a    succeeded  2016-26@17:15:02+1000  2016-26@17:16:36+1000  1m34s
1   one-off                       n/a    succeeded  2016-26@17:13:34+1000  2016-26@17:14:11+1000  37s
```

