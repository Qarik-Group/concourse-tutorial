#!/bin/bash

set -e
# set -x


for tutorial in tutorials/{basic,miscellaneous}/*
do
  if [ -x ${tutorial}/run.sh ]; then
    echo "--- ${tutorial} ---"
    ./${tutorial}/run.sh
  fi
done

