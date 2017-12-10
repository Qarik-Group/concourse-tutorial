#!/bin/bash

git clone ${REPO_ROOT:?required} ${REPO_OUT:?required}

if [[ ! -f ${CONCOURSE_ROOT:?required}/concourse-lite.yml ]]; then
    echo "${CONCOURSE_ROOT:?required}/concourse-lite.yml is missing"
    exit 1
fi
mkdir -p ${REPO_OUT}/manifests/
cp ${CONCOURSE_ROOT:?required}/concourse-lite.yml ${REPO_OUT}/manifests/concourse-lite.yml
