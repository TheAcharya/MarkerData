# ARCHITECTURE.md

## Overview
**Marker Data** is a macOS SwiftUI application that extracts Final Cut Pro marker metadata and generates export artifacts (CSV/TSV/XLSX/MIDI/Markdown/SRT/YouTube/Compressor, plus Notion/Airtable JSON). It can optionally:

- Render stills / GIFs for markers (via **`MarkersExtractor`**, SPM ≥ **0.4.6**)
- Compute and render dominant color swatches/palettes into images (`DominantColors` + app-side merge)
- Upload extracted JSON manifests to Notion/Airtable using bundled CLI tools (`csv2notion_neo`, `airlift`)

It also ships two Final Cut Pro integrations:

- **Share Destination** — Media Asset Protocol / AppleScript so FCP exports media + FCPXML and opens them into Marker Data
- **Workflow Extension** — ProExtensions-hosted UI that can send an FCPXML to the app and manage Roles

**Runtime requirements (product):** Apple silicon; macOS Sequoia 15.7+ (from 2.0.0); Final Cut Pro 12+ recommended. The app is expected to run from **`/Applications/Marker Data.app`**.

For agent-oriented change checklists, see **`AGENT.md`**. For short Cursor guardrails, see **`.cursorrules`**.

---

## Targets & modules

### Main app target (`Marker Data`)
**Location:** `Source/Marker Data/Marker Data/`  
**Bundle ID:** `co.theacharya.MarkerData`

Primary responsibilities:
- UI/navigation and settings panels
- Extraction orchestration, progress, notifications
- Persistence of configurations, DB profiles, logs
- Queue scanning/uploading previously extracted Notion/Airtable jobs
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
- Drag/drop `.fcpxml` → write Movies-cache handoff file → open main app → DistributedNotification
- Roles tab sharing `RolesSettingsView` / `RolesManager` with the main app (same prefs file)

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

