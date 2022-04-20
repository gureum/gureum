# This is post-archive script in Xcode.
# This file is not intended to be run from shell.
set -o pipefail

if [ ! "${ARCHIVE_PATH}" ]; then
    SCRIPT_DIR="$(dirname "$0")"
    # shellcheck source=tools/ready.sh
    . "${SCRIPT_DIR}/ready.sh" || exit $?
    echo "Archive directory path>" && read -r ARCHIVE_PATH
fi

EXPORT_PATH="$BUILT_PRODUCTS_DIR/Export"
/usr/bin/xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportOptionsPlist "$SRCROOT/tools/ExportOptions.plist" -exportPath "$EXPORT_PATH"

XCVERSION="$(cat "$SRCROOT/OSX/Version.xcconfig")"
PACKAGE_NAME="Gureum-${XCVERSION#VERSION = }"

APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"
ZIP_PATH="$EXPORT_PATH/$PACKAGE_NAME.zip"
PKG_PATH="$EXPORT_PATH/$PACKAGE_NAME.pkg"

# Create a ZIP archive suitable for altool.
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

# Create a pkg
INSTALLER_KEY="Developer ID Installer: YunWon Jeong"
productbuild --product "$SRCROOT/tools/preinst.plist" --component "${APP_PATH}" '/Library/Input Methods' --sign "${INSTALLER_KEY}" "${PKG_PATH}"

echo "$EXPORT_PATH" | pbcopy

# As a convenience, open the export folder in Finder.
/usr/bin/open "$EXPORT_PATH"
