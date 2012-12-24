#!/bin/bash
. ready.sh

rm "$pkgname.pkg" "$pkgname.app.tar.gz"

xcodebuild -project 'CharmIM.xcodeproj' -target 'Gureum' -configuration "$CONFIGURATION" && \
cd "build/$CONFIGURATION" && \
productbuild --component "$appname" '/Library/Input Methods' "$pkgname.pkg" && \
tar -zcf "$pkgname.app.tar.gz" "$appname"

