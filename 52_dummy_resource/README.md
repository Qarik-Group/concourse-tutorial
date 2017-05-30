52 - Dummy resource
===================

This section includes a pipeline using a new resource called `dummy`.

```
cd ../52_dummy_resource
./run.sh
```

Run a job that uses resource type
---------------------------------

The simplest pipeline to use this new resource type is:

```yaml
jobs:
- name: job-dummy
  public: true
  serial: true
  plan:
  - put: resource-dummy
resources:
- name: resource-dummy
  type: dummy
```

Deploy the pipeline:

```
cd ../52_dummy_resource
./run.sh
```

![dummy](http://cl.ly/image/3N292T3b2a0g/dummy_resource.png)
