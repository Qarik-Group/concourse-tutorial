#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

usage() {
  echo "USAGE: run.sh path/to/credentials.yml [get-version|display-version|rename-resource|bump-minor|bump-rc-save|bump-save-no-trigger]"
  exit 1
}

stub=$1; shift
if [[ "${stub}X" == "X" ]]; then
  usage
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  usage
fi

stage=$1; shift
if [[ "${stage}" != "get-version" && "${stage}" != "display-version" \
  && "${stage}" != "rename-resource" && "${stage}" != "bump-minor" \
  && "${stage}" != "bump-rc-save" && "${stage}" != "bump-save-no-trigger" ]]; then
  usage
fi

pushd $DIR
  yes y | fly configure -c pipeline-${stage}.yml --vars-from ${stub}
  curl $ATC_URL/jobs/job-bump-version/builds -X POST
  fly watch -j job-bump-version
popd
