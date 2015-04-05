#!/bin/bash

set -e


export ATC_URL=${ATC_URL:-"http://192.168.100.4:8080"}
echo "Concourse API $ATC_URL"

# pushd 01_*
# fly execute -c task_hello_world.yml
# popd
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

pushd 08_*
yes y | fly configure -c pipeline.yml
curl $ATC_URL/jobs/job-hello-world/builds -X POST
fly watch -j job-hello-world
popd
