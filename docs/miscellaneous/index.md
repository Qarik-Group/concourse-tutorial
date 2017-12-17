# Introduction

This section contains miscellaneous lessons that follow on from the sequential Basic lessons.

Using a Credentials Manager with Concourse is best practice, so from this point onwards the lessons will assume you are continuing to run `bucc` from the [Secrets with Credentials Manager](/basics/secret-parameters.md) lesson. 

Therefore the lessons will include `fly -t bucc` commands, rather than `fly -t tutorial` commands.

Also, the lessons will instruct to run `credhub set` commands to populate parameters for your pipelines.

You can of course use any Concourse, with or without a credentials manager. Adjust the `fly -t bucc` target alias for your target Concourse, and you can use `fly set-pipeline` with `-v` or `-l` flags to pass in parameters from the command line. Revisit lesson [Parameters](/basics/parameters.md) to learn more.

## Abbreviated pipelines

In the Basics section, all Concourse pipeline resources had names prefixed with `resource-` and jobs prefixed with `job-`. This was to help you easily learn that they are different, and start to see how each is used within a pipeline:

* resources appear within jobs via `get: myresource` and `put: myresource`
* jobs appear within jobs as `passed: [myjob]` to form pipelines

Normal pipelines do not include these prefixes. The Miscellaneous lessons' pipelines will no longer include the prefixes.

## Requests for Lessons

If there is a lesson you'd like added to the Concourse Tutorial book, please [create an Issue](https://github.com/starkandwayne/concourse-tutorial/issues). It is very interesting to learn how you and your team are using Concourse, or looking to switch from a previous CI/CD tool to Concourse.