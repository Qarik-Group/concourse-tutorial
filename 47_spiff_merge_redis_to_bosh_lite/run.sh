#!/bin/bash

stub=$1; shift
stage=$1; shift
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Concourse API $ATC_URL"
echo "Tutorial $(basename $DIR)"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

usage() {
  echo "USAGE: run.sh credentials.yml [build-task-image|bosh-deploy]"
  exit 1
}

if [[ "${stub}X" == "X" ]]; then
  usage
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  usage
fi

if [[ "${stage}" != "build-task-image" && "${stage}" != "bosh-deploy" ]]; then
  usage
fi


pushd $DIR
  fly sp -t ${fly_target} configure -c pipeline-${stage}.yml -p main --load-vars-from ${stub} -n
  fly -t ${fly_target} unpause-pipeline --pipeline main
  if [[ "${stage}" == "build-task-image" ]]; then
    fly -t ${fly_target} trigger-job -j main/job-build-task-image
    fly -t ${fly_target} watch -j main/job-build-task-image
  else
    fly -t ${fly_target} trigger-job -j main/job-deploy
    fly -t ${fly_target} watch -j main/job-deploy
  fi
popd
