#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155

if [ ! $CONFIGURATION ]; then
	CONFIGURATION='Release'
fi
SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`
. "${SCRIPT_DIR}/ready.sh" || exit $?

if [ $CONFIGURATION != 'Release' ]; then
    echo "Configuration is not Release: $CONFIGURATION"
    echo "Keep going?"
    read
fi

APPLICATION_KEY="Developer ID Application: YunWon Jeong"
INSTALLER_KEY="Developer ID Installer: YunWon Jeong"

BUILT_PRODUCT_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

rm ~/Downloads/"$PACKAGE_NAME.pkg"
rm -rf "${BUILT_PRODUCT_PATH}"

(xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "$CONFIGURATION" | xcpretty) && \
productbuild --product "tools/preinst.plist" --component "${BUILT_PRODUCTS_DIR}/$PRODUCT_NAME.app" '/Library/Input Methods' --sign "$INSTALLER_KEY" ~/Downloads/"$PACKAGE_NAME.pkg"
#tar -zcf "$PACKAGE_NAME.app.tar.gz" "$PRODUCT_NAME.app"

cat "${BUILT_PRODUCT_PATH}/Contents/Info.plist" | grep Copyright
