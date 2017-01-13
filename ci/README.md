# Tutorial's own CI pipeline

This is the pipeline which checks that the tutorial is working.


## Setup

To run this pipline you'll need to give it access to a BOSH
director and a Cloud Foundry account.


```
fly -t ${fly_target} set-pipeline -p concourse-tutorial -c ci/pipeline.yml -l ci/credentials.yml -l credentials.yml
fly -t ${fly_target} unpause-pipeline -p concourse-tutorial
```
