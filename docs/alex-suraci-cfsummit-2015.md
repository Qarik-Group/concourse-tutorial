Summary of ideas from Alex Suraci at CF Summit 2015
===================================================

Alex Suraci is the creator of Concourse and lead developer. He gave a talk at CF Summit 2015

https://www.youtube.com/watch?v=mYTn3qBxPhQ&list=WL&index=27

Slides https://docs.google.com/presentation/d/13pEbkTs9--d2eYHSnzM9dUo7JJpdv8Xt6a2lWu1aa68/edit#slide=id.p

Simple primitives
-----------------

-	**resources:** detecting, fetching, creating of external versioned “things”
-	**tasks:** run a script in a container with its dependent inputs
-	**jobs:** compose resources and tasks together to do something (run tests, ship, etc.)

Pipelines
---------

-	the resulting flow of resources through jobs
-	fancy visualization UI for build monitor
-	many isolated pipelines per deployment

Low cognitive overhead
----------------------

-	think of a job in isolation (inputs + outputs)
-	don’t have to keep full topology in your head
-	adding jobs is easy; pipeline flow is a result of individual job definitions, don’t need it all in your head

Reproducible everything
-----------------------

Subtitle: because bad things happen to good people

> Its nice not to worry too much about CI burning down. A VM could disappear or all the VMs. Its nice to able to say "I have this configuration, bring it back"

-	No clicking through wizards
-	Pipelines are just config files
-	Deploy cluster with vagrant or BOSH/bosh-lite
-	Workers are stateless

No big deal to reconstruct CI deployment if infrastructure fails.

Reproducible builds
-------------------

-	never hand-configure workers again
-	all builds run in stateless containers
-	one-off builds with custom inputs (local bits)
-	no ability to rely on CI state

result: portable CI scripts with decent abstractions, less coupled to Concourse

There are so many important distinctions between Concourse and other CI systems right here.

Perhaps the last line summarizes it best "no ability to rely on CI state".

CI state is hidden away. Recently that even randomized the root folder of a task so that task scripts didn't code them as dependencies.

Instead of `$BUILD_NUMBER` variable being managed by the CI system, your pipelines externalize this concept as `semver` resource and you manage it how you want. Bump any part of `X.Y.Z` or `X.Y.Z-rc.A` semver at anypoint in the pipeline.

Resources: delete your boring scripts
-------------------------------------

The main goal of Resources is to "delete all your boring crap; all your boiler plate".

-	encapsulation of some external “thing”
-	replaces boring plumbing scripts
-	results in intuitive pipeline semantics
-	many “first class” concepts from other systems are implemented in terms of resources (e.g. timed triggers)
-	only pluggable interface

Resources are the only way you can extend Concourse.

Resource interface
------------------

```
get   :: version -> input
put   :: output -> version
check :: version? -> [version]
```

e.g. git resource:

```
get   = git clone git@github.com:...
put   = git push origin [branch]
check = git pull && git log abcdef..HEAD
```

Debuggable builds
-----------------

Via the `fly` CLI

-	`fly execute` - run task using local inputs
-	`fly hijack` - hop into a running/completed build container - resources or tasks
-	`fly configure` - update pipeline configuration; fast feedback loop

Stateless worker pool
---------------------

-	no configuring dependencies on worker vms; all builds run in containers
-	supports arbitrary platforms (Garden API)
-	registering external workers is easy: only ATC has to be reachable, not your workers. no VPN needed.
-	only number to think about is “how many”

Highly available
----------------

-	ATCs can be scaled up; rely on ELB for load balancing
-	throw more workers into your pool by changing BOSH instance count

I assume you could use the sslproxy-boshrelease or the haproxy job from cf-release for a load balancer outside of AWS

Running multiple ATCs allows Concourse to upgrade itself without going down.

Same real thing, different logical resources
--------------------------------------------

During Q&A Alex introduces the idea that a resource thing - e.g. concourse's own git repo - might be represented in multiple logical resources.

In Concourse's pipeline, the same git repo is referenced as resources `concourse`, `concourse-master`, `concourse-develop`.

His explanation - use separate logical `resources` if you are using them in different ways.

"We should probably update the docs as a lot of people trip up on that."
