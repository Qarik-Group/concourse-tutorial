# Changed by yousafkhamza

## Concourse installation:
-----------------------------
Download From: wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml

Afterthen change URL with your public IP in YML file   ie. (http:3.82.191.135:8080)
afterthen please add both of the lines on last (Already added in my forked repo)

```
CONCOURSE_GARDEN_DNS_PROXY_ENABLE=true
CONCOURSE_WORKER_GARDEN_DNS_PROXY_ENABLE=true
```

#### Please exicute this command also
```
iptables -P FORWARD ACCEPT                  
```

> Concourse CI Installation with the help of docker

```
docker-compose up -d
```

---
### After the installation Please download fly from your installation:
```
wget "http://youriphere:8080/api/v1/cli?arch=amd64&platform=linux" -O fly
chmod +x fly
mv fly /usr/bin
```

---
### Fly Admin User initilisation
```
fly -t env login -u admin -p admin
fly --t env sync
```

> cat ~/.flyrc               <-- you can change the same here once your have already done.

This changes made by yousaf k hamza......

---------
# Concourse Tutorial

Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

Read the tutorial at https://concoursetutorial.com

## Thanks

Thanks to Alex Suraci for inventing Concourse CI, and to Pivotal and VMWare for sponsoring him and a team of developers to work since 2014.

At Stark & Wayne we started this tutorial as we were learning Concourse in early 2015, and we've been using Concourse in production since mid-2015 internally and at nearly all client projects.

Thanks to everyone who has worked through this tutorial and found it useful. I love learning that you're enjoying the tutorial and enjoying Concourse.

Thanks for all the pull requests to help fix regressions with some Concourse versions that came out with "backwards incompatible change".

## Getting Started

Read the tutorial at https://concoursetutorial.com

## Local development of tutorial

This tutorial is built using [`mkdocs`](http://www.mkdocs.org/). Please make sure you have python3 and pip3 installed before running mkdocs and they are refenced as python and pip respectively. . Once installed, you can continuously build and serve the tutorial locally with:

```plain
pip install mkdocs
pip install pymdown-extensions
pip install mkdocs-material

mkdocs serve
```

## Manual deployment

```
mkdocs build
cd site
gsutil -m cp -r . gs://concoursetutorial-com-website
gsutil -m rsync -r -x '\.git.*' . gs://concoursetutorial-com-website

```

View the site and live changes at https://localhost:8000.
