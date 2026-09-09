# AGENT.md

## Table of contents

- [Purpose](#purpose)
- [What you’re working on](#what-youre-working-on)
- [Key entry points (start here)](#key-entry-points-start-here)
- [Build & run (local)](#build--run-local)
- [CI / release basics](#ci--release-basics)
- [Code conventions & expectations](#code-conventions--expectations)
- [Settings system (read before changing preferences)](#settings-system-read-before-changing-preferences)
  - [Core files](#core-files)
  - [How it works (short)](#how-it-works-short)
  - [Migration ladder (each `case N` upgrades N → N+1)](#migration-ladder-each-case-n-upgrades-n--n1)
  - [Checklist: add or change a persisted setting](#checklist-add-or-change-a-persisted-setting)
  - [Known settings gaps (do not “fix” casually without product intent)](#known-settings-gaps-do-not-fix-casually-without-product-intent)
- [“When you change X, also change Y”](#when-you-change-x-also-change-y)
  - [SettingsStore / preferences](#settingsstore--preferences)
  - [New export fields / overlays](#new-export-fields--overlays)
  - [New database platform](#new-database-platform)
  - [FCP integrations](#fcp-integrations)
  - [File menu](#file-menu)
  - [Drop overlay / shared Workflow Extension UI](#drop-overlay--shared-workflow-extension-ui)
  - [App icon / dialogs](#app-icon--dialogs)
  - [Uninstaller cleanup paths](#uninstaller-cleanup-paths)
  - [Release metadata](#release-metadata)
  - [Agent documentation](#agent-documentation)
- [Extract / Roles / Queue drop surfaces](#extract--roles--queue-drop-surfaces)
- [Notification & handoff cheat sheet](#notification--handoff-cheat-sheet)
- [Common pitfalls](#common-pitfalls)
- [Definition of done for most changes](#definition-of-done-for-most-changes)

---

## Purpose
This repository contains **Marker Data**, a macOS Swift/SwiftUI app that extracts Final Cut Pro marker metadata (via `MarkersExtractor`), optionally renders images/palettes, and can upload results to Notion/Airtable via bundled CLIs. It also ships a **Final Cut Pro Workflow Extension** and a **Share Destination** integration.

This `AGENT.md` is guidance for humans and AI agents working in this repo: how to build, where to look, what to avoid, and how changes should be made.

For deeper module/data-flow detail, see **`ARCHITECTURE.md`**. For hard always/never constraints and learned pitfalls, see **`GUARDRAILS.md`**. For short Cursor enforcement, see **`.cursorrules`**. Keep all four consistent when architecture or agent guidance changes.

## What you’re working on

| Area | Path |
|------|------|
| Main app (SwiftUI) | `Source/Marker Data/Marker Data/` |
| Workflow Extension | `Source/Marker Data/Workflow Extension/` |
| Uninstaller (SwiftUI) | `Source/Marker Data/Marker Data Uninstaller/` — target **Uninstall Marker Data**; product `Uninstall Marker Data.app`; display name “Marker Data Uninstaller”; bundle ID `co.theacharya.MarkerData.Uninstaller` |
| Share Destination install UI | `Source/Marker Data/Marker Data/FCP Share Destination/Install View/` |
| Share Destination scripting (Obj‑C) | `Source/Marker Data/Marker Data/FCP Share Destination/Objective-C Code/` |
| Bundled helper CLIs (opaque) | `Source/Marker Data/Marker Data/Resources/airlift`, `.../csv2notion_neo` |
| Distribution / DMG / Sparkle | `Distribution/` |
| CI | `.github/workflows/` |

**Xcode project:** `Source/Marker Data/Marker Data.xcodeproj`  
**Scheme:** **Marker Data** builds the main app (embeds Workflow Extension) and the Uninstall Marker Data target.

## Key entry points (start here)

| Concern | File |
|---------|------|
| `@main` app | `Source/Marker Data/Marker Data/Marker_DataApp.swift` — constructs `SettingsContainer`, `DatabaseManager`, `ExtractionModel`, `QueueModel`; menu commands (`FileCommands` replaces `.newItem`); Failed Tasks + Pagemaker windows |
| AppKit / Sparkle delegate | `Source/Marker Data/Marker Data/ApplicationDelegate.swift` |
| Sidebar navigation | `Source/Marker Data/Marker Data/Views/Main/ContentView.swift` (`MainViews` enum) |
| Extract UI | `Source/Marker Data/Marker Data/Views/Main/ExtractView.swift` |
| Extraction orchestration | `Source/Marker Data/Marker Data/Models/Extract/Extraction Model/ExtractionModel.swift` |
| External handoffs (open / Workflow Extension) | `.../ExtractionModel_EventHandlers.swift` |
| FCPXML intake (files / pasteboard / textClipping) | `Utilities/Other/FCPXMLIntake.swift`, `TextClippingReader.swift` |
| Extract drop modifier | `Views/Components/FCPXMLDropModifier.swift` (`.fcpxmlDropDestination`) |
| FCPXML UTTypes | `Utilities/Extensions/UTTypeExtension.swift` — public `UTType.fcpxml` / `.fcpxmld` via private `finalCutProType` (`UTType(identifier) ?? UTType(importedAs:identifier, conformingTo:)` — never `!`); `Source/Marker Data/Marker-Data-Info.plist` `UTImportedTypeDeclarations` + Asset Description File `LSItemContentTypes` |
| File menu | `Views/Menu Bar Commands/FileCommands.swift` — replaces `.newItem` (Open Pagemaker ⌘P, Install Share Destination, Show/Clean Cache ⌘K); system Close stays last |
| Info.plist | `Source/Marker Data/Marker-Data-Info.plist` — Sparkle, Share Destination document types (**Asset Description File** name is a contract), imported FCPXML UTIs |
| Drop overlay (Extract / Roles / Queue + WE) | `Views/Components/DropTargetOverlay.swift` (also Workflow Extension Compile Sources) |
| Workflow Extension UI | `Source/Marker Data/Workflow Extension/WorkflowExtensionView.swift` — Extract + Roles tabs; **two** Compile Sources rows (main app + appex — do not delete the main-app membership). `WorkflowExtensionViewController.swift` is appex-only. |
| Color helpers (`markerAccent`, `heroGradient`) | `Utilities/Extensions/ColorExtension.swift` |
| Queue UI | `Views/Detail Views/QueueView.swift` |
| Queue scan/upload | `Models/Queue/QueueModel.swift` |
| Queue row + local-first manifest | `Models/Queue/QueueInstance.swift` (`manifestURL`) |
| Database uploads | `Models/Extract/DatabaseUploader.swift` |
| Progress aggregation | `Models/Extract/ProgressViewModel.swift` (`applyTaskAppearance`, `markAllProcessesFinished`, `markProcessAsFinished`) |
| Color swatch render | `Models/Color Swatch/ColorPaletteRenderer.swift` (`render(...) -> Bool`; `await applyTaskAppearance` after image checks) |
| Failed Tasks window | `Views/Other/FailedExtractionsView.swift` |
| Settings schema | `Source/Marker Data/Marker Data/Models/Settings/SettingsStore.swift` (`static let version` — currently **8**) |
| Settings container / configs | `Source/Marker Data/Marker Data/Models/Settings/SettingsContainer.swift` |
| Settings migrations | `Source/Marker Data/Marker Data/Models/Settings/SettingsVersioningManager.swift` |
| Canonical disk paths | `Source/Marker Data/Marker Data/Utilities/Extensions/URLExtension.swift` |
| Notification names | `Source/Marker Data/Marker Data/Utilities/Extensions/NotificationNameExtension.swift` |
| App / dialog icon | `Views/Extensions/DialogIcon.swift` — `@MainActor` `MarkerDataAppIcon` + `.appDialogIcon()`; Icon Composer `Marker-Data.icon` |
| About | `Views/Detail Views/AboutView.swift` — `MarkerDataAppIcon.image()` at 200×200 |
| Workflow Extension header icon | Same `MarkerDataAppIcon.image()` at 100×100; in the appex, resolve from containing `Marker Data.app` |
| Apple Event open | `FCP Share Destination/OpenEventHandler.swift` — `kAEOpen` → `.openFile`; re-register on `.FCPShareStart` (main queue) |
| Roles (app + WE) | `Models/Roles/RolesManager.swift` + `RolesManager+DropDelegate.swift` — reads/writes `preferences.json` (no `SettingsContainer` in the appex) |
| Uninstaller | `Marker Data Uninstaller/MarkerDataUninstaller.swift` — path list must match runtime paths |

## Build & run (local)
1. Open `Source/Marker Data/Marker Data.xcodeproj`.
2. Select the **Marker Data** scheme.
3. Build/run for **Apple Silicon** (`arm64`). Do not target Intel.

**Unsigned verification** (CI-equivalent; Debug **and** Release after code or agent-doc changes):

```bash
xcodebuild -project "Source/Marker Data/Marker Data.xcodeproj" \
  -scheme "Marker Data" \
  -configuration Debug \
  -destination "platform=macOS,arch=arm64" \
  ONLY_ACTIVE_ARCH=NO EXCLUDED_ARCHS="x86_64" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

Repeat with `-configuration Release`. A good result is an adhoc/linker-signed thin **arm64** `Marker Data.app` with `Contents/PlugIns/Workflow Extension.appex` and `Uninstall Marker Data.app` beside it. This machine may redirect `SYMROOT` outside `-derivedDataPath`; confirm the Products folder actually contains those apps.

CI installs the Workflow Extensions SDK from `SDK/Workflow_Extensions_1.0.3.dmg` (the folder may also contain an unused older `1.0.2` DMG). Locally you need that SDK under `/Library/Developer/SDKs/WorkflowExtensionSDK.sdk` to build the extension target.

**SwiftFormat** (courtesy, not CI-enforced): from repo root, `swiftformat .` — see `CONTRIBUTING.md`.

## CI / release basics

| Fact | Value |
|------|--------|
| Runner | `macos-26` |
| Xcode (workflows) | **`Xcode_26.6.0`** (`sudo xcode-select -s /Applications/Xcode_26.6.0.app/...`) |
| Architecture | `arch=arm64`, `EXCLUDED_ARCHS=x86_64` |
| PR/push build | `.github/workflows/build.yml` |
| Test (notarized) builds | `test_build.yml`, `test_build_debug.yml` |
| Full release + Sparkle appcast | `release_github.yml` |
| Release without appcast | `release_github_non-appcast.yml` |
| Refresh bundled CLIs / Pagemaker | `update_airlift_binary.yml`, `update_csv2notion_neo_binary.yml`, `update_pagemaker.yml` |

Release flow (high level):
1. Build **Marker Data** scheme (main app + Uninstall Marker Data).
2. Copy `Marker Data.app` and `Uninstall Marker Data.app` into `latest-build/`.
3. Codesign: Workflow Extension → Sparkle framework/XPC helpers → main app → Uninstaller.
4. Notarize; package DMG with `appdmg` + `Distribution/dmg-builds/build-marker-data-dmg.json`.
5. Sparkle: feed is `appcast.xml`; updated by `Distribution/dmg-builds/sparkle/generate_appcast_script.py`.

Shipping philosophy: distribute the **Derived Data Release `.app`**, not an Archive (debuggability / reproducibility — see `CONTRIBUTING.md`).

When bumping a release: update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.pbxproj` (all target occurrences), `CHANGELOG.md`, `Distribution/version.txt`, and website release-notes pages per `CONTRIBUTING.md`.

## Code conventions & expectations
- **Formatting:** SwiftFormat (`CONTRIBUTING.md`).
- **Threading:**
  - UI-driving models are `@MainActor` (`ExtractionModel`, `QueueModel`, `SettingsContainer`, `DatabaseManager`, etc.).
  - Extraction/upload use `Task` / `TaskGroup`; cancellation via `Task.cancel()` and terminating child `Process`es.
- **Persistence:** versioned JSON under Application Support (see Settings system). Database profiles are separate JSON files.
- **External tools:** Notion/Airtable uploads spawn bundled executables; treat binaries as opaque. Progress UI depends on stdout lines containing `NN%`.
- **Colors / icons:** `MarkerDataAppIcon` is `@MainActor` (`DialogIcon.swift`). Main-app Dock / About / alerts use Icon Composer `Marker-Data.icon`. Workflow Extension **header** loads that icon from the containing `Marker Data.app` (not the appex `AppIcon.appiconset`). Do **not** flatten the layer PNG into `AppIconSingle`. Shared Workflow Extension chrome uses `Color.markerAccent` (not host `accentColor`).
- **Shared Compile Sources:** one file on disk can appear **twice** in `project.pbxproj` (`PBXBuildFile` “in Sources”) — main app + Workflow Extension. That is target membership, not a duplicate file. Never delete one row to “dedupe”. Full extension membership list: **ARCHITECTURE.md → Workflow Extension target**.

## Settings system (read before changing preferences)

Marker Data settings are **versioned JSON**. The active store is `preferences.json`; named presets live in `Configurations/*.json`. Both use the same `SettingsStore` schema.

**Configuration names must be unique:** `saveCurrentAs` / `duplicateStore` / rename throw `ConfigurationSaveError.nameAlreadyExists` when a name already exists in memory **or** on disk. Never overwrite `{name}.json` silently. Rename prefills the current name; rename-to-same-name is a no-op; add/rename sheets dismiss only on success.

### Core files

| File | Role |
|------|------|
| `SettingsStore.swift` | Codable schema; `static let version` (currently **8**); `defaults()`; `markersExtractorSettings(fcpxmlFileUrl:)` |
| `SettingsContainer.swift` | `@MainActor` `ObservableObject`; load/save; configuration CRUD; auto-save on `$store` |
| `SettingsVersioningManager.swift` | Dict-based migrations **before** `JSONDecoder` |
| `SettingsModels.swift` | Supporting enums (`ImageMode`, font types, etc.) |
| `ConfigurationsViewModel.swift` | Thin UI facade over `SettingsContainer` |
| `RolesManager.swift` | Exception path: read/write `preferences.json` directly for Workflow Extension sync |

### How it works (short)

1. **Launch:** `SettingsContainer.init()` → `Task.synchronous { SettingsVersioningManager.updateAll() }` migrates every settings JSON on disk, **then** decode `preferences.json` / configurations.
2. **Runtime:** UI binds via `@EnvironmentObject SettingsContainer` and `$settings.store.<property>`.
3. **Auto-save:** any change to `store` writes `preferences.json` immediately.
4. **Extraction:** `SettingsStore.markersExtractorSettings(fcpxmlFileUrl:)` maps store → `MarkersExtractor.Settings` (not automatic — wire new export-related fields here). Roles are **reloaded from disk** inside this method.
5. **Roles exception:** `RolesManager` reads/writes `preferences.json` and posts DistributedNotification `.rolesChanged`. Main app `SettingsContainer` observes that and reloads the store. The Workflow Extension uses this path only (no `SettingsContainer`, no `SettingsVersioningManager`).

### Migration ladder (each `case N` upgrades N → N+1)

| From | Change |
|------|--------|
| 1 | Add nested `colorSwatchSettings` |
| 2 | Add `includeDisabledClips` (default `false`) |
| 3 | Swatch: `excludeGray` |
| 4 | Swatch: `accuracy` |
| 5 | Add `useChapterMarkerThumbnails` |
| 6 | Rename ID mode `projectTimecode` → `timelineNameAndTimecode` |
| 7 | Add `allowUTF8InMIDIExport` (default `false`) |

Current schema version is **8**. Adding a property requires a new `case 8:` (8 → 9) and bumping `SettingsStore.version` to **9**.

### Checklist: add or change a persisted setting

| Step | Action |
|------|--------|
| 1 | Add property to `SettingsStore`; set default in `defaults()` |
| 2 | **Bump `SettingsStore.version`** by 1 |
| 3 | Add `case <previousVersion>:` in `SettingsVersioningManager.upgradeVersion(dict:version:)` |
| 4 | Add UI binding under `Views/Detail Views/` |
| 5 | If export-related: pass through `markersExtractorSettings(fcpxmlFileUrl:)` |
| 6 | If MarkersExtractor gained a new API: bump the SPM package in `project.pbxproj` (currently minimum **0.4.8**) |
| 7 | Confirm old `preferences.json` / `Configurations/*.json` migrate and the app still loads settings |

**Always migrate** when adding/removing/renaming persisted keys. **Never** rely on `Codable` defaults alone for existing on-disk files.

The Workflow Extension **compiles `SettingsStore.swift`** and decodes `preferences.json` via `RolesManager` **without** running `SettingsVersioningManager`. After a schema bump, the main app must launch once so migrations write before the extension can decode.

**Reference implementation:** `allowUTF8InMIDIExport` (issue #148) — property, v7→v8 migration, `FileSettingsView` toggle, `isMIDIFileUTF8EncodingAllowed` in `markersExtractorSettings`. MarkersExtractor SPM minimum in `project.pbxproj` is **0.4.8**.

### Known settings gaps (do not “fix” casually without product intent)
These fields exist in UI / `SettingsStore` but are **not** currently passed into `MarkersExtractor.Settings`:
- `enabledNoMedia` (“Skip Image Generation” in File settings)
- `fontStyleType` (Label appearance picker)

Also: getter for `colorSwatchSettings` **forces `enableSwatch = false` when extract profile is `.xlsx`**.

## “When you change X, also change Y”

### SettingsStore / preferences
- Increment version + migration + UI + optional `markersExtractorSettings` (checklist above).

### New export fields / overlays
- Update `OverlaySettingsView` (and Notion merge-only column lists where relevant).
- Ensure `MarkersExtractor` / manifest fields support it; bump package if needed.

### New database platform
- Add `DatabasePlatform` case.
- Add a `DatabaseProfileModel` subclass + validation + Codable.
- Update `DatabaseManager.loadProfilesFromDisk()` and `DatabaseUploader.uploadToDatabase(...)`.
- Update UI sheets/pickers (Database settings + export profile picker).
- Note: existing property spelling is `plaform` on `DatabaseProfileModel` — keep consistent when extending.

### FCP integrations
- Share Destination: `Resources/OSAScriptingDefinition.sdef` + Obj‑C under `FCP Share Destination/Objective-C Code/` + Swift `OpenEventHandler`. Keep the **Asset Description File** document type name (`DocumentController` matches it).
- Workflow Extension: DistributedNotificationCenter names + fixed Movies-cache FCPXML path; roles via `preferences.json`. Appex `Info.plist` `ProExtensionAttributes` are 700×550 (FCP host min); SwiftUI frame is 600×400. `WorkflowExtensionView.swift` has two Compile Sources rows.
- Extract panel intake: `FCPXMLIntake` / `FCPXMLDropModifier` — keep Dock Open With (`OpenEventHandler`) and Share Destination paths distinct.
- FCPXML UTTypes: public `UTType.fcpxml` / `.fcpxmld` (private `finalCutProType`, never `!`) + `Marker-Data-Info.plist` `UTImportedTypeDeclarations` / Asset Description File `LSItemContentTypes`.

### File menu
- Custom File items live in `FileCommands` as `CommandGroup(replacing: .newItem)`.
- Do **not** also empty `.newItem` in `Marker_DataApp` (that puts system Close first). Emptying `.toolbar` in `Marker_DataApp` is unrelated (removes the default View-menu toolbar group).
- Do **not** add a Close item — system Close / Close All remain last.
- Current items (in order): **Open Pagemaker** (⌘P) → **Install FCP Share Destination…** → **Show Cache** / **Clean Cache** (⌘K). Extract **Choose File** still uses ⌘O on the Extract panel (`FilePicker`), not the File menu. Extract completion also shows **Open Pagemaker** when the profile is extract-only Notion or Airtable.

### Drop overlay / shared Workflow Extension UI
- Update copy in **`GUARDRAILS.md`** (Drop overlay copy table) when changing messages.
- Workflow Extension **Extract** (`WorkflowExtensionView`) and **Roles** (shared `RolesSettingsView`) both show overlays.
- Shared types must stay in **both** targets’ Compile Sources (two `PBXBuildFile` rows, one `PBXFileReference`). Minimum shared UI: `DropTargetOverlay`, `ColorExtension`, `DialogIcon.swift`, `HelpButton`, `OverlayHelpButton`. `WorkflowExtensionView.swift` is also dual-membership (appex UI; do not delete the main-app Compile Sources row). `WorkflowExtensionViewController.swift` is appex-only. Roles/settings files listed in **ARCHITECTURE.md**. Shared chrome uses `Color.markerAccent`.

### App icon / dialogs
- Icon Composer **`Marker-Data.icon`** (`ASSETCATALOG_COMPILER_APPICON_NAME` = Marker-Data) lives beside the catalog — **not** inside `Assets.xcassets`. Main-app `AppIcon.appiconset` is an empty placeholder. Never flatten the layer PNG into `AppIconSingle` (imageset removed).
- `MarkerDataAppIcon` is **`@MainActor`** (Marker Data does **not** set `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; a nonisolated `NSApplication.shared.applicationIconImage` read warns under Swift 6).
- **Resolution (`displayIcon`):**
  1. If running as `.appex`: load from the containing `Marker Data.app` (`appex` → `PlugIns` → `Contents` → `.app`): `Bundle.image(forResource: "Marker-Data")`, else `NSWorkspace.icon(forFile:)`. Do **not** use the appex’s `applicationIconImage` (that is `AppIcon.appiconset`, or Final Cut Pro).
  2. Else: `NSImage(named: "Marker-Data")`, then `NSApplication.shared.applicationIconImage`.
- **Surfaces:** About `MarkerDataAppIcon.image()` **200×200**; Workflow Extension header **100×100**; alerts **and** confirmation dialogs `.appDialogIcon()`.
- **Main-app `.alert` / `.confirmationDialog` (chain `.appDialogIcon()`):** `Marker_DataApp` (library folders); `ContentView` (install location); `ExtractView` (extract + upload, ×2); `ConfigurationSettingsView` (unsaved-switch, unsaved-add, and delete confirmations + alert); `DatabaseSettingsView` (remove + duplicate alerts, ×2, plus delete-profile confirmation); `CreateDBProfileSheet`; `DropboxSetupView`; `InstallShareDestinationView`.
- Uninstaller is a **separate target**: `UninstallerView` uses `NSApplication.shared.applicationIconImage`, not `MarkerDataAppIcon`.
- Do **not** change the Workflow Extension’s bundle/plugin icon (`ASSETCATALOG_COMPILER_APPICON_NAME` = AppIcon, existing `AppIcon.appiconset`).
- Workflow Extension Compile Sources must include `DialogIcon.swift` (header UI). Keep Extract/Roles `TabView` `.padding(.bottom, 40)` so `overlayHelpButton` does not sit on the drop zone.

### Uninstaller cleanup paths
- If the app/extension gains new Application Support, cache, container, or preferences paths, update `MarkerDataUninstaller.run()` path list to match.

### Release metadata
- `project.pbxproj` versions, `CHANGELOG.md`, `Distribution/version.txt`, website notes (`CONTRIBUTING.md`).

### Agent documentation
- Keep `AGENT.md`, `ARCHITECTURE.md`, `GUARDRAILS.md`, and `.cursorrules` aligned when flows, paths, or invariants change.

## Extract / Roles / Queue drop surfaces

| Surface | Intake | Overlay |
|---------|--------|---------|
| **Extract** | `.fcpxmlDropDestination` → `ExtractionModel.receiveItemProviders` → `FCPXMLIntake` (FCP pasteboard, `.fcpxml`/`.fcpxmld`, `.textClipping`). Dock/Finder Open With still via `OpenEventHandler` → `.openFile`. | `DropTargetOverlay()` defaults + hero caption *“Drop a timeline from Final Cut Pro, or an .fcpxml / .fcpxmld file”* |
| **Extract** (Workflow Extension) | `WorkflowExtensionView` `.onDrop([.fcpxml])` → Movies-cache handoff → open app → `.workflowExtensionFileReceived` | `DropTargetOverlay(message: "Drop to Open Marker Data", subtitle: nil)` |
| **Roles** (app + Workflow Extension) | `RolesManager` `DropDelegate` (`.fcpxml` / file URL); `isDropTargeted` from `dropEntered` / `dropExited` | `DropTargetOverlay(message: "Drop to Retrieve Roles Metadata", subtitle: nil)` |
| **Queue** | `.dropDestination(for: URL.self)` → `QueueModel.performDrop` (directories only; clears queue; scans for `extract_info.json`; disables auto-scan) | `DropTargetOverlay(message: "Drop Extract Folders (Notion or Airtable) into Queue", subtitle: nil, systemImage: "folder.fill")`; hidden while uploading |

**Queue manifest resolution:** `QueueInstance.manifestURL` prefers `{folder}/{json basename}` when that file exists (moved/copied exports), else falls back to absolute `ExtractInfo.jsonURL`. Uploads and `filterMissing()` must use `manifestURL`, not the sidecar path alone.

**Progress across extract → swatch:** `ColorPaletteRenderer.render(...) -> Bool`. Inside renderer, after image checks pass, `await progress.applyTaskAppearance("Analysing swatch", ...)` (MainActor). Returns `false` on skip (no images / unsupported GIF) → ExtractionModel uses `markProcessAsFinished` (**“Extract done”**). Returns `true` → `markAllProcessesFinished` (required because `ImageRenderService.export` calls `setProcesses` with **image** URLs, replacing the extract FCPXML rows). Never `reset()` when entering swatch. Ignore late KVO after a process is finished.

**Temporary pasteboard FCPXML:** `FCPXMLIntake.writeTemporaryFCPXML` → `~/Movies/Marker Data Cache/` (creates the cache folder if needed).

**Workflow Extension:** Extract + Roles tabs both use `DropTargetOverlay` (`WorkflowExtensionView` / shared `RolesSettingsView`); also shares `RolesManager` / `ColorExtension` / `DialogIcon` (`MarkerDataAppIcon`) / `HelpButton` / `OverlayHelpButton` plus the settings/roles files in **ARCHITECTURE.md**. Shared chrome uses `Color.markerAccent` (not host `accentColor`). Header icon: containing `Marker Data.app`, not appex `AppIcon.appiconset`. Extract/Roles `TabView` uses `.padding(.bottom, 40)` so the drop zone stays above the help “?”. The extension **writes** `WorkflowExtensionExport.fcpxml` but does **not** create `~/Movies/Marker Data Cache/` — the main app’s `LibraryFolders.checkAndCreateMissing()` does.

Exact overlay strings and always/never rules: **`GUARDRAILS.md`**.

## Notification & handoff cheat sheet

| Name | Center | Role |
|------|--------|------|
| `OpenFile` | Local `NotificationCenter` | Apple Event open → `ExtractionModel` / sidebar |
| `WorkflowExtensionFileReceived` | **Distributed** | Extension wrote cache FCPXML → app |
| `RolesChanged` | **Distributed** | Roles saved (app or extension) → peers reload |
| `FCPShareStart` | Local (`NSNotification` from Obj‑C) | Re-register Apple Event open handler |
| `updateAvailable` | Local | Sparkle delegate → sidebar badge |

**Workflow Extension file:** `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml` (`URL.workflowExtensionExportFCPXML`).  
**App open path hard-coded by extension:** `/Applications/Marker Data.app`.  
**`OpenEventHandler.setupHandler()`** is invoked from `init`, from `.FCPShareStart`, and again from `Marker_DataApp` `.task` — keep the `DispatchQueue.main.async` registration (see comments in that file).

## Common pitfalls
- **Don’t break migrations:** settings JSONs in the wild must upgrade step-by-step.
- **Don’t overwrite configuration names** silently — throw `nameAlreadyExists`.
- **Entitlements & signing:** Apple Events, sandbox Movies access, PyInstaller-helper allowances — coordinate with distribution entitlements.
- **Install location:** app warns if not under `/Applications` (`ContentView`); Workflow Extension opens that path — do not remove the check.
- **Opaque helpers:** only the CLI args in `DatabaseUploader` / `DropboxSetupModel` are the contract.
- **Queue scope:** `extract_info.json` is written only when the export profile is Notion/Airtable **and** a JSON manifest path exists. Queue will not list pure CSV/XLSX/etc. extract folders.
- **Queue relocated folders:** never upload only `ExtractInfo.jsonURL` — use `manifestURL` (see Signs in `GUARDRAILS.md`).
- **Progress `reset()` / wrong swatch label:** never `reset()` before swatch; never retitle to “Analysing swatch” until render will run. Skipped swatch must finish as **“Extract done”**, not **“Analysing swatch done”**. `await applyTaskAppearance` from `ColorPaletteRenderer` (MainActor).
- **FCP timeline → Dock:** often pasteboard-only; Extract panel drop is the supported UI path for timelines.
- **Alert / confirmation icons:** chain `.appDialogIcon()` after every `.alert` and `.confirmationDialog`. `MarkerDataAppIcon` is `@MainActor`; source is compiled `Marker-Data.icon`. Do not flatten the layer PNG into `AppIconSingle`. In the Workflow Extension header, load from the containing `Marker Data.app` — not the appex `AppIcon.appiconset`.
- **Dual Sparkle controllers:** both `Marker_DataApp` and `ApplicationDelegate` construct `SPUStandardUpdaterController`; update-available UI relies on `ApplicationDelegate.bestValidUpdate(...)` posting `.updateAvailable`. Don’t “simplify” without understanding that path.
- **`OpenEventHandler`:** must re-register on `.FCPShareStart`; registration should stay on the main queue (see comments in that file).
- **Shared `pbxproj` rows:** do not remove a second `DialogIcon.swift in Sources` (or other shared files) — the file is compiled into two targets.
- **Persisted typos:** do not rename JSON key `plaform` without a migration.
- **WE cache folder:** the extension does not `mkdir` Movies cache; a first-time drop can fail if the main app has never created `~/Movies/Marker Data Cache/`.
- **FCPXML `UTType` force-unwrap:** `UTType("com.apple.finalcutpro.xml")!` traps on first Extract layout when Final Cut Pro is not installed (App Preview / machines without FCP). Resolve with `UTType(identifier) ?? UTType(importedAs:identifier, conformingTo:)` and keep `UTImportedTypeDeclarations` in `Marker-Data-Info.plist`. Do not split the Share Destination **Asset Description File** document type.
- **File menu Close last:** custom File items replace `.newItem` (`FileCommands`). Do not empty `.newItem` (that puts system Close first) and do not add a second Close.

## Definition of done for most changes
- App builds **unsigned** Debug **and** Release for **arm64** (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`; Workflow Extension still embeds).
- Settings still load and migrate cleanly (`preferences.json` + `Configurations/*.json`).
- Extraction works for `.fcpxml` and `.fcpxmld`, including FCP pasteboard / textClipping intake via `FCPXMLIntake`.
- FCPXML `UTType`s still use `importedAs` fallback (no `!`); Info.plist still has `UTImportedTypeDeclarations`; Share Destination **Asset Description File** type is unchanged.
- File menu still replaces `.newItem` with app actions; system Close stays last (no second Close; do not empty `.newItem`).
- Drop overlays still work on main-app Extract / Roles / Queue **and** Workflow Extension Extract + Roles.
- Queue scan/upload still works for folders containing `extract_info.json`, including **moved/copied** folders (`manifestURL`).
- Skipped / no-media swatch finishes as **“Extract done”** (not **“Analysing swatch done”**).
- Any new `.alert` or `.confirmationDialog` uses `.appDialogIcon()` (`MarkerDataAppIcon` from compiled `Marker-Data.icon`).
- Workflow Extension header still shows the main-app Icon Composer icon (containing `Marker Data.app`); bundle/plugin `AppIcon.appiconset` unchanged.
- If settings changed: version bumped + migration case + UI wired + export bridge if needed.
- If behavior/architecture changed: update `AGENT.md`, `ARCHITECTURE.md`, `GUARDRAILS.md`, and `.cursorrules`.
