#!/bin/bash

function black() {
    echo -e "\e[30m${1}\e[0m"
}

function red() {
    echo -e "\e[31m${1}\e[0m"
}

function green() {
    echo -e "\e[32m${1}\e[0m"
}

function yellow() {
    echo -e "\e[33m${1}\e[0m"
}

function blue() {
    echo -e "\e[34m${1}\e[0m"
}

function magenta() {
    echo -e "\e[35m${1}\e[0m"
}

function cyan() {
    echo -e "\e[36m${1}\e[0m"
}

function gray() {
    echo -e "\e[90m${1}\e[0m"
}

black 'BLACK'
red 'RED'
green 'GREEN'
yellow 'YELLOW'
blue 'BLUE'
magenta 'MAGENTA'
cyan 'CYAN'
gray 'GRAY'
