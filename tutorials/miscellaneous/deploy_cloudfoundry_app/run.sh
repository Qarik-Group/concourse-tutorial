#!/bin/bash

stub=$1; shift
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

if [ -z "${stub}" ]; then
  stub="../credentials.yml"
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  usage
fi

pushd $DIR
  fly sp -t ${fly_target} configure -c pipeline.get-only.yml -p main --load-vars-from ${stub} -n
  fly -t ${fly_target} unpause-pipeline --pipeline main
  fly -t ${fly_target} trigger-job -j main/stemcells
  fly -t ${fly_target} watch -j main/stemcells
popd
