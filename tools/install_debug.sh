#!/bin/bash
. ready.sh
if [ $? -ne 0 ]; then
    exit 255
fi

xcodebuild -workspace 'Gureum.xcworkspace' -scheme 'OSX' -configuration 'Debug' && \
cd 'build/Debug' && \
sudo rm -rf "$INSTDIR/$appname" && \
sudo cp -R "$appname" "$INSTDIR/"
sudo killall -15 Gureum
