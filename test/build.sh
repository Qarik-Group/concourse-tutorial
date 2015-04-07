#!/bin/bash

set -e
# set -x

export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Concourse API $ATC_URL"

./01_*/run.sh
./02_*/run.sh
./03_*/run.sh
./06_*/run.sh
./07_*/run.sh simple
./07_*/run.sh renamed
./08_*/run.sh
./10_*/run.sh
./11_*/run.sh stub.yml
./12_*/run.sh stub.yml
./20_*/run.sh stub.yml get-version
./20_*/run.sh stub.yml display-version
./20_*/run.sh stub.yml rename-resource
