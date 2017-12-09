# Task scripts

The `inputs` feature of a task allows us to pass in two types of inputs:

* requirements/dependencies to be processed/tested/compiled
* task scripts to be executed to perform complex behavior

A common pattern is for Concourse tasks to `run:` complex shell scripts rather than directly invoking commands as we did above (we ran `uname` command with arguments `-a`).

Let's refactor `01_task_hello_world/task_ubuntu_uname.yml` into a new task `03_task_scripts/task_show_uname.yml` with a separated task script `03_task_scripts/task_show_uname.sh`

```
cd ../03_task_scripts
fly -t tutorial e -c task_show_uname.yml
```

The former specifies the latter as its task script:

```yaml
run:
  path: ./03_task_scripts/task_show_uname.sh
```

_Where does the `./03_task_scripts/task_show_uname.sh` file come from?_

From section 2 we learned that we could pass `inputs` into the task. The task configuration `03_task_scripts/task_show_uname.yml` specifies one input:

```
inputs:
- name: 03_task_scripts
```

Since input `03_task_scripts` matches the current directory `03_task_scripts` we did not need to specify `fly execute -i 03_task_scripts=.`.

The current directory was uploaded to the Concourse task container and placed inside the `03_task_scripts` directory.

Therefore its file `task_show_uname.sh` is available within the Concourse task container at `03_task_scripts/task_show_uname.sh`.

The only further requirement is that `task_show_uname.sh` is an executable script.

