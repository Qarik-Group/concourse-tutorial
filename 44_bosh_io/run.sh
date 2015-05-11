#!/bin/bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"

echo "Tutorial $(basename $DIR)"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

pushd $DIR
  yes y | fly -t ${fly_target} configure -c pipeline.yml
  curl $ATC_URL/pipelines/main/jobs/job-bosh-stemcell-release/builds -X POST
  fly -t ${fly_target} watch -j job-bosh-stemcell-release
popd
