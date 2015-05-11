#!/bin/bash

stub=$1; shift
stage=$1; shift

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"

echo "Tutorial $(basename $DIR)"

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
  yes y | fly -t ${fly_target} configure -c pipeline-${stage}.yml --vars-from ${stub}
  if [[ "${stage}" == "build-cli" || "${stage}" == "build-save" ]]; then
    curl $ATC_URL/pipelines/main/jobs/job-build-bosh-init-cli/builds -X POST
    fly -t ${fly_target} watch -j job-build-bosh-init-cli
  elif [[ "${stage}" == "plus-openstack" ]]; then
    curl $ATC_URL/pipelines/main/jobs/job-repackage-bosh-init-openstack/builds -X POST
    fly -t ${fly_target} watch -j job-repackage-bosh-init-openstack
  else
    curl $ATC_URL/pipelines/main/jobs/job-repackage-bosh-init-aws/builds -X POST
    # curl $ATC_URL/pipelines/main/jobs/job-repackage-bosh-init-openstack/builds -X POST
    fly -t ${fly_target} watch -j job-repackage-bosh-init-aws
  fi
popd
