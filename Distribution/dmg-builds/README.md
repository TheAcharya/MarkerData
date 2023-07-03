# README

1. **Install** - https://github.com/LinusU/node-appdmg
2. I have placed temporary codesign signatures in both “**build-uninstall-marker-data.sh**” and “**build-marker-data-dmg.json”**
3. To build “Uninstall Marker Data.app”, simply, **sh “build-uninstall-marker-data.sh**” in terminal.
4. **Place** your latest build of “**Marker Data.app**” in “**latest-build**” folder.
5. Change the text of “**VER="1.0.0.dmg"** in “build-marker-data-dmg.sh” whenever required. Example - “**VER=“1.0.1.dmg**”
6. To build our .dmg distribution, simply, **sh “build-marker-data-dmg.sh**” in terminal.
7. I have pre-configured “build-marker-data-dmg.json” for the best layout of the .dmg.
8. You might need to update the code signatures in both “build-uninstall-marker-data.sh” and “build-marker-data-dmg.json”
9. You can further tweak and optimise the .sh scripts if required.
10. You can also further tweak and optimise “Uninstall Marker Data.scpt” if required.