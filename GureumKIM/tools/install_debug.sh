#!/bin/bash
. ready.sh

xcodebuild -workspace 'CharmIM.xcworkspace' -scheme 'GureumKIM' -configuration 'Debug' && \
cd 'build/Debug' && \
sudo rm -rf "$INSTDIR/$appname" && \
sudo cp -R "$appname" "$INSTDIR/"
sudo killall Gureum
