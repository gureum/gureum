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
    echo "run archive and put archive path as 1st argument" >&2
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "unexisting path: $1" >&2
    exit 1
fi

if [ ! -e "$ZIP_PATH" ] || [ ! -e "$PKG_PATH" ]; then
    echo "The given path doesn't include .zip or .pkg" >&2
    echo "  app: $ZIP_PATH" >&2
    echo "  pkg: $PKG_PATH" >&2
    exit 1
fi

echo "Apple login ID is required to notarize products"
echo -n "Apple ID> "

read -r apple_id

echo "Notarizing app..."
cmd=(xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -itc_provider 9384JEL3M9 -f "${ZIP_PATH}")
echo "${cmd[@]}"
if ! "${cmd[@]}"; then
    echo "Signing app failed: ${ZIP_PATH}" >&2
    exit $?
fi

echo "Notarizing pkg..."
cmd=(xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -f "$PKG_PATH")
echo "${cmd[@]}"
if ! "${cmd[@]}"; then
    echo "Signing pkg failed: ${PKG_PATH}" >&2
    exit $?
fi

mv "$PKG_PATH" ~/Downloads/
