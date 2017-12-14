#!/bin/bash

set -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
  fly -t ${fly_target} sp -p tutorial-pipeline -c pipeline.yml -n
  fly -t ${fly_target} up -p tutorial-pipeline
  fly -t ${fly_target} trigger-job -j tutorial-pipeline/publish -w
popd
