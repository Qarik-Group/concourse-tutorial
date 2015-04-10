TODO
====

-	[x] introduce a task being run directly (01), described within a job (02), described via YAML in a resource (03)
-	[ ] introduce input resources; overview what's available
-	[ ] introduce output resources; overview what's available
-	[ ] show examples of how inputs to tasks are passed via files
-	[x] trigger a job to build if a resources changes (06 - via timer resource)
-	[ ] explicitly introduce the build plan
-	[ ] `aggregate` & `do` steps - all inputs need to be in first `aggregate` step
-	[ ] `conditions` steps - build plan fails if step fails; but can handle failure explicitly based on previous step results (combine with `aggregate` to cover success & failure cases); perhaps to determine if you bump semvar
-	[ ] `get` steps with `passed: [job-a, job-b]`
-	[ ] task steps that produce new resources (e.g. a `tgz`\) - 09?

-	[ ] `fly intercept` (`hijack`\)

-	[ ] update to new concourse in vagrant - `vagrant box update` & `sudo fly sync`

Show case resources

-	[x] fetch and bump semver X.Y.Z numbers (20)
-	[x] deploy an app to Cloud Foundry (10)
-	[ ] running tests of a Golang app (11)
-	[ ] building, testing, deploying Java app
-	[ ] building, testing, deploying Ruby app
-	[x] build/push a docker image - perhaps automate https://github.com/mmb/bosh_cli_docker_container (35, demo in 41)
-	[x] pull a docker image (36)
-	[ ] pull a docker image and use it
-	[x] get bosh release
-	[x] get bosh stemcell
-	[ ] bosh deploy

Non-basic

-	[ ] a resource "changes" based on its `check` - show the checks for each resource
-	[ ] options/methods for passing in private keys e.g. https://gist.github.com/vito/81248555ad1f6100674e#file-sanitized-concourse-yml-L1028-L1036 which is used https://github.com/concourse/concourse/blob/master/ci/scripts/bump-resource-package#L14

Writing Resources

-	[ ] Show resources are available per worker node (via ATC API; ssh in to vagrant)
-	[x] Show that `/var/vcap/jobs/groundcrew/config/worker.json` describes the per-worker resources available (change `worker.json`, then `monit restart beacon`, and resource type shows up in ATC API)
-	[x] use a docker URI `docker:///username/imagename#tagname` for dev/test of the docker image without forcing re-deploy (41)
