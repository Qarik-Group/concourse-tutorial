description: Concourse supports 'inputs' into tasks to pass in files/folders for processing.

# Task Inputs

In the previous section the only inputs to the task container were the `image` used. Base images, such as Docker images, are relatively static and relatively big, slow things to create. So Concourse supports `inputs` into tasks to pass in files/folders for processing.

Consider the working directory of a task that explicitly has no inputs:

```
cd ../task-inputs
fly -t tutorial e -c no_inputs.yml
```

The task runs `ls -al` to show the (empty) contents of the working folder inside the container:

```
running ls -al
total 8
drwxr-xr-x    2 root     root          4096 Feb 27 07:23 .
drwxr-xr-x    3 root     root          4096 Feb 27 07:23 ..
```

Note that above we used the short-hand form of the execute command in this example, simply **e**, as the action. Many commands have shortened single character forms, for example **fly s** is an alias for **fly sync**.

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
total 12
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 .
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 ..
drwxr-xr-x    1 root     root          4096 Dec 18 02:35 some-important-input

./some-important-input:
total 24
drwxr-xr-x    1 root     root          4096 Dec 18 02:35 .
drwxr-xr-x    3 root     root          4096 Dec 18 02:35 ..
-rw-r--r--    1 501      20             156 Dec  9 22:26 input_parent_dir.yml
-rw-r--r--    1 501      20             162 Dec  9 22:26 inputs_required.yml
-rw-r--r--    1 501      20             123 Dec  9 22:26 no_inputs.yml
-rwxr-xr-x    1 501      20             522 Dec 17 21:31 test.sh
```

To pass in a different directory as an input, provide its absolute or relative path:

```
fly -t tutorial e -c inputs_required.yml -i some-important-input=../task-hello-world
```

The `fly execute -i` option can be removed if the current directory is the same name as the required input.

The task `input_parent_dir.yml` contains an input `task-inputs` which is also the current directory. All the contents in the directory `./task-inputs` will be uploaded to the docker image. So the following command will work and return the same results as above:

```
fly -t tutorial e -c input_parent_dir.yml
```

