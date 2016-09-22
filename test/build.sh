#!/bin/bash

set -e
# set -x


for file in *
do
  if [ -x ${file}/run.sh ]; then
    echo "--- ${file} ---"
    ./${file}/run.sh
  fi
done

# ./01_*/run.sh
# ./02_*/run.sh
# ./03_*/run.sh
# ./06_*/run.sh
# ./07_*/run.sh simple
# ./07_*/run.sh renamed
# ./08_*/run.sh
# ./09_*/run.sh ls-abc-xyz
# ./09_*/run.sh ls-abc
# ./09_*/run.sh pretty-ls
# ./10_*/run.sh

# # ./12_*/run.sh credentials.yml

./20_*/run.sh credentials.yml get-version
./20_*/run.sh credentials.yml display-version
./20_*/run.sh credentials.yml rename-resource
./20_*/run.sh credentials.yml bump-minor
./20_*/run.sh credentials.yml bump-rc-save
./20_*/run.sh credentials.yml bump-save-no-trigger

./35_*/run.sh credentials.yml
./36_*/run.sh credentials.yml

./40_*/run.sh credentials.yml
