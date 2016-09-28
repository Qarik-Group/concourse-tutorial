#!/bin/bash

set -uex

gopath/src/github.com/cloudfoundry/bosh-init/bin/build
cp -r gopath/src/github.com/cloudfoundry/bosh-init/out build
