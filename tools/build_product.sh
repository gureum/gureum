#!/bin/bash
#https://discuss.atom.io/t/sandbox-supposedly-enabled-but-application-loader-disagrees/26155
. ready.sh

APP_KEY="3rd Party Mac Developer Application: YunWon Jeong"
INSTALLER_KEY="3rd Party Mac Developer Installer: YunWon Jeong"
DEVELOPER_KEY="Developer ID Installer: YunWon Jeong"

rm "build/$CONFIGURATION/$pkgname.pkg" "build/$CONFIGURATION/$pkgname.app.tar.gz"
rm "build/$CONFIGURATION/Gureum.app/Contents/Info.plist"

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "$CONFIGURATION" && \
cd "build/$CONFIGURATION" && \
productbuild --product "../../tools/preinst.plist" --component "$appname" '/Library/Input Methods' --sign "Developer ID Installer: YunWon Jeong" "$pkgname.pkg" && \
tar -zcf "$pkgname.app.tar.gz" "$appname"

cat "Gureum.app/Contents/Info.plist" | grep Copyright
