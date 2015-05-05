#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Concourse API $ATC_URL"
echo "Tutorial $(basename $DIR)"

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
  yes y | fly -t ${fly_target} configure -c pipeline-${stage}.yml
  curl $ATC_URL/pipelines/main/jobs/job-with-inputs/builds -X POST
  fly watch -j job-with-inputs
popd
