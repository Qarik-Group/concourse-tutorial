#!/bin/bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

pushd $DIR
  yes y | fly configure -c pipeline.yml
  curl $ATC_URL/jobs/job-bosh-stemcell-release/builds -X POST
  fly watch -j job-bosh-stemcell-release
popd
