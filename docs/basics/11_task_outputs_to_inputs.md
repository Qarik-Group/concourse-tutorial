# Passing task outputs to another task

In section 10 our task `web-app-tests` consumed an input resource and ran a script that ran some unit tests. The task did not create anything new. Some tasks will want to create something that is then passed to another task for further processing (this section); and some tasks will create something that is pushed back out to the external world (next section).

So far our pipelines' tasks' inputs have only come from resources using `get: resource-tutorial` build plan steps.

A task's `inputs` can also come from the `outputs` of previous tasks. All a task needs to do is declare that it publishes `outputs`, and subsequent steps can consume those as `inputs` by the same name.

A task file declares it will publish outputs with the `outputs` section:

```
outputs:
- name: some-files
```

If a task included the above `outputs` section then it's `run:` command would be responsible for putting interesting files in the `some-files` directory.

Subsequent tasks (discussed in this section) or resources (discussed in the next section) could reference these interesting files within the `some-files/` directory.

```
cd ../11_task_outputs_to_inputs
fly sp -t tutorial -c pipeline.yml -p pass-files -n
fly up -t tutorial -p pass-files
```

In this pipeline's `job-pass-files` there are two task steps `create-some-files` and `show-some-files`:

![pass-files](http://cl.ly/1j32242g0227/download/Image%202016-02-28%20at%205.14.12%20pm.png)

The former creates 4 files into its own `some-files/` directory. The latter gets a copy of these files placed in its own task container filesystem at the path `some-files/`.

The pipeline build plan only shows that two tasks are to be run in a specific order. It does not indicate that `show-files/` is an output of one task and used as an input into the next task.

```yaml
jobs:
- name: job-pass-files
  public: true
  plan:
  - get: resource-tutorial
  - task: create-some-files
    file: resource-tutorial/11_task_outputs_to_inputs/create_some_files.yml
  - task: show-some-files
    file: resource-tutorial/11_task_outputs_to_inputs/show_files.yml
```

Note, task `create-some-files` build output includes the following error:

```
mkdir: can't create directory 'some-files': File exists
```

This is a demonstration that if a task includes `outputs` then those output directories are pre-created and do not need creating.


