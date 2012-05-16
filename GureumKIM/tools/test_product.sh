#!/bin/bash
. ready.sh

installer -pkg "build/Release/$pkgname.pkg" -target '/'
sudo killall Gureum