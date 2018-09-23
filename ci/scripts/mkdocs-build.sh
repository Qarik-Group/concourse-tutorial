#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
apt-get update
apt-get install -y python3-pip
pip3 install 'pymdown-extensions<5.0' 'Markdown<3.0' 'mkdocs<1.0' 'mkdocs-material<3.0'

git clone ${REPO_ROOT} ${SITE_ROOT}
cd ${SITE_ROOT}
mkdocs build
