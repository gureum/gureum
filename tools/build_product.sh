#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155
set -o pipefail

if [ ! "${CONFIGURATION}" ]; then
    CONFIGURATION='Release'
fi
SCRIPT_DIR="$(dirname "$0")"
# shellcheck source=tools/ready.sh
. "${SCRIPT_DIR}/ready.sh" || exit $?

if [ "${CONFIGURATION}" != 'Release' ]; then
    echo "Configuration is not Release: ${CONFIGURATION}"
    echo "Keep going?"
    read -r
fi

BUILT_PRODUCT_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

rm ~/Downloads/"${PACKAGE_NAME}.pkg"
rm -rf "${BUILT_PRODUCT_PATH}"

if command -v xcpretty >/dev/null; then
    PRINTER="xcpretty"
else
    PRINTER="cat"
fi

(xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "${CONFIGURATION}" | $PRINTER) && \
productbuild --product "tools/preinst.plist" --component "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app" '/Library/Input Methods' ~/Downloads/"${PACKAGE_NAME}.pkg"
#tar -zcf "${PACKAGE_NAME}.app.tar.gz" "${PRODUCT_NAME}.app"

grep Copyright "${BUILT_PRODUCT_PATH}/Contents/Info.plist"
