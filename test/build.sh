#!/bin/bash

set -eu
set -x


for tutorial in tutorials/{basic,miscellaneous}/*
do
  if [ -x ${tutorial}/test.sh ]; then
    echo "--- ${tutorial} ---"
    ./${tutorial}/test.sh
  fi
done

