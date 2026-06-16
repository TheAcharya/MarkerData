## Overview
**Marker Data** is a macOS SwiftUI application that extracts Final Cut Pro marker metadata and generates export artifacts (CSV/TSV/XLSX/MIDI/Markdown/SRT/YouTube/Compressor, plus Notion/Airtable JSON). It can optionally:
- Render stills / GIFs for markers (via `MarkersExtractor`)
- Compute and render dominant color swatches/palettes into images
- Upload extracted JSON manifests to Notion/Airtable using bundled CLI tools

It also ships two Final Cut Pro integrations:
- **Share Destination**: a scripting-based integration that causes FCP to export media + FCPXML and “open” it into Marker Data.
- **Workflow Extension**: a ProExtensions-hosted extension view that can send an FCPXML to the app (and also exposes Roles selection).

## Targets & modules
### Main app target (`Marker Data`)
Location: `Source/Marker Data/Marker Data/`

Primary responsibilities:
- UI/navigation and settings panels
- Extraction orchestration + progress + notifications
- Local persistence of configurations, DB profiles, and logs
- Queue scanning/uploading previously extracted jobs
- Installing FCP Share Destination templates
- Hosting Pagemaker (WebView) for PDF generation

### Workflow Extension target
Location: `Source/Marker Data/Workflow Extension/`

Responsibilities:
- SwiftUI UI embedded in an `NSViewController` (`WorkflowExtensionViewController`)
- Drag/drop `.fcpxml` into the extension
- Writes a cache file to `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml`
- Opens the main app and posts `DistributedNotificationCenter` event `.workflowExtensionFileReceived`

### Uninstaller target (`Uninstall Marker Data`)
Location: `Source/Marker Data/Marker Data Uninstaller/`

Responsibilities:
- SwiftUI dialog app that removes Marker Data app, caches, preferences, and related paths (see `MarkerDataUninstaller.run()`).
- Product name: `Uninstall Marker Data.app`; display name: “Marker Data Uninstaller”. Bundle ID: `co.theacharya.MarkerData.Uninstaller`.
- Writes a log to `~/Desktop/Marker-Data_Uninstall_Log.txt` (deleted / undeleted paths).
- Built as part of the **Marker Data** scheme; CI copies it from build products into the DMG layout.

### Share Destination / scripting bridge (inside main app bundle)
Location: `Source/Marker Data/Marker Data/FCP Share Destination/`

Responsibilities:
- **Install UI** (Swift) triggers AppleScript to open `.fcpxdest` resources in Final Cut Pro.
- **Objective‑C scripting/doc controller** implements the MediaAssetProtocol shape and the AppleScript `make` command to create “assets” backed by exported files.
- Posts a local notification `FCPShareStart` so the Swift side can re-register Apple Event handlers reliably.

## High-level runtime graph
Constructed at app launch (`Marker_DataApp.swift`):
- `SettingsContainer` (environment object)
- `DatabaseManager` (environment object)
- `ExtractionModel` (observed by Extract UI)
- `QueueModel` (observed by Queue UI)

### Navigation
`ContentView.swift` uses `NavigationSplitView` with sidebar selection:
- Extract
- Queue
- Settings (General/Image/Label/Configurations/Databases)
- About

## Data & persistence
### App Support layout
Defined by `URLExtension.swift` and created/validated by `LibraryFolders.checkAndCreateMissing()`:
- `~/Library/Application Support/Marker Data/`
  - `preferences.json` (current settings store)
  - `Configurations/*.json` (saved configurations)
  - `Database Profiles/Notion/*.json`
  - `Database Profiles/Airtable/*.json`
  - `Database Profiles/Dropbox/dropbox_token.json`
  - `Logs/*.txt`
- `~/Movies/Marker Data Cache/` (FCP export cache + workflow extension handoff file)

### Settings system

Marker Data persists almost all user preferences as versioned JSON. Understanding this system is required before adding or changing any setting.

#### Key types and files

| File | Role |
|------|------|
| `Models/Settings/SettingsStore.swift` | `Codable` value type holding the full settings schema; `static let version` is the **current schema number** (check the file — do not hard-code in docs) |
| `Models/Settings/SettingsContainer.swift` | `@MainActor` `ObservableObject` wrapping the active `store`; loads/saves, manages named configurations, auto-saves on change |
| `Models/Settings/SettingsVersioningManager.swift` | Dict-based migrations run **before** `JSONDecoder` decode |
| `Models/Settings/SettingsModels.swift` | Supporting enums/types used by `SettingsStore` (e.g. `ImageMode`, `FontNameType`) |
| `Models/Settings/MarkersExtractorModelExtensions.swift` | Display-name / `Codable` extensions for MarkersExtractor types |
| `Utilities/Extensions/URLExtension.swift` | Canonical paths under Application Support |

#### What gets persisted where

