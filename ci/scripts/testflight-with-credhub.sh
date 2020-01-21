#!/bin/bash

set -eu

curl -o fly "${FLY_URL:?required}/api/v1/cli?arch=amd64&platform=linux"
chmod +x fly
mv fly $(which fly)

echo
echo "$ fly --target tutorial login"
if [[ "${FLY_CACERT:-X}" == "X" ]]; then
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name     ${FLY_TEAM:?required}
else
  echo "$FLY_CACERT" > fly.cacert
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name     ${FLY_TEAM:?required}
      --ca-cert       fly.cacert
fi

credman=${credmanager:-credhub}
case $credman in
  credhub)
    echo
    echo "$ credhub login"
    echo "${CREDHUB_CACERT:?required}" > credhub.cacert
    credhub login \
          --server  ${CREDHUB_URL:?required} \
          --ca-cert credhub.cacert \
          --username ${CREDHUB_USERNAME:?required} \
          --password ${CREDHUB_PASSWORD:?required}
    ;;
  vault)
    echo
    echo "$ vault login"
    safe target -k ${VAULT_TARGET} lab
    echo -e "${VAULT_ROLEID}\n${VAULT_SECRETID}" | safe auth approle
    ;;
esac

export fly_target=tutorial

cd ${REPO_ROOT:?required}

echo
echo "$ tutorials/test-pipeline-vars.sh"
./tutorials/test-pipeline-vars.sh

echo
for f in tutorials/*/*/test{,-need-parameters}.sh
do
  echo "\n\n\nlesson $f\n"
  pushd `dirname $f`
  if [[ -x ./test.sh ]]; then
    ./test.sh
  else
    ./test-need-parameters.sh
  fi
  popd
done
