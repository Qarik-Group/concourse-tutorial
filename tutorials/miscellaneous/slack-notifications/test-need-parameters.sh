#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline-no-notifications.yml -n
  fly -t ${fly_target} unpause-pipeline -p tutorial-pipeline
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/test || { echo "failed... continuing"; }
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline-slack-failures.yml -n
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/test || { echo "failed... continuing"; }
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline-dynamic-messages.yml -n
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/test || { echo "failed... continuing"; }
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline-custom-metadata.yml -n
  fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/test || { echo "failed... continuing"; }
popd
