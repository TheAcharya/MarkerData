#!/bin/bash

PARENT=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
APP="../dmg-builds/latest-build/Uninstall Marker Data.app"
SCRIPT="../dmg-builds/uninstaller/include/Uninstall Marker Data.scpt"
ICON="../dmg-builds/uninstaller/include/applet.icns"

cd "$PARENT"
rm -rf "$APP"
osacompile -x -o "$APP" "$SCRIPT"
cp "$ICON" "$APP"/Contents/Resources/applet.icns
xattr -cr "$APP"
codesign --verbose --force --sign "The Acharya" "$APP"
codesign -dv --verbose=4 "$APP"
