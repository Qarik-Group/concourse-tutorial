#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

usage() {
  echo "USAGE: run.sh [ls-abc-xyz|ls-abc|pretty-ls]"
  exit 1
}

stage=$1; shift
if [[ "${stage}" != "ls-abc-xyz" && "${stage}" != "ls-abc" \
  && "${stage}" != "pretty-ls" ]]; then
  usage
fi


pushd $DIR
  yes y | fly configure -c pipeline-${stage}.yml
  curl $ATC_URL/jobs/job-with-inputs/builds -X POST
  fly watch -j job-with-inputs
popd
