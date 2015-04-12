#!/bin/bash

stage=$1; shift

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

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
  yes y | fly configure -c pipeline-base-${stage}.yml
  curl $ATC_URL/jobs/job-spiff-merge/builds -X POST
  fly watch -j job-spiff-merge
popd
