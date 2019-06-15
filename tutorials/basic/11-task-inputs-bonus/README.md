Task inputs
===========

The pipelines in this tutorial show a task that imports resources and how it can access the files from those resources.

http://concourse-ci.org/builds.html

```
$ ./run.sh ls-abc-xyz
...
running ls -opR .
.:
total 8
drwxr-xr-x 3 vcap 4096 Apr  8 04:52 gist-abc/
drwxr-xr-x 3 vcap 4096 Apr  8 04:53 gist-xyz/

./gist-abc:
total 12
-rw-r--r-- 1 vcap 8 Apr  8 04:52 a.md
-rw-r--r-- 1 vcap 8 Apr  8 04:52 b.md
-rw-r--r-- 1 vcap 8 Apr  8 04:52 c.md

./gist-xyz:
total 12
-rw-r--r-- 1 vcap 8 Apr  8 04:53 x.md
-rw-r--r-- 1 vcap 8 Apr  8 04:53 y.md
-rw-r--r-- 1 vcap 8 Apr  8 04:53 z.md
```

The job `job-with-inputs` has a build plan that:

-	pulls in (`get`s) two resources (`type: git`) and
-	they are made available to the task `ls-abc-xyz`.

The two `get` resources are described:

```yaml
- { get: gist-abc, resource: resource-gist-a-b-c }
- { get: gist-xyz, resource: resource-gist-x-y-z }
```

They come from resources `resource-gist-a-b-c` and `resource-gist-x-y-z`; and are renamed `gist-abc` and `gist-xyz` respectively (their name within this particular job build plan).

The purpose of the `ls-abc-xyz` task is to show how the resources `resource-gist-a-b-c` and `resource-gist-x-y-z` are passed through to subsequent steps.

Looking at the output above you can see that the content of each resource are nested inside subfolders of the renamed build plan resources (`gist-abc` and `gist-xyz`).

### Explicit task inputs

The task `ls-abc-xyz` declares explicitly that it wants both resources via its `inputs` configuration:

```yaml
- task: ls-abc-xyz
  config:
    platform: linux
    image_resource:
      type: docker-image
      source: {repository: ubuntu}
    inputs:
    - name: gist-abc
    - name: gist-xyz
    run:
      path: ls
      args: ["-opR", "."]
```

The `ls-abc-xyz` task explicitly shows that it has access to the files from the two resources (see output above). The files are in the root of the fetched repositories; but during the build plan they are now nested beneath a folder.

We can demonstrate that a task only has access to resource inputs that it specifies by removing `gist-xyz` from the list of `inputs` above.

```
$ run.sh ls-abc
...
initializing
running ls -opR .
.:
total 4
drwxr-xr-x 3 vcap 4096 Apr  8 05:17 gist-abc/

./gist-abc:
total 12
-rw-r--r-- 1 vcap 8 Apr  8 05:17 a.md
-rw-r--r-- 1 vcap 8 Apr  8 05:17 b.md
-rw-r--r-- 1 vcap 8 Apr  8 05:17 c.md
```

Bonus - pretty print via resource script
----------------------------------------

```
$ ./run.sh pretty-ls
...
initializing
running bash pretty-ls/pretty_ls.sh .
./gist-abc
./gist-xyz
./pretty-ls
./gist-abc/a.md
./gist-abc/b.md
./gist-abc/c.md
./gist-xyz/x.md
./gist-xyz/y.md
./gist-xyz/z.md
./pretty-ls/pretty_ls.sh
initializing
running bash pretty-ls/pretty_ls.sh .
./gist-xyz
./pretty-ls
./gist-xyz/x.md
./gist-xyz/y.md
./gist-xyz/z.md
./pretty-ls/pretty_ls.sh
```
