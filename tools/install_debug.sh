#!/bin/bash

run_with_echo() {
    echo "$@" && eval "$@" || exit $?
}

SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

(xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "${CONFIGURATION}" | xcpretty) || exit $?
if [ ! "${INSTALL_PATH}" ]; then
    echo "something wrong" && exit 255
fi

/usr/bin/codesign --force --sign - --entitlements "${CONFIGURATION_TEMP_DIR}/OSX.build/Gureum.app.xcent" --timestamp=none "${TARGET_BUILD_DIR}/Gureum.app"

run_with_echo sudo rm -rf "\"${INSTALL_PATH}/${PRODUCT_NAME}.app\""
run_with_echo sudo cp -R "\"${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app\"" "\"${INSTALL_PATH}/\""
run_with_echo sudo killall -15 "\"${PRODUCT_NAME}\""
