#!/bin/bash

set -e # fail fast
set -x # print commands

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

fly_target=${fly_target:-tutorial}
pipeline=helloworld
atc_url=$(cat ~/.flyrc | yaml2json | jq -r ".targets.${fly_target}.api")

pushd $DIR
  fly -t ${fly_target} sp -p $pipeline -c pipeline.yml -n
  curl $atc_url/pipelines/${pipeline}/jobs/job-hello-world/builds -X POST
  fly -t ${fly_target} watch -j ${pipeline}/job-hello-world
popd
