#!/bin/bash

stub=$1; shift
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

if [[ "${stub}X" == "X" ]]; then
  echo "USAGE: run.sh path/to/credentials.yml"
  exit 1
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  echo "USAGE: run.sh path/to/credentials.yml"
  exit 1
fi

pushd $DIR
  yes y | fly configure -c pipeline.yml --vars-from ${stub}
  curl $ATC_URL/jobs/job-publish/builds -X POST
  fly watch -j job-publish
popd
