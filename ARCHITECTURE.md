# ARCHITECTURE.md

## Table of contents

- [Overview](#overview)
- [Targets & modules](#targets--modules)
  - [Main app target (`Marker Data`)](#main-app-target-marker-data)
  - [Workflow Extension target](#workflow-extension-target)
  - [Uninstaller target (`Uninstall Marker Data`)](#uninstaller-target-uninstall-marker-data)
  - [Share Destination / scripting bridge (inside main app)](#share-destination--scripting-bridge-inside-main-app)
- [High-level runtime graph](#high-level-runtime-graph)
  - [Navigation](#navigation)
- [Data & persistence](#data--persistence)
  - [App Support & cache layout](#app-support--cache-layout)
  - [Settings system](#settings-system)
    - [Key types and files](#key-types-and-files)
    - [What gets persisted where](#what-gets-persisted-where)
    - [Runtime lifecycle (app launch)](#runtime-lifecycle-app-launch)
    - [Schema versioning](#schema-versioning)
    - [Auto-save and configurations](#auto-save-and-configurations)
    - [Bridge to extraction (`markersExtractorSettings`)](#bridge-to-extraction-markersextractorsettings)
    - [Exception: Roles (`RolesManager`)](#exception-roles-rolesmanager)
    - [Checklist: adding or changing a persisted setting](#checklist-adding-or-changing-a-persisted-setting)
- [Core flows](#core-flows)
  - [1) Extract flow (interactive)](#1-extract-flow-interactive)
  - [2) Queue flow (batch upload)](#2-queue-flow-batch-upload)
  - [3) Database upload flow](#3-database-upload-flow)
  - [4) Workflow Extension handoff](#4-workflow-extension-handoff)
  - [5) Share Destination handoff](#5-share-destination-handoff)
- [Color swatch pipeline](#color-swatch-pipeline)
- [Database profiles](#database-profiles)
- [UI architecture](#ui-architecture)
- [Notifications (full list)](#notifications-full-list)
- [Entitlements / security model](#entitlements--security-model)
- [Build, packaging, updates](#build-packaging-updates)
  - [Notable SPM dependencies (main app)](#notable-spm-dependencies-main-app)
- [Uninstaller path contract](#uninstaller-path-contract)
- [Directory map (sources)](#directory-map-sources)
- [Invariants & pitfalls (architecture-level)](#invariants--pitfalls-architecture-level)

---

## Overview
**Marker Data** is a macOS SwiftUI application that extracts Final Cut Pro marker metadata and generates export artifacts (CSV/TSV/XLSX/MIDI/Markdown/SRT/YouTube/Compressor, plus Notion/Airtable JSON). It can optionally:

- Render stills / GIFs for markers (via **`MarkersExtractor`**, SPM ≥ **0.4.6**)
- Compute and render dominant color swatches/palettes into images (`DominantColors` + app-side merge)
- Upload extracted JSON manifests to Notion/Airtable using bundled CLI tools (`csv2notion_neo`, `airlift`)

It also ships two Final Cut Pro integrations:

- **Share Destination** — Media Asset Protocol / AppleScript so FCP exports media + FCPXML and opens them into Marker Data
- **Workflow Extension** — ProExtensions-hosted UI: Extract tab handoff (overlay + Movies-cache FCPXML → open app) and Roles management (shared prefs + overlay)

**Runtime requirements (product):** Apple silicon; macOS Sequoia 15.7+ (from 2.0.0); Final Cut Pro 12+ recommended. The app is expected to run from **`/Applications/Marker Data.app`**.

For agent-oriented change checklists, see **`AGENT.md`**. For hard always/never constraints and learned pitfalls, see **`GUARDRAILS.md`**. For short Cursor enforcement, see **`.cursorrules`**.

---

## Targets & modules

### Main app target (`Marker Data`)
**Location:** `Source/Marker Data/Marker Data/`  
**Bundle ID:** `co.theacharya.MarkerData`

Primary responsibilities:
- UI/navigation and settings panels
- FCPXML intake (Finder, Dock Open With, FCP pasteboard, text clippings) and drop overlays
- Extraction orchestration, progress, notifications
- Persistence of configurations, DB profiles, logs
- Queue scanning/uploading previously extracted Notion/Airtable jobs (local-first `manifestURL`)
- Installing FCP Share Destination templates
- Hosting Pagemaker (WebView) for PDF generation
- Embedding the Workflow Extension as `Contents/PlugIns/Workflow Extension.appex`

### Workflow Extension target
**Location:** `Source/Marker Data/Workflow Extension/`  
**Product:** `Workflow Extension.appex`  
**Bundle ID:** `co.theacharya.MarkerData.WorkflowExtension`  
**SDK:** `/Library/Developer/SDKs/WorkflowExtensionSDK.sdk` (from `SDK/Workflow_Extensions_1.0.3.dmg`)  
**Link:** `-lProExtension`

Responsibilities:
- SwiftUI UI inside `WorkflowExtensionViewController` (`NSHostingView`)
- Extract tab: drag/drop `.fcpxml` + `DropTargetOverlay` (“Drop to Open Marker Data”) → write Movies-cache handoff file → open main app → DistributedNotification
- Roles tab sharing `RolesSettingsView` / `RolesManager` / `DropTargetOverlay` / `ColorExtension` with the main app (same prefs file)

### Uninstaller target (`Uninstall Marker Data`)
**Location:** `Source/Marker Data/Marker Data Uninstaller/`  
**Product:** `Uninstall Marker Data.app`  
**Display name:** Marker Data Uninstaller  
**Bundle ID:** `co.theacharya.MarkerData.Uninstaller`

`MarkerDataUninstaller.run()` terminates the main app, deletes the `co.theacharya.MarkerData` defaults domain, trashes app/cache/prefs/container paths, and writes `~/Desktop/Marker-Data_Uninstall_Log.txt`.

Built as part of the **Marker Data** scheme; CI copies it next to the main app in the DMG.

### Share Destination / scripting bridge (inside main app)
**Location:** `Source/Marker Data/Marker Data/FCP Share Destination/`

- **Install UI (Swift):** AppleScript opens bundled `.fcpxdest` resources in Final Cut Pro
- **Obj‑C scripting/doc controller:** Media Asset Protocol shape + AppleScript `make` command creating “assets” backed by export directories under Movies cache
- Posts local notification `FCPShareStart` so Swift re-registers the Apple Event `kAEOpen` handler

---

## High-level runtime graph

Constructed at app launch (`Marker_DataApp.swift`):

```mermaid
flowchart TB
  App[Marker_DataApp]
  SC[SettingsContainer]
  DM[DatabaseManager]
  EM[ExtractionModel]
  QM[QueueModel]

  App --> SC
  App --> DM
  App --> EM
  App --> QM
  DM --> SC
  EM --> SC
  EM --> DM
  QM --> SC
  QM --> DM
```

Also at launch / first appear:
- `DockProgress.style = .squircle(...)`
- `NotificationManager.setupDelegate()`
- `OpenEventHandler.setupHandler()`
- `SidebarSelectionSwitcher` (forces Extract on external handoffs)
- `LibraryFolders.checkAndCreateMissing()` (creates App Support + Movies cache; deletes old cache)

### Navigation
`ContentView` → `NavigationSplitView` with `MainViews`:

| Case | Detail |
|------|--------|
| `extract` | `ExtractView` (drop overlay + FCPXML intake) |
| `queue` | `QueueView` (folder drop overlay + upload table) |
| `general` | File / Roles / Notifications / Updates |
| `image` | Extraction + Swatch tabs |
| `label` | Appearance + Overlays |
| `configurations` | Named presets CRUD |
| `databases` | Notion / Airtable profiles |
| `about` | About |

Fixed content size (`WindowSize`), forced dark appearance. Toolbar configuration picker loads stores via `settings.load(store)`.

Sparkle: `SPUStandardUpdaterController` exists on both the SwiftUI `App` and `ApplicationDelegate`. Update badge uses `ApplicationDelegate.bestValidUpdate(in:for:)` → `.updateAvailable` (delegate returns `SUAppcastItem.empty()` intentionally).

---

## Data & persistence

### App Support & cache layout
Defined by `URLExtension.swift`; created/validated by `LibraryFolders`.

```
~/Library/Application Support/Marker Data/
  preferences.json                 # active SettingsStore
  Configurations/*.json            # named SettingsStore presets
  Database Profiles/
    Notion/*.json
    Airtable/*.json
    Dropbox/dropbox_token.json
  Logs/*.txt                       # CLI logs etc.

~/Movies/Marker Data Cache/
  WorkflowExtensionExport.fcpxml   # Workflow Extension handoff
  <Share Destination export dirs>/ # media + fcpxml from FCP
  FCP Drop-*.fcpxml                # temp pasteboard / clipping intake (FCPXMLIntake)
```

`Resources/DefaultConfiguration.json` in the app bundle is a **legacy** resource (`URL.defaultConfigurationJSON`); it is **not** the live settings source.

### Settings system

Marker Data persists almost all user preferences as versioned JSON. Understanding this system is required before adding or changing any setting.

#### Key types and files

| File | Role |
|------|------|
| `Models/Settings/SettingsStore.swift` | Codable value type; `static let version` (currently **8**) |
| `Models/Settings/SettingsContainer.swift` | Active store, auto-save, configuration CRUD |
| `Models/Settings/SettingsVersioningManager.swift` | Dict migrations before decode |
| `Models/Settings/SettingsModels.swift` | Supporting enums/types |
| `Models/Settings/MarkersExtractorModelExtensions.swift` | Display-name / Codable helpers for MarkersExtractor types |
| `Models/Configurations/ConfigurationsViewModel.swift` | UI facade |
| `Utilities/Extensions/URLExtension.swift` | Canonical paths |

#### What gets persisted where

| Path | Contents |
|------|----------|
| `preferences.json` | **Active** settings |
| `Configurations/{name}.json` | Named presets (same schema) |
| `Database Profiles/` | Notion/Airtable credentials — **outside** `SettingsStore`; owned by `DatabaseManager` |

Both preferences and configuration files include a `"version"` integer that must match `SettingsStore.version` after migration.

#### Runtime lifecycle (app launch)

```
SettingsContainer.init()
  → Task.synchronous { SettingsVersioningManager.updateAll() }
  → load preferences.json into store (fallback: defaults())
  → load Configurations/*.json (+ in-memory Default)
  → save preferences.json (normalize on disk)
  → $store sink → auto-save on every change
  → observe DistributedNotification .rolesChanged → reload preferences
```

Migrations run **synchronously at launch** before any settings decode. Failures are logged per file; decode may then fail for that file.

#### Schema versioning

- `SettingsStore.version` = schema the **current app code** expects.
- Per-file `version` = schema that file was last written with.
- While `file.version < SettingsStore.version`, apply one `upgradeVersion(dict:version:)` step, write file, increment.

Migrations operate on `[String: Any]` — not Codable — so renames and nested updates are explicit. Each `case N` upgrades **from** N **to** N+1:

| From | Upgrade |
|------|---------|
| 1 | Inject `colorSwatchSettings` defaults |
| 2 | `includeDisabledClips = false` |
| 3 | Swatch `excludeGray` |
| 4 | Swatch `accuracy` |
| 5 | `useChapterMarkerThumbnails` |
| 6 | `IDNamingMode`: `projectTimecode` → `timelineNameAndTimecode` |
| 7 | `allowUTF8InMIDIExport` |

#### Auto-save and configurations

- Views bind `$settings.store.<property>` → auto-write `preferences.json`.
- Saving a named configuration writes `Configurations/{name}.json`.
- **Unique names:** `configurationNameExists` checks in-memory list **and** on-disk file; collisions → `ConfigurationSaveError.nameAlreadyExists`. Illegal names: empty or `"Default"`.
- Rename = duplicate-as-new + remove-old (`ConfigurationsViewModel.rename`); same-name rename is a no-op; sheets dismiss only on success.
- `unsavedChanges`: Default compares to `defaults()`; named configs compare to on-disk file.
- Optional ⌘1…⌘9 shortcuts via `@UserDefaultsArray("configurationShortcuts")`.

#### Bridge to extraction (`markersExtractorSettings`)

`SettingsStore.markersExtractorSettings(fcpxmlFileUrl:)` → `MarkersExtractor.Settings`.

Notable behaviors:
- Output dir: `exportFolderURL` or fallback `URL.FCPExportCacheFolder`
- Roles: `RolesManager.loadRolesFromDisk()` → `excludeRoles` = disabled role raw values
- GIF + `.noOverride` image size → defaults **50%**
- Stroke auto → `imageLabelFontStrokeWidth = nil`
- Throws `ExtractError.conflictingNamingAndSource` if `IDNamingMode == .notes` and markers source ≠ `.markers`
- Maps MIDI UTF-8 toggle → `isMIDIFileUTF8EncodingAllowed`

**Not currently wired into MarkersExtractor** (persisted + UI only): `enabledNoMedia`, `fontStyleType`.

**XLSX special case:** `colorSwatchSettings` getter forces `enableSwatch = false`.

#### Exception: Roles (`RolesManager`)

FCP role enable/disable lives in `preferences.json`, but **`RolesManager` reads/writes the file directly** (hard-coded Application Support path) so the Workflow Extension (no `SettingsContainer`) can share it.

- Save → DistributedNotification `.rolesChanged`
- Main app observes and replaces `store` from disk
- Extraction always reloads roles from disk inside `markersExtractorSettings`

Changing the JSON shape of `roles` / `RoleModel` must remain compatible with both targets.

#### Checklist: adding or changing a persisted setting

1. Add property + `defaults()` value on `SettingsStore`
2. Increment `SettingsStore.version`
3. Add migration `case` for previous version
4. Add UI binding
5. Wire `markersExtractorSettings` if export-related
6. Bump MarkersExtractor SPM if library API changed
7. Verify old on-disk JSON upgrades

**Never** remove/rename JSON keys without a migration.

---

## Core flows

### 1) Extract flow (interactive)

**Entry points:**
- `ExtractView` `.fcpxmlDropDestination` → `ExtractionModel.receiveItemProviders`
- Choose File / open panel → `receiveFiles`
- Dock / Finder Open With → `OpenEventHandler` → `.openFile` → `handleOpenDocument`
- Workflow Extension / Share Destination handoffs (see §§ 4–5)

**Intake (`FCPXMLIntake`):**
- Resolves `.fcpxml` / `.fcpxmld` URLs
- Reads Finder `.textClipping` via `TextClippingReader`
- Loads Final Cut Pro pasteboard (`UTType.fcpxml` data) → writes temp file under `~/Movies/Marker Data Cache/`
- Does **not** replace Share Destination media+FCPXML exports

**UI:** `DropTargetOverlay` while targeted and not extracting; hero caption under title describes FCP timeline / file drop. Overlay copy: see **`GUARDRAILS.md`**.

Supported types: `UTType.fcpxml`, `UTType.fcpxmld` (`ExtractionModel.supportedContentTypes`).

```mermaid
flowchart LR
  Drop[Drop / Open / Pasteboard]
  Intake[FCPXMLIntake]
  EM[ExtractionModel]
  ME[MarkersExtractor]
  Swatch["ColorPaletteRenderer.render -> Bool"]
  Up[DatabaseUploader]

  Drop --> Intake --> EM --> ME
  ME --> Swatch
  ME --> Up
  Swatch -->|true: markAllProcessesFinished| Up
  Swatch -->|false: markProcessAsFinished Extract done| Up
```

Pipeline (`performExtraction`):

1. Validate export destination (`exportFolderURL` must exist) — else fail progress with alert message
2. `prepareExtraction` — `ProgressViewModel.setProcesses`, show UI
3. Parallel `TaskGroup` per URL:
   - Build settings via `markersExtractorSettings`
   - `MarkersExtractor.extract()`; KVO `progress.fractionCompleted` → progress UI / DockProgress
   - Optionally write `extract_info.json` when `ExtractInfo(exportResult:)` succeeds (Notion/Airtable + JSON path)
   - If swatches enabled: `didRender = await ColorPaletteRenderer.render(...)` — renderer `await`s `applyTaskAppearance` only after images pass checks; `true` → `markAllProcessesFinished`; `false` → `markProcessAsFinished(url)` (keeps **“Extract done”**)
   - If swatches disabled: `markProcessAsFinished(url)`
   - If DB profile selected: `DatabaseUploader.uploadToDatabase(jsonManifestPath, profile)`
4. Aggregate `ExportExitStatus` + `ExtractionFailure[]`; notifications; optional Finder/Pagemaker open

Cancellation: `cancelAll()` cancels extraction `Task` and terminates upload `Process`es.

External file gate: if open/Workflow Extension arrives without a valid export folder, set `externalFileRecieved` / `externalFileURL` and wait for `processExternalFile` after the user picks a destination.

### 2) Queue flow (batch upload)

**Entry:** `QueueView` `.task { scanExportFolder }` and/or drag-drop folders (any location).

**UI:** `DropTargetOverlay` with folder icon while targeted and not uploading — copy in **`GUARDRAILS.md`**.

```mermaid
flowchart TB
  Scan[scanFolder / performDrop]
  Info[extract_info.json]
  QI[QueueInstance]
  Man[manifestURL]
  Up[DatabaseUploader]

  Scan --> Info --> QI --> Man --> Up
```

**Scan (`QueueModel.scanFolder`):**
- Recursive walk for files named `extract_info.json`
- Decode `ExtractInfo` → `QueueInstance` with DB profiles filtered to matching `plaform`
- Sort by `creationDate` descending
- Automatic scan uses `settings.store.exportFolderURL` when `@AppStorage("queueAutomaticScanEnabled")`
- Folder drop (`performDrop`): clear queue, scan each directory with `append: true`, set `automaticScanEnabled = false`

**Manifest resolution (`QueueInstance.manifestURL`):**
- Prefer `{folderURL}/{ExtractInfo.jsonURL.lastPathComponent}` when that file exists (moved/copied export folders)
- Else fall back to absolute `ExtractInfo.jsonURL` written at extract time
- `filterMissing()` and upload both use `manifestURL`

**Upload (`QueueModel.upload`):**
- Parallel `TaskGroup` → each `QueueInstance` owns its own `DatabaseUploader` (`showDockProgress = false`)
- Uploads `manifestURL` to the user-selected profile
- Optional `@AppStorage("deleteFolderAfterUpload")` → trash export folder after success
- Drop / Start Upload blocked while `uploadInProgress`

**Important:** Queue only discovers Notion/Airtable extract jobs. Extract-only CSV/TSV/XLSX/etc. do not produce usable `extract_info.json`.

### 3) Database upload flow

**Entry:** `DatabaseUploader.uploadToDatabase(url:databaseProfile:)`

| Platform | Resource binary | Highlights |
|----------|-----------------|------------|
| Notion | `csv2notion_neo` | workspace/token, image columns `Image Filename` / `Palette Filename`, Marker ID columns, optional merge/URL, logs under Application Support |
| Airtable | `airlift` | token/base/table, Dropbox token JSON, attachment maps, `--md` |

Implementation details:
- Args via `ShellArgumentList`; process via `Shell.createProcess` (`/bin/sh -c`, `HOME` + `TERM`)
- Stream stdout/stderr; regex parse `NN%` → `ProgressViewModel`
- Non-zero exit → platform-specific `DatabaseUploadError`
- Cancel → `Process.terminate()`

Dropbox auth for Airtable: `DropboxSetupModel` writes a temp `.command` that runs `airlift --dropbox-refresh-token` and opens it in Terminal (avoids fragile AppleScript paths on newer macOS).

### 4) Workflow Extension handoff

**Entry:** drop `.fcpxml` on extension Extract tab (`WorkflowExtensionView`).

1. Show `DropTargetOverlay` (**“Drop to Open Marker Data”**) while targeted
2. Write `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml`
3. `NSWorkspace.openApplication` → `/Applications/Marker Data.app`
4. DistributedNotification `.workflowExtensionFileReceived` (no URL payload)

App: `ExtractionModel_EventHandlers.handleWorkflowExtensionEvent` reads the fixed path; starts extraction or sets external-file gate. `SidebarSelectionSwitcher` selects Extract.

Roles tab: same `RolesSettingsView` + `DropTargetOverlay` as the main app (extension Compile Sources must include overlay + `ColorExtension`). Overlay borders use `Color.markerAccent` so FCP’s host accent does not turn them blue.

### 5) Share Destination handoff

**Install:** `ShareDestinationInstaller` AppleScripts FCP to open bundled `Marker Data Source.fcpxdest` / `Marker Data H.264.fcpxdest`.

**Contract (`OSAScriptingDefinition.sdef`):**
- Suite ProVideo Asset Management; `make` → `MakeCommand` with `KeyDictionary` keys `name`, `metadata`, `dataOptions`
- Asset location record keys: `folder`, `basename`, `hasMedia`, `hasDescription`

**Obj‑C:**
- `MakeCommand` posts `FCPShareStart`, creates `~/Movies/Marker Data Cache/<name>/`, returns asset location expecting media + `.fcpxml`
- `DocumentController` / `Asset` attach opened media/description URLs to the document

**Swift:**
- `OpenEventHandler` registers `kAEOpen`; on each URL posts `.openFile` with `userInfo["url"]`
- Re-registers when `.FCPShareStart` arrives
- `ExtractionModel.handleOpenDocument` validates type and starts extract / gate

Info.plist advertises Media Asset Protocol and document types for asset media/description collections.

**Note:** FCP **timeline** drops onto the Dock icon are often pasteboard-only (no file URL). Prefer Extract panel drop, file Open With, Workflow Extension, or Share Destination for media+XML.

---

## Color swatch pipeline

After successful extract, if `colorSwatchSettings.enableSwatch`:

`ColorPaletteRenderer.render(...) -> Bool`:

1. Scan export folder for images (skips `icon-marker*`)
2. Early `return false` if no images, directory failure, or GIF without JSON (no progress retitle)
3. Else `await progress.applyTaskAppearance("Analysing swatch", ...)` (MainActor), then `ColorsExtractorService` / DominantColors → `ImageRenderService` / `ImageMergeOperation`
4. `return true` (caller runs `markAllProcessesFinished`)

- Still images: palette strip merged onto originals
- GIF + JSON export: separate `{name}-Palette.jpg`, rewrite manifest with `"Palette Filename"`
- GIF + non-JSON: skip palette (`false`)
- Forced off for XLSX extract profile (settings getter)
- No images / Skip Image Generation: `false` → ExtractionModel `markProcessAsFinished` → **“Extract done”** (never **“Analysing swatch done”**). Do not `reset()` when entering the swatch phase.

Settings model: `ColorSwatchSettingsModel` (nested under SettingsStore, Codable).

---

## Database profiles

`DatabaseManager` loads typed JSON from Notion/Airtable folders into `[DatabaseProfileModel]`.

- Selection syncs with `settings.store.unifiedExportProfile` (`UnifiedExportProfile`: extract-only vs extract-and-upload)
- Setting a DB profile forces the MarkersExtractor export format for that platform so a JSON manifest exists
- Validation: unique profile names; must not collide with extract-only format display names
- Property spelling **`plaform`** is intentional in current code — preserve when editing

| Model | Notable fields |
|-------|----------------|
| `NotionDBModel` | workspace, token, database URL, rename key column, `mergeOnlyColumns: [ExportField]` |
| `AirtableDBModel` | token, base ID, table ID, rename key column |

---

## UI architecture

SwiftUI views bind into `SettingsContainer.store`. Changing fields auto-saves.

Notable modules under `Views/`:

| Area | Notes |
|------|--------|
| Main | `ContentView`, `ExtractView` (drop overlay + `.fcpxmlDropDestination`) |
| Detail | General (File/Roles/Notifications/Updates), Image, Label, Configurations, Databases, Queue (folder drop overlay), About |
| Menu commands | App / File / Edit / Sidebar / Configuration / Help |
| Onboarding | `@AppStorage("showOnboarding")` sheet |
| Components | `DropTargetOverlay` (main app + WE), `FCPXMLDropModifier`, shared controls |
| Extensions | **`MarkerDataAppIcon` / `.appDialogIcon()`** (`DialogIcon.swift`) — About, Workflow Extension header, alerts from compiled `Marker-Data.icon` |
| Other | `FailedExtractionsView` (truncate + `.help()` tooltips; min ~640×240) |
| Pagemaker | `PagemakerView` WebView + `PagemakerPDFExportHandler` (JS → Swift PDF via `NSSavePanel`) |

Install-location warning: on appear, if not under `/Applications` and `@AppStorage("ignoreInstallLocation")` is false, show alert (with `.appDialogIcon()`).

Drop overlay copy and invariants: **`GUARDRAILS.md`**.

```mermaid
flowchart TB
  subgraph mainApp [Main app]
    EX[ExtractView]
    RO[RolesSettingsView]
    QU[QueueView]
  end

  subgraph we [Workflow Extension]
    WEX[WorkflowExtensionView Extract]
    WRO[RolesSettingsView]
  end

  OV[DropTargetOverlay]
  EX --> OV
  RO --> OV
  QU --> OV
  WEX --> OV
  WRO --> OV

  EX --> FM[FCPXMLDropModifier]
  FM --> IN[FCPXMLIntake]
  IN --> EM[ExtractionModel]

  RO --> RM[RolesManager DropDelegate]
  WRO --> RM
  QU --> QM[QueueModel.performDrop]
  WEX --> HO[Movies cache + open app + DNC]
```

```mermaid
flowchart LR
  Drop[FCPXML drop on WE Extract]
  Overlay[DropTargetOverlay]
  Cache[WorkflowExtensionExport.fcpxml]
  App["/Applications/Marker Data.app"]
  DNC[.workflowExtensionFileReceived]
  EM[ExtractionModel]

  Drop --> Overlay
  Drop --> Cache --> App --> DNC --> EM
```

---

## Notifications (full list)

Defined in `NotificationNameExtension.swift`:

| Swift name | String | Transport |
|------------|--------|-----------|
| `.openFile` | `OpenFile` | Local |
| `.workflowExtensionFileReceived` | `WorkflowExtensionFileReceived` | Distributed |
| `.rolesChanged` | `RolesChanged` | Distributed |
| `.FCPShareStart` | `FCPShareStart` | Local (Obj‑C → Swift) |
| `.updateAvailable` | `updateAvailable` | Local |

User-facing macOS notifications: `NotificationManager` + `NotificationFrequency` gated by settings.

---

## Entitlements / security model

Multiple entitlements plists:

- Main app: Apple Events automation targeting Final Cut Pro variants; helpers needed for CLI/binaries in distribution builds
- Workflow Extension: App Sandbox, Movies read/write, temporary exception for Application Support preferences path, Apple Events / FCP inspection
- Uninstaller: separate entitlements under Distribution for signing

Changing automation, sandbox, or extension behavior usually requires entitlement + CI signing review.

---

## Build, packaging, updates

| Item | Detail |
|------|--------|
| Project | `Source/Marker Data/Marker Data.xcodeproj` |
| CI runner / Xcode | `macos-26` / **Xcode 26.6.0** |
| Workflow Extension SDK | `SDK/Workflow_Extensions_1.0.3.dmg` |
| DMG | `appdmg` + `Distribution/dmg-builds/build-marker-data-dmg.json` |
| Sparkle feed | `appcast.xml`; generator `Distribution/dmg-builds/sparkle/generate_appcast_script.py` |
| Binary refresh workflows | `update_airlift_binary.yml`, `update_csv2notion_neo_binary.yml`, `update_pagemaker.yml` |

### Notable SPM dependencies (main app)
MarkersExtractor, DominantColors, DockProgress, Sparkle, FilePicker, ColorWellKit, PasswordField, ButtonKit, WebViewKit, swift-collections, swift-log-oslog (and related logging).

---

## Uninstaller path contract

Must stay aligned with runtime paths. Current removal list includes:

- `/Applications/Marker Data.app`
- `~/Movies/Marker Data Cache`
- Saved Application State, WebKit, HTTPStorages, Caches for `co.theacharya.MarkerData`
- Containers / Application Scripts for Workflow Extension
- `~/Library/Application Support/Marker Data`
- `~/Library/Preferences/co.theacharya.MarkerData.plist`

Plus `defaults delete co.theacharya.MarkerData` and `killall "Marker Data"`.

---

## Directory map (sources)

```
Source/Marker Data/Marker Data/
  Marker_DataApp.swift
  ApplicationDelegate.swift
  Models/
    Extract/           # ExtractionModel, ProgressViewModel, DatabaseUploader, results
    Queue/             # QueueModel, QueueInstance (manifestURL), ExtractInfo
    Settings/          # Store, Container, Versioning, models
    Database/          # Manager + Notion/Airtable/Dropbox profiles
    Roles/             # RolesManager (+ DropDelegate isDropTargeted), RoleModel
    Color Swatch/      # ColorPaletteRenderer (render -> Bool), image merge, color extraction
    Configurations/    # ConfigurationsViewModel
    Errors/
    Other/             # MainViews, WindowSize, UnifiedExportProfile
  Views/
    Main/, Detail Views/, Menu Bar Commands/,
    Components/        # DropTargetOverlay, FCPXMLDropModifier, …
    Extensions/        # DialogIcon (MarkerDataAppIcon + .appDialogIcon)
    Onboarding/, Other/  # FailedExtractionsView, …
  FCP Share Destination/
    Install View/, Objective-C Code/, OpenEventHandler (Swift)
  Pagemaker/
  Utilities/
    Extensions/        # URL, Color (markerAccent, heroGradient), UTType, NotificationName, …
    Shell/, Notifications/,
    Other/             # FCPXMLIntake, TextClippingReader, LibraryFolders, …
  Resources/
    airlift, csv2notion_neo, OSAScriptingDefinition.sdef,
    *.fcpxdest, Pagemaker.html, entitlements, DefaultConfiguration.json
  Marker-Data.icon                     # Icon Composer Liquid Glass (ASSETCATALOG_COMPILER_APPICON_NAME)
  Assets.xcassets/                     # empty AppIcon.appiconset placeholder; no AppIconSingle

Source/Marker Data/Workflow Extension/
  WorkflowExtensionView.swift          # Extract overlay + handoff; MarkerDataAppIcon header; hosts RolesSettingsView
  WorkflowExtensionViewController.swift
  Assets.xcassets/, Info.plist, entitlements, bridging header
  # Bundle/plugin icon remains AppIcon.appiconset (do not replace with Marker-Data.icon)
  # Header UI shares Marker-Data.icon via DialogIcon.swift (named Marker-Data; not host applicationIconImage)
```

---

## Invariants & pitfalls (architecture-level)

1. Settings migrations are mandatory for persisted key changes; Codable defaults alone are insufficient for existing users.
2. Configuration filenames are unique; silent overwrite is a product bug.
3. Roles are a cross-process file + DNC contract shared with the Workflow Extension (incl. shared drop overlay types in both targets).
4. Workflow Extension **Extract** and **Roles** both show `DropTargetOverlay`; Extract handoff is local to `WorkflowExtensionView`, Roles uses shared `RolesSettingsView`.
5. Shared WE chrome must use `Color.markerAccent` — `accentColor` resolves to Final Cut Pro’s blue inside the appex.
6. Queue is upload-oriented around `extract_info.json` (Notion/Airtable), not a universal browser of all exports.
7. Queue uploads must use `QueueInstance.manifestURL` so moved/copied folders work despite absolute sidecar paths.
8. Extract → swatch: never `reset()`. `ColorPaletteRenderer.render -> Bool`; retitle only via `await applyTaskAppearance` after images exist; skip → `markProcessAsFinished` (“Extract done”); success → `markAllProcessesFinished`.
9. CLI progress and success depend on binary stdout contracts (`NN%`, exit codes).
10. Share Destination and Workflow Extension both assume `/Applications` install.
11. Alert / About / Workflow Extension **header** UI must use `MarkerDataAppIcon` / `.appDialogIcon()` from compiled Icon Composer `Marker-Data.icon`. Do not flatten the layer PNG into `AppIconSingle`. Main-app `AppIcon.appiconset` is a catalog placeholder only. Do **not** replace the Workflow Extension’s bundle/plugin `AppIcon.appiconset`. In the extension header, load the named `Marker-Data` asset (host `applicationIconImage` is Final Cut Pro).
12. Preserve `plaform` spelling when touching database models unless intentionally migrating.
13. FCPXML pasteboard/clipping temps live under `~/Movies/Marker Data Cache/` (not App Support).
14. Definition of done: arm64 Debug+Release build; settings migrate; `.fcpxml`/`.fcpxmld` + pasteboard intake; WE Extract + Roles overlays; queue finds/uploads via `manifestURL`; agent docs (`AGENT.md` / `ARCHITECTURE.md` / `GUARDRAILS.md` / `.cursorrules`) stay aligned.
