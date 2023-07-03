#!/bin/sh

PARENT=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
VER="1.0.0.dmg"
JSON="../dmg-builds/build-marker-data-dmg.json"
OUTPUT="../dmg-builds/dmg-output/Marker Data_"

cd "$PARENT"
for file in ../dmg-builds/dmg-output/*.dmg; do
    mv -- "$file" "${file%.dmg}.old"
done
rm -rf ../dmg-output/*.old
appdmg "$JSON" "$OUTPUT""$VER"