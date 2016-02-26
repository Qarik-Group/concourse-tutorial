#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Concourse API $ATC_URL"
echo "Tutorial $(basename $DIR)"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

pushd $DIR
  yes y | fly sp -t ${fly_target} configure -c pipeline.yml -p job-dummy
  fly unpause-pipeline --pipeline job-dummy
  curl ${ATC_URL}/pipelines/job-dummy/jobs/job-dummy/builds -X POST
  fly -t ${fly_target} watch -j job-dummy/job-dummy
popd
