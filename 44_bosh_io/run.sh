#!/bin/bash

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

pushd $DIR
  fly sp -t ${fly_target} configure -c pipeline.yml -p main -n
  fly -t ${fly_target} unpause-pipeline --pipeline main
  curl $ATC_URL/pipelines/main/jobs/job-bosh-stemcell-release/builds -X POST
  fly -t ${fly_target} watch -j main/job-bosh-stemcell-release
popd
