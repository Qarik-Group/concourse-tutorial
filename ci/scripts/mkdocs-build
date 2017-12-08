#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
apt-get update
apt-get install -y python3-pip
pip3 install --upgrade pip
pip3 install mkdocs-material

git clone ${REPO_ROOT} ${SITE_ROOT}
cd ${SITE_ROOT}
mkdocs build
