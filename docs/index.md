description: Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.
image_path: /images/concourse-sample-pipeline.gif

# Introduction to Concourse

Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

[![concourse-sample-pipeline](/images/concourse-sample-pipeline.gif)](https://concourse-ci.org/)

Concourse is a 100% open source CI/CD system with approximately 100 [integrations](https://resource-types.concourse-ci.org/) -- [Resource types](https://concourse-ci.org/resource-types.html) -- to the outside world. Concourse's principles reduce the risk of switching to and from Concourse, by encouraging practices that decouple your project from your CI's little details, and keeping all configuration in declarative files that can be checked into version control.

This Concourse Tutorial book is the world's most popular guide for learning Concourse, since 2015. It is a wonderful companion for [Concourse online documentation](https://concourse-ci.org/docs.html).

## Thanks

Thanks to Alex Suraci for inventing Concourse CI, and to Pivotal and now VMWare for sponsoring him and a team of developers to work since 2014.

At Stark & Wayne we started this tutorial as we were learning Concourse in early 2015, and we've been using Concourse in production since mid-2015 internally and at nearly all client projects.

Thanks to everyone who has worked through this tutorial and found it useful. I love learning that you're enjoying the tutorial and enjoying Concourse.

Thanks for all the pull requests to help fix regressions with some Concourse versions that came out with "backwards incompatible change".

Thanks to all the staff at Stark & Wayne who helped to maintain this Concourse Tutorial and its examples over the years.

Thanks to everyone who visits our Stark & Wayne booth at conferences and says "Thanks for the Concourse Tutorial!"

## Getting Started

1. Install [Docker](https://www.docker.com/community-edition).
2. Install [Docker Compose](https://docs.docker.com/compose/install/#install-compose) if not included in your Docker installation. 
While Docker's Compose V2 interface is still in beta, we will continue use the old docker-compose command line in this tutorial.
We will leave it to the reader to mentally convert `docker-compose` to `docker compose`.
3. Deploy Concourse using Docker Compose:

    ```plain
    wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml
    docker-compose up -d
    ```
    The following are common issues found when working with the tutorial 
    
    a. For Windows AMD issues:
    
    - Right click Docker instance
    - Go to Settings -> Daemon  -> Advanced -> Set the "experimental": true
    - Restart Docker
    - Switch to Linux container and restart the docker
    
    b. For running concourse on a docker server instead of locally:
    
    You need to set the external url env variable inside the docker-compose.yml. Without this change you will not be able to login to 
    the webui because it would redirect to 127.0.0.1:8080
    ```plain
    - CONCOURSE_EXTERNAL_URL
    + CONCOURSE_EXTERNAL_URL=http://{{my-server}}:8080
    ```
    You will also need to access the webui and setup the fly target to use this url rather than 127.0.0.1, 
    so change every http://127.0.0.1:8080 in this tutorial to http://{{my-server}}:8080         

### Test Setup

Open http://127.0.0.1:8080/ in your browser:

[![initial](/images/dashboard-no-pipelines.png)](http://127.0.0.1:8080/)

Click on your operating system to download the `fly` CLI.

Once downloaded, copy the `fly` binary into your path (`$PATH`), such as `/usr/local/bin` or `~/bin`. Don't forget to also make it executable. For example,

```plain
sudo mkdir -p /usr/local/bin
sudo mv ~/Downloads/fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly
```

For Windows users, use [this article](https://stackoverflow.com/questions/23400030/windows-7-add-path)
to see where to add `fly` in to the `PATH`.

## Target Concourse

In the spirit of declaring absolutely everything you do to get absolutely the same result every time, the `fly` CLI requires that you specify the target API for every `fly` request.

First, alias it with a name `tutorial` (this name is used by all the tutorial task scripts).

```plain
fly --target=tutorial login --concourse-url=http://127.0.0.1:8080 --username=admin --password=admin
fly --target=tutorial sync
```

You can now see this saved target Concourse API in a local file:

```plain
cat ~/.flyrc
```

Shows a simple YAML file with the API, credentials etc:

```yaml
targets:
  tutorial:
    api: http://127.0.0.1:8080
    team: main
    token:
      type: Bearer
      value: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJjc3JmIjoiYjE3ZDgxZmMwMWIxNDE1Mjk2OWIyZDc4NWViZmVjM2EzM2IyY2MxYWZjZjU3Njc1ZWYwYzY0MTM3MWMzNzI3OSIsImV4cCI6MTUyMjcwMjUwMCwiaXNBZG1pbiI6dHJ1ZSwidGVhbU5hbWUiOiJtYWluIn0.JNutBGQJMKyFzow5eQOTXAw3tOeM8wmDGMtZ-GCsAVoB7D1WHv-nHIb3Rf1zWw166FuCrFqyLYnMroTlQHyPQUTJFDTiMEGnc5AY8wjPjgpwjsjyJ465ZX-70v1J4CWcTHjRGrB1XCfSs652s8GJQlDf0x2hi5K0xxvAxsb0svv6MRs8aw1ZPumguFOUmj-rBlum5k8vnV-2SW6LjYJAnRwoj8VmcGLfFJ5PXGHeunSlMdMNBgHEQgmMKf7bFBPKtRuEAglZWBSw9ryBopej7Sr3VHPZEck37CPLDfwqfKErXy_KhBA_ntmZ87H1v3fakyBSzxaTDjbpuOFZ9yDkGA
```

When we use the `fly` command we will target this Concourse API using `fly --target tutorial`.

> @alexsuraci: I promise you'll end up liking it more than having an implicit target state :) Makes reusing commands from shell history much less dangerous (rogue fly configure can be bad)

## Fly Help

In keeping with the philosophy of clarity, all the fly commands in this tutorial will use the long form names for its command operations.
If you get tired of typing out the command operation all the time, you can lookup the command's alias using fly help
command. Most fly operations have an alias and as a bonus, you also get a short operation description!

``` plain
fly help
```

There are also long and short forms for options as well for fly operations.
To see an operation's parameters and options place `--help` or `-h` after the operation parameter.

``` plain
fly login --help
```
Using option long forms as in the `fly login` command above, makes the command line hard to read, so we will use the short option forms
in the remainder of this tutorial. Here is the login command again using the short option names.

``` plain
fly -t tutorial login -c http://127.0.0.1:8080 -u admin -p admin
```

Now, isn't that nicer to read and type!

## Destroy Concourse

When you've finished with your local Concourse, deployed via `docker-compose up`, you can use `docker-compose down` to destroy it.

```plain
docker-compose down
```
