#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DIR="$DIR/${1}"
export fly_target=${fly_target:-tutorial}
echo "Concourse API target ${fly_target}"
echo "Tutorial $(basename $DIR)"


for file in $(find ${1} -type f -iname *.yml); do
  if [ -f "$file" ]; then
    name=$(echo $file | cut -d "/" -f 2)
    pushd $DIR
      fly -t ${fly_target} execute -c $name
    popd
  fi
done
