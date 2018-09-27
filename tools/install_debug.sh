#!/bin/bash

SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`
. "${SCRIPT_DIR}/ready.sh" || exit $?

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "${CONFIGURATION}" || exit $?
if [ ! "${INSTALL_PATH}" ]; then
    echo "something wrong" && exit 255
fi

cmd="sudo rm -rf \"${INSTALL_PATH}/${PRODUCT_NAME}.app\""
echo ${cmd} && eval ${cmd} || exit $?
cmd="sudo cp -R \"${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app\" \"${INSTALL_PATH}/\""
echo ${cmd} && eval ${cmd} || exit $?
cmd="sudo killall -15 \"${PRODUCT_NAME}\""
echo ${cmd} && eval ${cmd} || exit $?
