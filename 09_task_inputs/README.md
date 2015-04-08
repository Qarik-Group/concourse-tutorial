Task inputs
===========

The pipelines in this tutorial show a task that imports resources and how it can access the files from those resources.

http://concourse.ci/build-plans.html

```
$ ./run.sh simple-ls
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

```
$ ./run.sh pretty-ls
...
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
```
