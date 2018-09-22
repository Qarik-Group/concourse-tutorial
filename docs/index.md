description: Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.
image_path: /images/concourse-sample-pipeline.gif

# Introduction to Concourse

Learn to use https://concourse-ci.org with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

[![concourse-sample-pipeline](/images/concourse-sample-pipeline.gif)](https://concourse-ci.org/)

Concourse is 100% open source CI/CD system with approximately 100 [integrations](https://concourse-ci.org/resource-types.html) to the outside world. Concourse's principles reduce the risk of switching to and from Concourse, by encouraging practices that decouple your project from your CI's little details, and keeping all configuration in declarative files that can be checked into version control.

This Concourse Tutorial book is the world's most popular guide for learning Concourse, since 2015. It is a wonderful companion for [Concourse online documentation](https://concourse-ci.org/index.html).

## Thanks

Thanks to Alex Suraci for inventing Concourse CI, and to Pivotal for sponsoring him and a team of developers to work since 2014.

At Stark & Wayne we started this tutorial as we were learning Concourse in early 2015, and we've been using Concourse in production since mid-2015 internally and at nearly all client projects.

Thanks to everyone who has worked through this tutorial and found it useful. I love learning that you're enjoying the tutorial and enjoying Concourse.

Thanks for all the pull requests to help fix regressions with some Concourse versions that came out with "backwards incompatible change".

Thanks to all the staff at Stark & Wayne who helped to maintain this Concourse Tutorial and its examples over the years.

Thanks to everyone who visits our Stark & Wayne booth at conferences and says "Thanks for the Concourse Tutorial!"

## Getting Started

1. Install [Docker](https://www.docker.com/community-edition).
2. Install [Docker Compose](https://docs.docker.com/compose/install/#install-compose) if not included in your Docker installation.
3. Deploy Concourse using Docker Compose:

    ```plain
    wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml
    docker-compose up -d
    ```

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
fly --target tutorial login --concourse-url http://127.0.0.1:8080 -u admin -p admin
fly --target tutorial sync
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

## Destroy Concourse

When you've finished with your local Concourse, deployed via `docker-compose up`, you can use `docker-compose down` to destroy it.

```plain
docker-compose down
```
