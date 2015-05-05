#!/bin/bash

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
  echo "USAGE: run.sh [show|save]"
  exit 1
}

if [[ "${stage}" != "show" && "${stage}" != "save" ]]; then
  usage
fi

pushd $DIR
  yes y | fly -t ${fly_target} configure -c pipeline-base-${stage}.yml
  curl $ATC_URL/pipelines/main/jobs/job-spiff-merge/builds -X POST
  fly -t ${fly_target} watch -j job-spiff-merge
popd
