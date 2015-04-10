50 - Dummy resource
===================

Create dummy resource
---------------------

```
vagrant ssh
```

Change to root user:

```
sudo su -
```

In `/var/vcap/packages` create `dummy` and copy another resource package (a rootfs) into it and create a `opt/resources/out`

```
cd /var/vcap/packages
mkdir dummy
cp -r time_resource/* dummy/
cd dummy/opt/resource
rm *
```

Now create `out` file:

```bash
#!/bin/sh

echo '{"version": {"ref": 123}}'
```

And make it executable:

```
chmod +x out
```

Add new resource type into worker
---------------------------------

```
vi /var/vcap/jobs/groundcrew/config/worker.json
```

The top-level of this JSON are the keys: `platform`, `tags`, `addr`, and `resource_types`. We want to add our new resource type to the latter's list.

Add to the tail:

```
,{"image":"/var/vcap/packages/dummy","type":"dummy"}]}
```

Exit and restart the `beacon` monit process (see `/var/vcap/jobs/groundcrew/monit` for definition):

```
monit restart beacon
```

From the host machine, the new resource type will now be registered with Concourse ATC's API:

```
curl http://192.168.100.4:8080/api/v1/workers
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

```
run.sh
```

![dummy](http://cl.ly/image/3N292T3b2a0g/dummy_resource.png)
