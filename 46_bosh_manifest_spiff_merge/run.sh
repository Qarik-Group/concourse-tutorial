#!/bin/bash


# set -ex

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
  echo "USAGE: run.sh [show|save]"
  exit 1
}

stage=$1; shift
if [ -z "${stage}" ]; then
  ./run.sh show
  # ./run.sh save
  exit 0
elif [[ "${stage}" != "show" && "${stage}" != "save" ]]; then
  usage
fi

echo bar

pushd $DIR
  fly sp -t ${fly_target} configure -c pipeline-base-${stage}.yml -p main -n
  fly -t ${fly_target} unpause-pipeline --pipeline main
  fly -t ${fly_target} trigger-job -j main/job-spiff-merge
  fly -t ${fly_target} watch -j main/job-spiff-merge
popd
