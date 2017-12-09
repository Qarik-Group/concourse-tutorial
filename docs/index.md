# Introduction to Concourse

Learn to use https://concourse.ci with this linear sequence of tutorials. Learn each concept that builds on the previous concept.

## Thanks

Thanks to Alex Suraci for inventing Concourse CI, and to Pivotal for sponsoring him and a team of developers to work on it for over a year (2014 onwards).

At Stark & Wayne we started this tutorial as we were learning Concourse in early 2015, and we've been using Concourse in production since mid-2015 internally and at nearly all client projects.

Thanks to everyone who has worked through this tutorial and found it useful. I love learning that you're enjoying the tutorial and enjoying Concourse.

Thanks for all the pull requests to help fix regressions with some Concourse versions that came out with "backwards incompatible change".

Thanks to all the staff at Stark & Wayne who helped to maintain this Concourse Tutorial and its examples over the years.

## Getting started

Install Vagrant/Virtualbox.

Fetch this tutorial and start a local Concourse server:

```
git clone https://github.com/starkandwayne/concourse-tutorial.git
cd concourse-tutorial
vagrant box add concourse/lite --box-version $(cat VERSION)
vagrant up
```

Open http://192.168.100.4:8080/ in your browser:

[![initial](/images/dashboard-no-pipelines.png)](http://192.168.100.4:8080/)

Once the page loads in your browser, click to download the `fly` CLI appropriate for your operating system:

![cli](/images/fly_cli.png)

Once downloaded, copy the `fly` binary into your path (`$PATH`), such as `/usr/local/bin` or `~/bin`. Don't forget to also make it executable. For example,

```
sudo mkdir -p /usr/local/bin
sudo mv ~/Downloads/fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly
```

Target Concourse
----------------

In the spirit of declaring absolutely everything you do to get absolutely the same result every time, the `fly` CLI requires that you specify the target API for every `fly` request.

First, alias it with a name `tutorial` (this name is used by all the tutorial task scripts):

```
fly --target tutorial login  --concourse-url http://192.168.100.4:8080
fly -t tutorial sync
```

You can now see this saved target Concourse API in a local file:

```
cat ~/.flyrc
```

Shows a simple YAML file with the API, credentials etc:

```yaml
targets:
  tutorial:
    api: http://192.168.100.4:8080
    token:
      type: ""
      value: ""
```

When we use the `fly` command we will target this Concourse API using `fly -t tutorial`.

> @alexsuraci: I promise you'll end up liking it more than having an implicit target state :) Makes reusing commands from shell history much less dangerous (rogue fly configure can be bad)

