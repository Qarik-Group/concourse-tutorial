#!/bin/bash

export fly_target=${fly_target:-tutorial}

function ensure-rvm {
  announce-task "Making sure RVM is set up..."
  set +ux
  if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
    run-cmd source "$HOME/.rvm/scripts/rvm"
  elif [ -s "/usr/local/rvm/scripts/rvm" ] ; then
    run-cmd source "/usr/local/rvm/scripts/rvm"
  else
    fail-error "An RVM installation was not found."
  fi
  set -u
}

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

function ensure-bosh-cli {
  announce-task "Making sure BOSH CLI is installed..."

  if [ `which bosh` ]; then
    echo "BOSH CLI is at `which bosh`"
  else
    fail-error "BOSH CLI not found in path."
  fi
}

function ensure-credentials-yml {
  announce-task "Ensuring we have a credentials.yml..."

  if [ -e "credentials.yml" ]; then
    echo "Found credentials.yml in repo root."
  elif [ -e "../credentials/credentials.yml" ]; then
    echo "Found ../credentials/credentials.yml. Linking..."
    ln -s "../credentials/credentials.yml"
  else
    fail-error "Could not find credentials.yml."
  fi
}

function bosh-login {
  announce-task "Logging-in to BOSH director..."
  which bosh
  bosh version

  set +x
  bosh -t ${bosh_director} login ${bosh_username} ${bosh_password}
  run-cmd bosh target ${bosh_director}
  run-cmd bosh status
}

function deploy-concourse {
  announce-task "Starting deployment..."
  run-cmd bosh deployment ci/manifest-vsphere-4.yml
  run-cmd bosh -n deploy
  run-cmd bosh instances
}

function check-concourse {
  announce-task "Making sure Concourse is up..."
  run-cmd fly login -t ${fly_target} -c http://10.58.111.191
  run-cmd fly -t ${fly_target} sync
  run-cmd fly -t ${fly_target} pipelines
}
