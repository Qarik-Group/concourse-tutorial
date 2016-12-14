#!/bin/sh

set -uex

output_manifest=$1; shift
if [[ "${output_manifest}X" == "X" ]]; then
  echo "USAGE: spiff-merge-and-save manifest.yml [args.yml to.yml spiff.yml merge.yml]"
  exit 1
fi


mkdir -p `dirname $output_manifest`
spiff merge $@ > $output_manifest
