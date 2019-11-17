#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155
set -o pipefail

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Release'
fi

SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

ZIP_PATH=$1/${PACKAGE_NAME}.zip
PKG_PATH=$1/${PACKAGE_NAME}.pkg

if [ ! "$1" ]; then
    echo "run archive and put archive path as 1st argument"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "unexisting path: $1"
    exit 1
fi

if [ ! -e "$ZIP_PATH" ] || [ ! -e "$PKG_PATH" ]; then
    echo "The given path doesn't include .zip or .pkg $ZIP_PATH $PKG_PATH"
    exit 1
fi

echo "Apple login ID is required to notarize products"
echo -n "Apple ID> "

read -r apple_id

echo "Notarizing app..."
xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -itc_provider 9384JEL3M9 -f "${ZIP_PATH}"

echo "Notarizing pkg..."
xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -f "$PKG_PATH"

mv "$PKG_PATH" ~/Downloads/
