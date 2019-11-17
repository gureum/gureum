#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155
set -o pipefail

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Release'
fi

SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

# shellcheck disable=2034
APPLICATION_KEY="Developer ID Application: YunWon Jeong"
INSTALLER_KEY="Developer ID Installer: YunWon Jeong"

ZIP_PATH=$1/Gureum.zip
APP_PATH=$1/Gureum.app

if [ ! "$1" ]; then
    echo "run archive and put archive path as 1st argument"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "unexisting path: $1"
    exit 1
fi

if [ ! -e "$ZIP_PATH" ] || [ ! -e "$APP_PATH" ]; then
    echo "The given path doesn't include .zip or .app $ZIP_PATH $APP_PATH"
    exit 1
fi

PKG_PATH=~/"Downloads/${PACKAGE_NAME}.pkg"

productbuild --product "tools/preinst.plist" --component "${APP_PATH}" '/Library/Input Methods' \
    --sign "${INSTALLER_KEY}" "${PKG_PATH}"

grep Copyright "${APP_PATH}/Contents/Info.plist"

echo "Apple login ID is required to notarize products"
echo "Apple ID>"

read -r apple_id

echo "Notarizing app..."
xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -itc_provider 9384JEL3M9 -f "${ZIP_PATH}"

echo "Notarizing pkg..."
xcrun altool --notarize-app -t osx --primary-bundle-id org.youknowone.inputmethod.Gureum \
    -u "$apple_id" -p @keychain:developer.apple.com -f "$PKG_PATH"
