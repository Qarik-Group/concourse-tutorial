TODO
====

-	[x] introduce a task being run directly (01), described within a job (02), described via YAML in a resource (03)
-	[ ] introduce input resources; overview what's available
-	[ ] introduce output resources; overview what's available
-	[x] trigger a job to build if a resources changes (06 - via timer resource)
-	[ ] explicitly introduce the build plan
-	[ ] `aggregate` & `do` steps
-	[ ] `conditions` steps - build plan fails if step fails; but can handle failure explicitly based on previous step results (combine with `aggregate` to cover success & failure cases); perhaps to determine if you bump semvar
-	[ ] `get` steps with `passed: [job-a, job-b]`
-	[ ] task steps that produce new resources (e.g. a `tgz`\) - 09?

Show case resources

-	[x] fetch and bump semver X.Y.Z numbers (20)
-	[x] deploy an app to Cloud Foundry (10)
-	[ ] running tests of a Golang app (11)
-	[ ] building, testing, deploying Java app
-	[ ] building, testing, deploying Ruby app

Non-basic

-	[ ] a resource "changes" based on its `check` - show the checks for each resource
