#!/bin/bash


#COLOR_RED='\033[0;31m'
#COLOR_RED='\033[1;31m'
# Use 1 for Bold and 0 for Normal! 
# For background color change, use numbers 40-47

export COLOR_RED='\e[0;31m'
export COLOR_BLUE='\e[0;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_YELLOW='\e[0;33m'
export COLOR_WHITE='\e[0;37m'
export COLOR_CYAN='\e[0;36m'
export COLOR_MAGNETA='\e[0;35m'
export COLOR_BLACK='\e[0;30m'
export COLOR_RESET='\e[0m'


function errorline() {
  echo -e "$COLOR_RED ${1}"
}

function successline(){
  echo -e "$COLOR_GREEN ${1}"
}

function infoline() {
  echo -e "$COLOR_BLUE ${1} $COLOR_RESET"
}

function warnline() {
  echo -e "$COLOR_YELLOW ${1}"
}

function fatalline() {
  echo -e "$COLOR_RED ${1}"
  # exit 1
}

function normalline() {
  echo -e "$COLOR_WHITE ${1}"
}

export -f errorline
export -f successline 
export -f infoline 
export -f warnline 
export -f fatalline
export -f normalline 


