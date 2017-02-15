#!/bin/bash
#
# Functions for pretty output
#


export CF_COLOR=true
RCol='\033[0m'
BCya='\033[1;36m'
BGre='\033[1;32m'
BRed='\033[1;31m'
BWhi='\033[1;37m'
BYel='\033[1;33m'
Cya='\033[0;36m'
Gre='\033[0;32m'
Red='\033[0;31m'
Yel='\033[0;33m'

function announce-started {
  echo -e "\n\n${BCya}---"
  echo -e "${BCya}${0} started."
  echo -e "${BCya}---${RCol}"
  echo
  echo
}

function announce-task {
  echo -e "\n\n${BWhi}---"
  echo -e "${BWhi}${1}"
  echo -e "${BWhi}---${RCol}"
}

function announce-success {
  echo -e "${BGre}Mission accomplished.${RCol}"
}

function debug {
  echo -e "${BYel}DEBUG: ${1}${RCol}"
}

function run-cmd {
  echo -e "\n\n${Cya}${@}${RCol}\n"
  $@
}

function fail-error {
  echo -e "\n\n${BRed}ERROR: ${Red}${@} ${BRed}Exiting.\n${RCol}"
  exit -1
}
