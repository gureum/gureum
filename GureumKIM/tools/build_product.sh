#!/bin/bash
. ready.sh

rm "build/$CONFIGURATION/$pkgname.pkg" "build/$CONFIGURATION/$pkgname.app.tar.gz"
rm "build/$CONFIGURATION/*.app/Contents/Info.plist"

xcodebuild -project 'CharmIM.xcodeproj' -target 'Gureum' -configuration "$CONFIGURATION" && \
cd "build/$CONFIGURATION" && \
productbuild --product "../../GureumKIM/tools/preinst.plist" --component "$appname" '/Library/Input Methods' --sign "Developer ID Installer: YunWon Jeong" "$pkgname.pkg" && \
tar -zcf "$pkgname.app.tar.gz" "$appname"

