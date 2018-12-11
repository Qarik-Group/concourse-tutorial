description: Task scripts are typically passed in from one of the inputs.

# Task Scripts

The `inputs` feature of a task allows us to pass in two types of inputs:

* requirements/dependencies to be processed/tested/compiled
* task scripts to be executed to perform complex behavior

A common pattern is for Concourse tasks to `run:` complex shell scripts rather than directly invoking commands as we did in the [Hello World tutorial](/basics/task-hello-world/#task-docker-images) (we ran `uname` command with arguments `-a`).

Let's refactor `task-hello-world/task_ubuntu_uname.yml` into a new task `task-scripts/task_show_uname.yml` with a separated task script `task-scripts/task_show_uname.sh`

```
cd ../task-scripts
fly -t tutorial e -c task_show_uname.yml
```

The former specifies the latter as its task script:

```yaml
run:
  path: ./task-scripts/task_show_uname.sh
```

_Where does the `./task-scripts/task_show_uname.sh` file come from?_

From section 2 we learned that we could pass `inputs` into the task. The task configuration `task-scripts/task_show_uname.yml` specifies one input:

```
inputs:
- name: task-scripts
```

Since input `task-scripts` matches the current directory `task-scripts` we did not need to specify `fly execute -i task-scripts=.`.

The current directory was uploaded to the Concourse task container and placed inside the `task-scripts` directory.

Therefore its file `task_show_uname.sh` is available within the Concourse task container at `task-scripts/task_show_uname.sh`.

The only further requirement is that `task_show_uname.sh` is an executable script.

