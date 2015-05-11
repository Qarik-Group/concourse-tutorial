#!/bin/bash

stub=$1; shift
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"

echo "Tutorial $(basename $DIR)"

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
  yes y | fly -t ${fly_target} configure -c pipeline.yml --vars-from ${stub}
  curl $ATC_URL/pipelines/main/jobs/job-deploy/builds -X POST
  fly -t ${fly_target} watch -j job-deploy
popd
