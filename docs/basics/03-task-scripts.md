# Task scripts

The `inputs` feature of a task allows us to pass in two types of inputs:

* requirements/dependencies to be processed/tested/compiled
* task scripts to be executed to perform complex behavior

A common pattern is for Concourse tasks to `run:` complex shell scripts rather than directly invoking commands as we did above (we ran `uname` command with arguments `-a`).

Let's refactor `01-task-hello-world/task_ubuntu_uname.yml` into a new task `03-task-scripts/task_show_uname.yml` with a separated task script `03-task-scripts/task_show_uname.sh`

```
cd ../03-task-scripts
fly -t tutorial e -c task_show_uname.yml
```

The former specifies the latter as its task script:

```yaml
run:
  path: ./03-task-scripts/task_show_uname.sh
```

_Where does the `./03-task-scripts/task_show_uname.sh` file come from?_

From section 2 we learned that we could pass `inputs` into the task. The task configuration `03-task-scripts/task_show_uname.yml` specifies one input:

```
inputs:
- name: 03-task-scripts
```

Since input `03-task-scripts` matches the current directory `03-task-scripts` we did not need to specify `fly execute -i 03-task-scripts=.`.

The current directory was uploaded to the Concourse task container and placed inside the `03-task-scripts` directory.

Therefore its file `task_show_uname.sh` is available within the Concourse task container at `03-task-scripts/task_show_uname.sh`.

The only further requirement is that `task_show_uname.sh` is an executable script.

