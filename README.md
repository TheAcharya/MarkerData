<p align="center">
  <a href="https://github.com/TheAcharya/MarkerData"><img src="assets/marker_data_app_icon.png" height="200">
  <h1 align="center">Marker Data</h1>
</p>


<p align="center"><a href="https://github.com/TheAcharya/MarkerData/blob/main/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="license"/></a>&nbsp;<a href="https://github.com/TheAcharya/MarkerData"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/></a>&nbsp;<a href="https://github.com/TheAcharya/MarkerData/actions/workflows/build.yml"><img src="https://github.com/TheAcharya/MarkerData/actions/workflows/build.yml/badge.svg" alt="build"/></a>&nbsp;<a href="Github All Releases"><img src="https://img.shields.io/github/downloads/TheAcharya/MarkerData/total.svg" alt="release_github"/></a></p>

Marker Data allows users to extract, convert & create databases from <a href="https://www.apple.com/final-cut-pro/" target="_blank">Final Cut Pro</a>’s Marker metadata effortlessly. Marker Data uses <a href="https://github.com/TheAcharya/MarkersExtractor" target="_blank">MarkersExtractor</a> Library.

## Core Features

- Functionality allowing batch extraction and rendering of stills or animated GIFs based on each Marker's timecode.
- Automatically analyse and embed colour swatches from extracted images for shot reference.
- Integrates with Final Cut Pro, boasting a native Share Destination & Workflow Extension.
- Precise extraction of Markers, ensuring an accurate representation of metadata.
- Native integration with renowned databases such as [Notion](https://www.notion.so) and [Airtable](https://www.airtable.com).
- Effortlessly synchronise Final Cut Pro's Marker metadata to cloud databases with a single click.
- Versatile features for batch burning-in labels, embedding comprehensive metadata of each Marker onto stills or animated GIFs.
- Comprehensive timeline functionality, encompassing support for timelines such as Projects and Compound Clips.
- Allows the creation of multiple configurations tailored to diverse project requirements.
- Harnesses the potential to utilise Captions as Markers, adding a layer of flexibility.
- Convert Markers into shareable, professional PDFs via Pagemaker.
- Written in Apple Swift language and SwiftUI framework.
- Application is Notarised by Apple.

## Avaliable Extract Profiles

- Notion (JSON)
- Airtable (JSON)
- Comma-separated values (CSV) - Compatible with spreadsheet applications
- Tab-separated values (TSV) - Compatible with spreadsheet application
- Microsoft Excel (XLSX)
- YouTube Chapters (TXT)
- Standard MIDI File - Compatible with most audio DAWs

## Table of contents
- [Demo](#demo)
- [Screenshot](#screenshot)
- [System Requirements](#system-requirements)
- [Download](https://github.com/TheAcharya/MarkerData/releases)
- [Installation](#installation)
- [Use Cases](#use-cases)
- [Featured](#Featured)
- [Credits](#Credits)
- [License](#License)
- [Reporting Bugs](#reporting-bugs)

## Demo

<details><summary>Send to Notion</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-send-to-notion-03.gif?raw=true"> </p>
</p>
</details>

<details><summary>Send to Airtable</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-send-to-airtable-03.gif?raw=true"> </p>
</p>
</details>

<details><summary>Send to Logic Pro</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-send-to-midi-02.gif?raw=true"> </p>
</p>
</details>

<details><summary>Create YouTube Chapters</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-send-to-youtube-02.gif?raw=true"> </p>
</p>
</details>

<details><summary>Creating Shot Library</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-creating-shot-library-03.gif?raw=true"> </p>
</p>
</details>

<details><summary>Creating PDF</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-pagemaker-creating-pdf-02.gif?raw=true"> </p>
</p>
</details>

<details><summary>Utilising Workflow Extension</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-workflow-extension-roles.gif?raw=true"> </p>
</p>
</details>

<details><summary>Queue in Action</summary>
<p>
<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-queue-01.gif?raw=true"> </p>
</p>
</details>

## Screenshot

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-main-share.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-queue.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-general-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-image-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-image-settings-swatch.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-label-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-label-overlays-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-configuration-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-database-settings.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-workflow-extension-extract.png?raw=true"> </p>

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-workflow-extension-roles.png?raw=true"> </p>

<p align="center"> <img src="https://raw.githubusercontent.com/TheAcharya/MarkerData-Website/refs/heads/main/docs/assets/md-pagemaker.png?raw=true"> </p>

## System Requirements

macOS Sonoma 14.7 or later <br> Final Cut Pro 11.0 or later <br> Runs only on Apple silicon Macs <br> Internet connection is necessary for some modules and functionality

## Installation

<p align="center"> <img src="https://github.com/TheAcharya/MarkerData-Website/blob/main/docs/assets/md-install.png?raw=true"> </p>

1. Download the DMG to your system.
2. Mount the DMG by double-clicking it.
3. Move Marker Data to your Applications folder.
4. Launch Marker Data.
5. Read Onboarding information and instructions.
6. Create your first [Configuration](https://markerdata.theacharya.co/user-guide/configurations/).
7. Start using Marker Data and have fun!

> [!WARNING]  
> Marker Data must be installed in the Applications folder to run correctly. Running the application outside of this designated directory would result in functionality issues.

## Use Cases
- Marker Notes Database
- Shot Library Database
- VFX Database
- ADR Database
- Stock Footage Database
- Music Cue Sheet Database
- Colourist’s Notes Database
- Client Review & Tracking Database
- Offline & Online Notes Database
- Send Final Cut Pro's Markers to DAWs
- Create YouTube Chapters
- Create PDFs via Pagemaker

## Featured

- [FCP Cafe](https://fcp.cafe/ecosystem/tools/#marker-data)
- [Newsshooter](https://www.newsshooter.com/2024/07/10/marker-data-for-final-cut-pro/)
- [ProVideo Coalition](https://www.provideocoalition.com/marker-data-a-quick-look/)

## Credits

Original Idea, Application Direction and Workflow Architecture by [Vigneswaran Rajkumar](https://bsky.app/profile/vigneswaranrajkumar.com)

**Graphical User Interface and UI/UX Logic**

Maintained by [Milán Várady](https://github.com/milanvarady) (1.0.0 ...)

**MarkersExtractor (CLI & Library)**

Maintained by [Steffan Andrews](https://github.com/orchetect) ([0.2.0 ...](https://github.com/TheAcharya/MarkersExtractor))

**App Icon**

Icon Design by [Bor Jen Goh](https://www.artstation.com/borjengoh)

## License

Licensed under the MIT license. See [LICENSE](https://github.com/TheAcharya/MarkerData/blob/main/LICENSE) for details.

## Reporting Bugs

Technical support questions are best asked in the [Discussions](https://github.com/TheAcharya/MarkerData/discussions).

For bug reports, feature requests and other suggestions you can create a new [issue](https://github.com/TheAcharya/MarkerData/issues) to discuss.
