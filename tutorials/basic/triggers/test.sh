#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
  fly -t ${fly_target} set-pipeline -p tutorial-pipeline -c pipeline.yml -n
popd
