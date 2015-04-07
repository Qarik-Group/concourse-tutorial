#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Concourse API $ATC_URL"

pushd $DIR
  yes y | fly configure -c pipeline.yml
  echo open in browser $ATC_URL
popd
