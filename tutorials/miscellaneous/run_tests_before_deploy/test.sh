#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
  if [[ "${CREDENTIALS_FILE:-X}" == "X" ]]; then
    fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline.yml -n
  else
    fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline.yml -n -l ${CREDENTIALS_FILE}
  fi  
  fly -t ${fly_target} unpause-pipeline -p tutorial-pipeline
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/deploy-app
popd
