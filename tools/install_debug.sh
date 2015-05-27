#!/bin/bash
. ready.sh

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration 'Debug' && \
cd 'build/Debug' && \
sudo rm -rf "$INSTDIR/$appname" && \
sudo cp -R "$appname" "$INSTDIR/"
sudo killall -15 Gureum
