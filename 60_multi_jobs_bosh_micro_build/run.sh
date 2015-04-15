#!/bin/bash

stub=$1; shift
stage=$1; shift

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Tutorial $(basename $DIR)"
echo "Concourse API $ATC_URL"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

usage() {
  echo "USAGE: run.sh path/to/credentials.yml [build-cli|build-save|repackage|plus-openstack]"
  exit 1
}

if [[ "${stub}X" == "X" ]]; then
  usage
fi
stub=$(realpath $stub)
if [[ ! -f ${stub} ]]; then
  usage
fi

if [[ "${stage}" != "build-cli" && "${stage}" != "build-save" && \
  "${stage}" != "repackage" && "${stage}" != "plus-openstack" ]]; then
  usage
fi


pushd $DIR
  yes y | fly configure -c pipeline-${stage}.yml --vars-from ${stub}
  if [[ "${stage}" == "build-cli" || "${stage}" == "build-save" ]]; then
    curl $ATC_URL/jobs/job-build-bosh-init-cli/builds -X POST
    fly watch -j job-build-bosh-init-cli
  elif [[ "${stage}" == "plus-openstack" ]]; then
    curl $ATC_URL/jobs/job-repackage-bosh-init-openstack/builds -X POST
    fly watch -j job-repackage-bosh-init-openstack
  else
    curl $ATC_URL/jobs/job-repackage-bosh-init-aws/builds -X POST
    # curl $ATC_URL/jobs/job-repackage-bosh-init-openstack/builds -X POST
    fly watch -j job-repackage-bosh-init-aws
  fi
popd
