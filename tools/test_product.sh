#!/bin/bash

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Release'
fi
SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

sudo installer -pkg ~/Downloads/"${PACKAGE_NAME}.pkg" -target '/' && sudo killall Gureum
