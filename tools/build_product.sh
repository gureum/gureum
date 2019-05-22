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

APP_KEY="3rd Party Mac Developer Application: YunWon Jeong"
INSTALLER_KEY="3rd Party Mac Developer Installer: YunWon Jeong"
DEVELOPER_KEY="Developer ID Installer: YunWon Jeong"

BUILT_PRODUCT_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

rm ~/Downloads/"$PACKAGE_NAME.pkg" ~/Downloads/"$PACKAGE_NAME.app.tar.gz"
rm -rf "${BUILT_PRODUCT_PATH}"

(xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "$CONFIGURATION" | xcpretty) && \
productbuild --product "tools/preinst.plist" --component "${BUILT_PRODUCTS_DIR}/$PRODUCT_NAME.app" '/Library/Input Methods' ~/Downloads/"$PACKAGE_NAME.pkg"
#tar -zcf "$PACKAGE_NAME.app.tar.gz" "$PRODUCT_NAME.app"

cat "${BUILT_PRODUCT_PATH}/Contents/Info.plist" | grep Copyright
