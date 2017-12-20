#!/bin/bash

set -eu

echo
echo "$ fly --target tutorial login"
if [[ "${FLY_CACERT:-X}" == "X" ]]; then
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main
else
  echo "$FLY_CACERT" > fly.cacert
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main \
      --ca-cert       fly.cacert
fi
fly -t tutorial sync

echo
echo "$ credhub login"
echo "${CREDHUB_CACERT:?required}" > credhub.cacert
credhub login \
      --server  ${CREDHUB_URL:?required} \
      --ca-cert credhub.cacert \
      --username ${CREDHUB_USERNAME:?required} \
      --password ${CREDHUB_PASSWORD:?required}

export fly_target=tutorial

cd ${REPO_ROOT:?required}

echo
echo "$ tutorials/test-pipeline-vars.sh"
./tutorials/test-pipeline-vars.sh

echo
for f in tutorials/*/*/test.sh
do
  echo "\n\n\nlesson $f\n"
  pushd `dirname $f`
  ./test.sh
  popd
done
