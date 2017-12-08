# Using resource inputs in job tasks

Note, the topic of running unit tests in your pipeline will be covered in more detail in future sections.

Consider a simple application that has unit tests. In order to run those tests inside a pipeline we need:

* a task `image` that contains any dependencies
* an input `resource` containing the task script that knows how to run the tests
* an input `resource` containing the application source code

For the example Go application [simple-go-web-app](https://github.com/cloudfoundry-community/simple-go-web-app), the task image needs to include the Go programming language. We will use the `golang:1.6-alpine` image from https://hub.docker.com/_/golang/ (see https://imagelayers.io/?images=golang:1.6-alpine for size of layers)

The task file `task_run_tests.yml` includes:

```yaml
image_resource:
  type: docker-image
  source: {repository: golang, tag: 1.6-alpine}

inputs:
- name: resource-tutorial
- name: resource-app
  path: gopath/src/github.com/cloudfoundry-community/simple-go-web-app
```

The `resource-app` resource will place the inbound files for the input into an alternate path. By default we have seen that inputs store their contents in a folder of the same name. The reason for using an alternate path in this example is specific to building & testing Go language applications and is outside the scope of the section.

To run this task within a pipeline:

```
cd ../10_job_inputs
fly sp -t tutorial -c pipeline.yml -p simple-app -n
fly up -t tutorial -p simple-app
```

View the pipeline UI http://192.168.100.4:8080/pipelines/simple-app and notice that the job automatically starts.

The job will pause on the first run at `web-app-tests` task because it is downloading the `golang:1.6-alpine` image for the first time.

The `web-app-tests` output below corresponds to the Go language test output (in case you've not seen it before):

```
ok  	github.com/cloudfoundry-community/simple-go-web-app	0.003s
```