| Path | Contents |
|------|----------|
| `preferences.json` | **Active** settings — what the app uses right now |
| `Configurations/{name}.json` | **Named configuration presets** (toolbar picker); same schema as `preferences.json` |
| `Database Profiles/` | Notion/Airtable credentials — **separate** from `SettingsStore`; managed by `DatabaseManager` |
| `Resources/DefaultConfiguration.json` | Legacy bundle resource; **not** the live settings source (URL helper exists but is unused) |

Both `preferences.json` and every `Configurations/*.json` file include a `"version"` integer that must match `SettingsStore.version` after migration.

#### Runtime lifecycle (app launch)

```
SettingsContainer.init()
  → SettingsVersioningManager.updateAll()     // migrate JSON dicts on disk
  → load preferences.json into store          // JSONDecoder → SettingsStore
  → load all Configurations/*.json
  → save preferences.json (normalize on disk)
  → subscribe to $store → auto-save on every change
```

Migrations run **synchronously at launch** (via `Task.synchronous`) before any settings are decoded. If migration fails for a file, it is logged; decode may then fail for that file.

#### Schema versioning

- `SettingsStore.version` (static) = schema the **current app code** expects.
- `version` (per JSON file) = schema that file was written with.
- On launch, for each settings JSON: while `file.version < SettingsStore.version`, apply one `upgradeVersion(dict:version:)` step, increment `version`, save file.

Migrations operate on `[String: Any]` dictionaries — **not** on Swift `Codable` — so renames, nested dict updates, and default injection are explicit. Each `case N` in `upgradeVersion` handles the upgrade **from** version `N` **to** `N + 1`.

**Example (v7 → v8):** added `allowUTF8InMIDIExport` with default `false` for existing users.

#### Auto-save and configurations

- SwiftUI views bind to `$settings.store.<property>` via `@EnvironmentObject SettingsContainer`.
- Any change to `store` triggers `saveAsCurrent()` → writes `preferences.json`.
- Named configurations are separate files; **saving a configuration** (`saveCurrentAs`, duplicate, etc.) writes `Configurations/{name}.json`.
- `unsavedChanges` compares in-memory `store` to the on-disk file for the active configuration.
- Configuration CRUD UI uses `ConfigurationsViewModel` as a thin facade over `SettingsContainer`.

#### Bridge to extraction (`markersExtractorSettings`)

Not every `SettingsStore` field maps 1:1 to the UI. Extraction reads settings through:

`SettingsStore.markersExtractorSettings(fcpxmlFileUrl:)` → `MarkersExtractor.Settings`

When adding a setting that affects extraction/export, wire it here (and bump MarkersExtractor dependency if the library adds a new parameter). Example: `allowUTF8InMIDIExport` → `isMIDIFileUTF8EncodingAllowed`.

#### Exception: Roles (`RolesManager`)

FCP role enable/disable is stored in `preferences.json` but **`RolesManager` reads/writes the file directly** (not via `SettingsContainer`) so the Workflow Extension can share the same file. Changes to `roles` must remain compatible with both the main app and the extension; cross-process sync uses `DistributedNotificationCenter` (`.rolesChanged`).

#### Checklist: adding or changing a persisted setting

1. Add property to `SettingsStore` with a default in `defaults()`.
2. **Increment** `SettingsStore.version` by 1.
3. Add `case <previousVersion>:` in `SettingsVersioningManager.upgradeVersion` — inject the new key (use `SettingsStore.defaults()` for default values) or migrate renamed keys.
4. Add UI binding in the appropriate settings view (`Views/Detail Views/...`).
5. If it affects extraction: update `markersExtractorSettings(fcpxmlFileUrl:)`.
6. If it affects MarkersExtractor API: bump the Swift package version in `Marker Data.xcodeproj`.
7. Verify existing `preferences.json` and `Configurations/*.json` on disk upgrade cleanly (definition of done).

**When you must migrate:** new persisted property, renamed JSON key, removed property, changed nested structure, or any change that would break `JSONDecoder` decode of older files.

**When migration is not needed:** UI-only changes, recalculating defaults for **new** installs only, or settings stored outside `SettingsStore` (e.g. database profiles).

**Never** remove or rename JSON keys without a migration step — users keep settings across app updates.

## Core flows
### 1) Extract flow (interactive)
Entry: `ExtractView` → `ExtractionModel.startExtraction(urls:)`

Pipeline (`ExtractionModel.performExtraction`):
- Validate export destination
- For each input URL (parallel `TaskGroup`):
  - Build `MarkersExtractor.Settings` via `SettingsStore.markersExtractorSettings(fcpxmlFileUrl:)`
  - Run `MarkersExtractor.extract()`, observe `Progress.fractionCompleted`
  - Write `extract_info.json` (via `ExtractInfo(exportResult:)`)
  - If swatches enabled:
    - `ColorPaletteRenderer.render(...)` → `ImageRenderService` → `ImageMergeOperation`
    - For GIF exports, generate separate palette images and update JSON manifest to add `Palette Filename`
  - If a database profile is selected:
    - `DatabaseUploader.uploadToDatabase(jsonManifestPath, profile)` (CLI process + streamed progress)
