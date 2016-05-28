#!/bin/bash

version=$(cat pivnet-stemcells/version)
release_type=$(cat pivnet-stemcells/metadata.json | jq -r ".release.release_type")
description=$(cat pivnet-stemcells/metadata.json | jq -r ".release.description")

echo $release_type
echo $description

cat > pivnet-message/message << EOF
*${release_type}* ${version}
${description}
https://network.pivotal.io/products/${slug}
$(cat pivnet-stemcells/metadata.json | jq .)
EOF
