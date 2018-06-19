#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [[ "$(which pip3)X" == "X" ]]; then
  apt-get update
  apt-get install python3-pip -y
fi


pip3 install mkdocs-material

git clone ${REPO_ROOT} ${SITE_ROOT}
cd ${SITE_ROOT}
mkdocs build
