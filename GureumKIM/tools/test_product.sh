#!/bin/bash
. ready.sh

installer -pkg "build/$CONFIGURATION/$pkgname.pkg" -target '/'
sudo killall Gureum