#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline.yml -n
  fly -t ${fly_target} unpause-pipeline -p tutorial-pipeline
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/show-animal-names && { echo "Expected to fail"; exit 1; }

  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline.yml -v cat-name=garfield -v dog-name=odie -n
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/show-animal-names
popd
