#!/bin/bash
. ready.sh

xcodebuild -project 'CharmIM.xcodeproj' -target 'Gureum' -configuration 'Debug' && \
cd 'build/Debug' && \
sudo rm -rf "$INSTDIR/$appname" && \
sudo cp -R "$appname" "$INSTDIR/"
sudo killall Gureum
