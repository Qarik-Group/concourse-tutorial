#!/bin/bash

set -eu

cd ${REPO_ROOT:?required}

if [[ "${FLY_CACERT:-X}" == "X" ]]; then
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main
else
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main \
      --ca-cert       ${FLY_CACERT}
fi

credhub login \
      --server  ${CREDHUB_URL:?required} \
      --ca-cert ${CREDHUB_CACERT:?required} \
      --username ${CREDHUB_USERNAME:?required} \
      --password ${CREDHUB_PASSWORD:?required}

export fly_target=tutorial

./tutorials/test-pipeline-vars.sh

for f in tutorials/*/*/test.sh
do
  echo "\n\n\nlesson $f\n"
  pushd `dirname $f`
  ./test.sh
  popd
done
