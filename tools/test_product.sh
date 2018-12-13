#!/bin/bash
SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`
. "${SCRIPT_DIR}/ready.sh" || exit $?

sudo installer -pkg ~/Downloads"/$PACKAGE_NAME.pkg" -target '/' && sudo killall Gureum