- Summarize success/failure into `ExportExitStatus` and `ExtractionFailure[]`
- Show result UI + optional Finder open / Pagemaker open

### 2) Queue flow (batch upload after extraction)
Entry: `QueueView.task { scanExportFolder }` or drag/drop folders into the table.

Pipeline (`QueueModel.scanFolder`):
- Walk directory recursively for `extract_info.json`
- Decode `ExtractInfo` and create `QueueInstance`
- User selects upload destination per item (must match platform recorded in `ExtractInfo.profile`)

Upload (`QueueModel.upload`):
- `TaskGroup` runs `QueueInstance.upload()` for all items
- Optional `deleteFolderAfterUpload` triggers `trashOrDelete()` after successful upload

### 3) Database upload flow
Entry: `DatabaseUploader.uploadToDatabase(url:databaseProfile:)`

Implementation:
- Spawns a bundled executable:
  - Notion: `csv2notion_neo`
  - Airtable: `airlift`
- Builds argument list via `ShellArgumentList` and launches with `Shell.createProcess`
- Streams stdout/stderr via `Shell.stream(...)`, parses `NN%` progress, updates `ProgressViewModel`
- Cancellation terminates child `Process`es

### 4) Workflow Extension handoff
Entry: drop `.fcpxml` on extension UI (`WorkflowExtensionView.onDrop`)

Implementation:
- Writes file to `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml`
- Opens the main app (`NSWorkspace.openApplication`)
- Posts distributed notification `.workflowExtensionFileReceived`

App receives:
- `ExtractionModel_EventHandlers.handleWorkflowExtensionEvent()`
  - If export folder exists: start extraction immediately
  - Else: set `externalFileRecieved` and wait for user to select export folder

### 5) Share Destination (FCP) handoff
Contract:
- `Resources/OSAScriptingDefinition.sdef` defines the scripting suite and record shapes.
  - `make` command maps `with properties` → `KeyDictionary` (Obj‑C reads `name`, `metadata`, `dataOptions`)
  - `asset location` record uses keys: `folder`, `basename`, `hasMedia`, `hasDescription`

Implementation:
- Obj‑C `MakeCommand` posts `FCPShareStart` and ensures an export directory exists under Movies cache.
- FCP “opens” exported files into the app; Swift `OpenEventHandler` registers an Apple Event handler for `kAEOpen`.
- `OpenEventHandler` posts `.openFile` notifications carrying the received URL.
- `ExtractionModel_EventHandlers.handleOpenDocument(...)` validates file type and starts extraction or shows the “external file received” gate.
- `SidebarSelectionSwitcher` forces UI to the Extract panel on those events.

## UI architecture
SwiftUI views generally bind directly into `SettingsContainer.store` (a published `SettingsStore`), so changing UI fields will auto-save to `preferences.json`. See **Settings system** for the full persistence, migration, and configuration model.

Notable UI modules:
- **General settings**: File, Roles, Notifications, Updates
- **Image settings**: Extraction + Swatch tabs
- **Label settings**: Appearance + Overlays
- **Configurations**: create/rename/duplicate/remove; unsaved-change dialogs; optional ⌘1…⌘9 shortcuts
- **Databases**: CRUD for Notion/Airtable profiles; Airtable includes Dropbox token setup
- **Pagemaker**: a bundled HTML app in a WebView with JS→Swift message to export PDF via `NSSavePanel`

## Entitlements / security model
There are multiple entitlements plists used in different contexts:
- App and workflow extension request Apple Events automation and specific scripting targets for Final Cut Pro.
- Workflow Extension is sandboxed and also requests Movies read-write for cache handoff.
- Distribution signing uses entitlements that include allowances commonly needed for PyInstaller-built helper binaries.

## Build, packaging, updates (operational architecture)
- Xcode project: `Source/Marker Data/Marker Data.xcodeproj`
- CI uses `xcodebuild` and installs Workflow Extensions SDK from `SDK/Workflow_Extensions_1.0.3.dmg`.
- DMG creation uses `appdmg` and `Distribution/dmg-builds/build-marker-data-dmg.json`.
- Sparkle:
  - Feed URL in Info.plist points to `appcast.xml`
  - `Distribution/dmg-builds/sparkle/generate_appcast_script.py` inserts a new `<item>` with ECDSA signature and length.
- Release workflows build the Marker Data scheme (main app + Uninstall Marker Data target), copy both apps to `latest-build/`, then handle signing + notarization for the app, extension, Sparkle framework, and the uninstaller app.

