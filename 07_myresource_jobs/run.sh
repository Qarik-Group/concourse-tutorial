#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Concourse API $ATC_URL"

pipeline=$1; shift
if [[ "${pipeline}" != "simple" && "${pipeline}" != "renamed" ]]; then
  echo "USAGE: run.sh [simple|renamed]"
  exit 1
fi

pushd $DIR
  yes y | fly configure -c pipeline-${pipeline}-resource.yml
  curl $ATC_URL/jobs/job-hello-world/builds -X POST
  fly watch -j job-hello-world
popd
