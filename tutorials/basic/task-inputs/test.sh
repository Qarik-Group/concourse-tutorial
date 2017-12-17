#!/bin/bash

set -eu

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"

pushd $DIR
    fly -t ${fly_target} execute -c no_inputs.yml
    fly -t ${fly_target} e -c inputs_required.yml && { echo "Should have failed"; exit 1; }
    fly -t ${fly_target} e -c inputs_required.yml -i some-important-input=.
    fly -t ${fly_target} e -c inputs_required.yml -i some-important-input=../task-hello-world
popd
