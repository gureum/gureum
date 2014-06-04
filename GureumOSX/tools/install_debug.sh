#!/bin/bash
. ready.sh

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'GureumOSX' -configuration 'Debug' && \
cd 'build/Debug' && \
sudo rm -rf "$INSTDIR/$appname" && \
sudo cp -R "$appname" "$INSTDIR/"
sudo killall -15 Gureum
