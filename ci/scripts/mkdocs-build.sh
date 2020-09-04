#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
apt-get update
apt-get install -y python3-pip
pip3 install 'pymdown-extensions<=8.0' 'Markdown<=3.2.2' 'mkdocs<=1.1.2' 'mkdocs-material<=5.5.9'

git clone ${REPO_ROOT} ${SITE_ROOT}
cd ${SITE_ROOT}
mkdocs build
