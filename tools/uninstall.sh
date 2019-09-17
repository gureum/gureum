#!/bin/bash

run_with_echo() {
  echo "$@" && eval "$@" || exit $?
}

run_with_echo sudo rm -rf "\"/Library/Input Methods/Gureum.app\""
run_with_echo sudo killall -15 "\"Gureum\""
