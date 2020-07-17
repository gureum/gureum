#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155
set -o pipefail

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Release'
fi

SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

PKG_PATH=~/Downloads/${PACKAGE_NAME}.pkg

spctl -a -vvv -t install "${PKG_PATH}"
