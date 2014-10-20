#!/bin/bash
. ready.sh

rm "build/$CONFIGURATION/$pkgname.pkg" "build/$CONFIGURATION/$pkgname.app.tar.gz"
rm "build/$CONFIGURATION/*.app/Contents/Info.plist"

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration "$CONFIGURATION" && \
cd "build/$CONFIGURATION" && \
productbuild --product "../../OSX/tools/preinst.plist" --component "$appname" '/Library/Input Methods' --sign "Developer ID Installer: YunWon Jeong" "$pkgname.pkg" && \
tar -zcf "$pkgname.app.tar.gz" "$appname"

