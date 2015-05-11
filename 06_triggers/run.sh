#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"

echo "Tutorial $(basename $DIR)"

pushd $DIR
  yes y | fly -t ${fly_target} configure -c pipeline.yml
  echo open in browser $ATC_URL
popd
