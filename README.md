Concourse Tutorial
==================

Learn to use https://concourse.ci with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

Getting started
---------------

Install Vagrant/Virtualbox.

```
vagrant up
```

Open http://192.168.100.4:8080/ in the browser:

[![initial](http://cl.ly/image/221Y1F3V2s0e/concourse_initial.png)](http://192.168.100.4:8080/)

Download the `fly` CLI from the bottom right hand corner:

![cli](http://cl.ly/image/1r462S1m1j1H/fly_cli.png)

Place it in your path (`$PATH`), such as `/usr/bin` or `~/bin`.

Tutorials
---------

### 01 - Hello World task

```
$ cd 01_task_hello_world
$ fly execute -c 01_task_hello_world.yml
Connecting to 10.0.2.15:8080 (10.0.2.15:8080)
-                    100% |*******************************| 10240   0:00:00 ETA
initializing with docker:///ubuntu#14.04
running echo hello world
hello world
succeeded
```

On the first time this will trigger concourse to download the `ubuntu#14.04` docker image.
