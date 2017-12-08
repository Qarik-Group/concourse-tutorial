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
if [ -z "${stage}" ];then
 ./run.sh ls-abc-xyz
 ./run.sh ls-abc
 ./run.sh pretty-ls
 exit 0
elif [[ "${stage}" != "ls-abc-xyz" && "${stage}" != "ls-abc" \
  && "${stage}" != "pretty-ls" ]]; then
  usage
fi

set -uex
pushd $DIR
  fly sp -t ${fly_target} configure -c pipeline-${stage}.yml -p main -n
  fly -t ${fly_target} unpause-pipeline --pipeline main
  curl $ATC_URL/pipelines/main/jobs/job-with-inputs/builds -X POST
  fly -t ${fly_target} watch -j main/job-with-inputs
popd
