#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

variables=$(cat */*/pipeline*.yml | grep "((" | awk '{print $2}' | sed -e "s%((%%" | sed -e "s%)).*%%" | sort | uniq)
errors=
for var in $variables; do
  if ! credhub get -n /concourse/main/$var >/dev/null 2>/dev/null ; then
    echo "Not found $var"
    errors=1
  fi
done

if [[ "${errors}" == "1" ]]; then
  echo "Variables missing"
  exit 1
fi