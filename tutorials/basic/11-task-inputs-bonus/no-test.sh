#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

usage() {
  echo "USAGE: test.sh [ls-abc-xyz|ls-abc|pretty-ls]"
  exit 1
}

cd $DIR

stage=${1:-}
if [ -z "${stage}" ];then
 ./test.sh ls-abc-xyz
 ./test.sh ls-abc
 ./test.sh pretty-ls
 exit 0
elif [[ "${stage}" != "ls-abc-xyz" && "${stage}" != "ls-abc" \
  && "${stage}" != "pretty-ls" ]]; then
  usage
fi

fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline-${stage}.yml -n
fly -t ${fly_target} unpause-pipeline -p tutorial-pipeline
fly -t ${fly_target} trigger-job -w -j tutorial-pipeline/job-with-inputs