```
Marker_DataApp
 ├─ SettingsContainer          (@EnvironmentObject)
 ├─ DatabaseManager(settings)  (@EnvironmentObject)
 ├─ ExtractionModel(settings, databaseManager)  (@ObservedObject in Extract)
 └─ QueueModel(settings, databaseManager)       (@ObservedObject in Queue)
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
| `extract` | `ExtractView` |
| `queue` | `QueueView` |
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

**Entry:** `ExtractView` → `ExtractionModel.startExtraction(for:)`

Supported types: `UTType.fcpxml`, `UTType.fcpxmld` (`ExtractionModel.supportedContentTypes`).

Pipeline (`performExtraction`):

1. Validate export destination (`exportFolderURL` must exist) — else fail progress with alert message
2. `prepareExtraction` — `ProgressViewModel.setProcesses`, show UI
3. Parallel `TaskGroup` per URL:
   - Build settings via `markersExtractorSettings`
   - `MarkersExtractor.extract()`; KVO `progress.fractionCompleted` → progress UI / DockProgress
   - Optionally write `extract_info.json` when `ExtractInfo(exportResult:)` succeeds (Notion/Airtable + JSON path)
   - If swatches enabled: `ColorPaletteRenderer.render(...)` (may rewrite JSON for GIF palette filenames)
   - If DB profile selected: `DatabaseUploader.uploadToDatabase(jsonManifestPath, profile)`
4. Aggregate `ExportExitStatus` + `ExtractionFailure[]`; notifications; optional Finder/Pagemaker open

Cancellation: `cancelAll()` cancels extraction `Task` and terminates upload `Process`es.

External file gate: if open/Workflow Extension arrives without a valid export folder, set `externalFileRecieved` / `externalFileURL` and wait for `processExternalFile` after the user picks a destination.

### 2) Queue flow (batch upload)

**Entry:** `QueueView` `.task { scanExportFolder }` and/or drag-drop folders.

**Scan (`QueueModel.scanFolder`):**
- Recursive walk for files named `extract_info.json`
- Decode `ExtractInfo` → `QueueInstance` with DB profiles filtered to matching `plaform`
- Sort by `creationDate` descending
- Automatic scan uses `settings.store.exportFolderURL` when `@AppStorage("queueAutomaticScanEnabled")`

**Upload (`QueueModel.upload`):**
- Parallel `TaskGroup` → each `QueueInstance` owns its own `DatabaseUploader` (`showDockProgress = false`)
- Uploads the JSON URL recorded in `ExtractInfo` to the user-selected profile
- Optional `@AppStorage("deleteFolderAfterUpload")` → trash export folder after success

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

**Entry:** drop `.fcpxml` on extension Extract tab.

1. Write `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml`
2. `NSWorkspace.openApplication` → `/Applications/Marker Data.app`
3. DistributedNotification `.workflowExtensionFileReceived` (no URL payload)

App: `ExtractionModel_EventHandlers.handleWorkflowExtensionEvent` reads the fixed path; starts extraction or sets external-file gate. `SidebarSelectionSwitcher` selects Extract.

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

---

## Color swatch pipeline

After successful extract, if `colorSwatchSettings.enableSwatch`:

`ColorPaletteRenderer` → scans export images (skips `icon-marker*`) → `ColorsExtractorService` / DominantColors → `ImageRenderService` / `ImageMergeOperation`.

- Still images: palette strip merged onto originals
- GIF + JSON export: separate `{name}-Palette.jpg`, rewrite manifest with `"Palette Filename"`
- GIF + non-JSON: skip palette
- Forced off for XLSX extract profile (settings getter)

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
| Main | `ContentView`, `ExtractView` |
| Detail | General (File/Roles/Notifications/Updates), Image, Label, Configurations, Databases, Queue, About |
| Menu commands | App / File / Edit / Sidebar / Configuration / Help |
| Onboarding | `@AppStorage("showOnboarding")` sheet |
| Components / Extensions | Shared controls; **`DialogIcon.appDialogIcon()`** for alerts |
| Pagemaker | `PagemakerView` WebView + `PagemakerPDFExportHandler` (JS → Swift PDF via `NSSavePanel`) |

Install-location warning: on appear, if not under `/Applications` and `@AppStorage("ignoreInstallLocation")` is false, show alert (with `.appDialogIcon()`).

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

## Directory map (main app sources)

```
Source/Marker Data/Marker Data/
  Marker_DataApp.swift
  ApplicationDelegate.swift
  Models/
    Extract/           # ExtractionModel, Progress, DatabaseUploader, results
    Queue/             # QueueModel, QueueInstance, ExtractInfo
    Settings/          # Store, Container, Versioning, models
    Database/          # Manager + Notion/Airtable/Dropbox profiles
    Roles/             # RolesManager, RoleModel
    Color Swatch/      # Palette renderer + image merge + color extraction
    Configurations/    # ConfigurationsViewModel
    Errors/
    Other/             # MainViews, WindowSize, UnifiedExportProfile
  Views/
    Main/, Detail Views/, Components/, Menu Bar Commands/,
    Extensions/ (DialogIcon), Onboarding/, Other/
  FCP Share Destination/
    Install View/, Objective-C Code/, OpenEventHandler (Swift)
  Pagemaker/
  Utilities/
    Extensions/, Shell/, Notifications/, Other/
  Resources/
    airlift, csv2notion_neo, OSAScriptingDefinition.sdef,
    *.fcpxdest, Pagemaker.html, entitlements, DefaultConfiguration.json
```

---

## Invariants & pitfalls (architecture-level)

1. Settings migrations are mandatory for persisted key changes; Codable defaults alone are insufficient for existing users.
2. Configuration filenames are unique; silent overwrite is a product bug.
3. Roles are a cross-process file + DNC contract shared with the Workflow Extension.
4. Queue is upload-oriented around `extract_info.json` (Notion/Airtable), not a universal browser of all exports.
5. CLI progress and success depend on binary stdout contracts (`NN%`, exit codes).
6. Share Destination and Workflow Extension both assume `/Applications` install.
7. Alert UI must use PNG `AppIconSingle` via `.appDialogIcon()` (Icon Composer dock asset is unreliable in dialogs).
8. Preserve `plaform` spelling when touching database models unless intentionally migrating.
9. Definition of done: arm64 Debug+Release build; settings migrate; `.fcpxml`/`.fcpxmld` extract; queue still finds/uploads `extract_info.json` folders.
