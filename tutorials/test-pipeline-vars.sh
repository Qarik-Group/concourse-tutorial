#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

credman=${credmanager:-credhub}
case $credman in
  credhub)
    cmdget="credhub get -n"
    cmddel="credhub delete -n"
    ;;
  vault)
    cmdget="safe get"
    cmddel="safe delete"
    ;;
esac

team=${team:-concourse-tutorial}
variables=$(cat */*/pipeline*.yml | grep "((" | awk '{print $2}' | sed -e "s%((%%" | sed -e "s%)).*%%" | sort | uniq)
errors=
for var in $variables; do
  if [[ "$var" == "cat-name" || "$var" == "dog-name" ]]; then
      if ${cmdget} /concourse/$team/$var >/dev/null 2>/dev/null ; then
        echo "Deleting variable /concourse/$team/$var as it is expected to be missing"
        ${cmddel} /concourse/$team/$var
      fi
  else
    if ! ${cmdget} /concourse/$team/$var >/dev/null 2>/dev/null &&
       ! ${cmdget} /concourse/$team/tutorial-pipeline/$var >/dev/null 2>/dev/null ; then
      echo "Not found $var"
      errors=1
    fi

  fi
done

if [[ "${errors}" == "1" ]]; then
  echo "Variables missing"
  exit 1
fi
