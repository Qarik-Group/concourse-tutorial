# Tutorial's own CI pipeline

This is the pipeline which checks that the tutorial is working.


## Setup

To run this pipline you'll need to give it access to a BOSH
director and a Cloud Foundry account.


```
fly --target ${fly_target} set-pipeline --pipeline concourse-tutorial --config ci/pipeline.yml -l ci/credentials.yml --load-vars-from credentials.yml
fly --target ${fly_target} unpause-pipeline --pipeline concourse-tutorial
```
