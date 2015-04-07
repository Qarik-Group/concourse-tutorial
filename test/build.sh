#!/bin/bash

set -e
# set -x

export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Concourse API $ATC_URL"

# pushd 01_*
# fly execute -c task_hello_world.yml
# popd
# fly configure
#
#
# pushd 02_*
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-hello-world/builds -X POST
# fly watch -j job-hello-world
# popd
#
# pushd 03_*
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-hello-world/builds -X POST
# fly watch -j job-hello-world
# popd
#
# pushd 06_*
# yes y | fly configure -c pipeline.yml
# # verify pipeline config
# popd
#
# pushd 07_*
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-hello-world/builds -X POST
# fly watch -j job-hello-world
# popd
#
# pushd 08_*
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-fetch-resource/builds -X POST
# fly watch -j job-fetch-resource
# fly watch -j job-run-task
# popd
#
# pushd 10_*
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-deploy-app/builds -X POST
# fly watch -j job-deploy-app
# popd
#
pushd 11_*
spiff merge templates/pipeline-final.yml templates/pipeline-base.yml ../stub.yml > pipeline.yml
yes y | fly configure -c pipeline.yml
curl $ATC_URL/jobs/job-deploy-app/builds -X POST
fly watch -j job-deploy-app
popd

# pushd 12_*
# spiff merge templates/pipeline-final.yml templates/pipeline-base.yml ../stub.yml > pipeline.yml
# yes y | fly configure -c pipeline.yml
# curl $ATC_URL/jobs/job-test-deploy-app/builds -X POST
# fly watch -j job-test-deploy-app
# popd
