#!/bin/bash
# vim: set ft=sh

set -e

# task script is in resource-tutorial/10_job_inputs/ folder
# application input is in resource-app/ folder
cd resource-app

export GOPATH=$(dirname $(realpath $0))/Godeps/_workspace

go test ./...
