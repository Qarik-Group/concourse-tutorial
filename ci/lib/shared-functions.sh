#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/pretty-output.sh

export fly_target=${fly_target:-tutorial}
export TUTORIAL_CONCOURSE_URL=${TUTORIAL_CONCOURSE_URL:-"http://127.0.0.1:8080"}
export PIPELINE_CREDENTIALS=${PIPELINE_CREDENTIALS:-"$DIR/../../credentials.yml"}

function ensure-fly {
  announce-task "Making sure fly is installed..."

  if [ `which fly` ]; then
    echo "Fly is at `which fly`"
  else
    echo "Fly not found. Installing..."
    run-cmd curl -L https://github.com/concourse/concourse/releases/download/v2.5.0/fly_linux_amd64 -o /usr/local/bin/fly
    run-cmd chmod 755 /usr/local/bin/fly
    run-cmd fly -t ${fly_target} sync

  fi
}

function check-bosh {
  announce-task "Making sure BOSH CLI is installed..."

  if [ `which bosh` ]; then
    echo "BOSH CLI is at `which bosh`"
  else
    fail-error "BOSH CLI not found in path."
  fi
  bosh env
}

function ensure-credentials-yml {
  announce-task "Ensuring we have a credentials.yml..."

  if [[ ! -f $PIPELINE_CREDENTIALS ]]; then
    echo "Cannot find $PIPELINE_CREDENTIALS"
    exit 1
  fi
}

function deploy-concourse {
  announce-task "Starting deployment..."
  export BOSH_DEPLOYMENT=concourse-tutorial-ci
  mkdir -p /tmp/operators
  cat > /tmp/operators/name.yml <<YAML
- type: replace
  path: /name
  value: $BOSH_DEPLOYMENT
YAML
  run-cmd bosh -n deploy \
    ${REPO_ROOT:?required}/manifests/concourse-lite.yml \
    -o /tmp/operators/name.yml
  run-cmd bosh instances
}

function check-concourse {
  announce-task "Making sure Concourse is up..."
  if [[ ! $(bosh int ~/.flyrc --path /targets/${fly_target}/api) ]]; then
    run-cmd fly login -t ${fly_target} -c ${TUTORIAL_CONCOURSE_URL}
  fi
  run-cmd fly -t ${fly_target} sync
  run-cmd fly -t ${fly_target} pipelines
}
