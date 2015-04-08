#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

usage() {
  echo "USAGE: run.sh [simple-ls|pretty-ls]"
  exit 1
}

stage=$1; shift
if [[ "${stage}" != "simple-ls" && "${stage}" != "pretty-ls" ]]; then
  usage
fi


pushd $DIR
  yes y | fly configure -c pipeline-${stage}.yml
  curl $ATC_URL/jobs/job-inputs-btw-steps/builds -X POST
  fly watch -j job-inputs-btw-steps
popd
