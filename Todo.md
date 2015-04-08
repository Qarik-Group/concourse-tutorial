TODO
====

-	[x] introduce a task being run directly (01), described within a job (02), described via YAML in a resource (03)
-	[ ] introduce input resources; overview what's available
-	[ ] introduce output resources; overview what's available
-	[x] trigger a job to build if a resources changes (06 - via timer resource)
-	[ ] explicitly introduce the build plan
-	[ ] `aggregate` task step
-	[ ] `get` steps with `passed: [job-a, job-b]`
-	[ ] task steps that produce new resources (e.g. a `tgz`\) - 09?

Show case resources

-	[x] fetch and bump semver X.Y.Z numbers (20)
-	[x] deploy an app to Cloud Foundry (10)

Non-basic

-	[ ] a resource "changes" based on its `check` - show the checks for each resource
