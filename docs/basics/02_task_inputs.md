# Task inputs

In the previous section the only inputs to the task container were the `image` used. Base images, such as Docker images, are relatively static and relatively big, slow things to create. So Concourse supports `inputs` into tasks to pass in files/folders for processing.

Consider the working directory of a task that explicitly has no inputs:

```
cd ../02_task_inputs
fly -t tutorial e -c no_inputs.yml
```

The task runs `ls -al` to show the (empty) contents of the working folder inside the container:

```
running ls -al
total 8
drwxr-xr-x    2 root     root          4096 Feb 27 07:23 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:23 ..
```

In the example task `inputs_required.yml` we add a single input:

```yaml
inputs:
- name: some-important-input
```

When we try to execute the task:

```
fly -t tutorial e -c inputs_required.yml
```

It will fail:

```
error: missing required input `some-important-input`
```

Commonly if wanting to run `fly execute` we will want to pass in the local folder (`.`). Use `-i name=path` option to configure each of the required `inputs`:

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=.
```

Now the `fly execute` command will upload the `.` directory as an input to the container. It will be made available at the path `some-important-input`:

```
running ls -alR
.:
total 8
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 ..
drwxr-xr-x    1 501      20              64 Feb 27 07:27 some-important-input

./some-important-input:
total 12
drwxr-xr-x    1 501      20              64 Feb 27 07:27 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:27 ..
-rw-r--r--    1 501      20             112 Feb 27 07:30 input_parent_dir.yml
-rw-r--r--    1 501      20             118 Feb 27 07:27 inputs_required.yml
-rw-r--r--    1 501      20              79 Feb 27 07:18 no_inputs.yml
```

To pass in a different directory as an input, provide its absolute or relative path:

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=../01_task_hello_world
```

The `fly execute -i` option can be removed if the current directory is the same name as the required input.

The task `input_parent_dir.yml` contains an input `02_task_inputs` which is also the current directory. So the following command will work and return the same results as above:

```
fly -t tutorial e -c input_parent_dir.yml
```

