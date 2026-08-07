# AGENT.md

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
| `@main` app | `Source/Marker Data/Marker Data/Marker_DataApp.swift` — constructs `SettingsContainer`, `DatabaseManager`, `ExtractionModel`, `QueueModel`; menu commands; Failed Tasks + Pagemaker windows |
| AppKit / Sparkle delegate | `Source/Marker Data/Marker Data/ApplicationDelegate.swift` |
| Sidebar navigation | `Source/Marker Data/Marker Data/Views/Main/ContentView.swift` (`MainViews` enum) |
| Extract UI | `Source/Marker Data/Marker Data/Views/Main/ExtractView.swift` |
| Extraction orchestration | `Source/Marker Data/Marker Data/Models/Extract/Extraction Model/ExtractionModel.swift` |
| External handoffs (open / Workflow Extension) | `.../ExtractionModel_EventHandlers.swift` |
| FCPXML intake (files / pasteboard / textClipping) | `Utilities/Other/FCPXMLIntake.swift`, `TextClippingReader.swift` |
| Extract drop modifier | `Views/Components/FCPXMLDropModifier.swift` (`.fcpxmlDropDestination`) |
| Drop overlay (Extract / Roles / Queue) | `Views/Components/DropTargetOverlay.swift` |
| Queue UI | `Views/Detail Views/QueueView.swift` |
| Queue scan/upload | `Models/Queue/QueueModel.swift` |
| Queue row + local-first manifest | `Models/Queue/QueueInstance.swift` (`manifestURL`) |
| Database uploads | `Models/Extract/DatabaseUploader.swift` |
| Progress aggregation | `Models/Extract/ProgressViewModel.swift` (`applyTaskAppearance`, `markAllProcessesFinished`) |
| Failed Tasks window | `Views/Other/FailedExtractionsView.swift` |
| Settings schema | `Source/Marker Data/Marker Data/Models/Settings/SettingsStore.swift` (`static let version` — currently **8**) |
| Settings container / configs | `Source/Marker Data/Marker Data/Models/Settings/SettingsContainer.swift` |
| Settings migrations | `Source/Marker Data/Marker Data/Models/Settings/SettingsVersioningManager.swift` |
| Canonical disk paths | `Source/Marker Data/Marker Data/Utilities/Extensions/URLExtension.swift` |
| Notification names | `Source/Marker Data/Marker Data/Utilities/Extensions/NotificationNameExtension.swift` |
| Alert dialog icon helper | `Source/Marker Data/Marker Data/Views/Extensions/DialogIcon.swift` (`.appDialogIcon()`) |

## Build & run (local)
1. Open `Source/Marker Data/Marker Data.xcodeproj`.
2. Select the **Marker Data** scheme.
3. Build/run for **Apple Silicon** (`arm64`). Do not target Intel.

CI installs the Workflow Extensions SDK from `SDK/Workflow_Extensions_1.0.3.dmg` before `xcodebuild`. Locally you need the same SDK installed under `/Library/Developer/SDKs/WorkflowExtensionSDK.sdk` to build the extension target.

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
- **Colors / icons:** Dock icon is Icon Composer (`Marker-Data.icon`). SwiftUI `.alert` often shows a blank document glyph — always chain `.appDialogIcon()` after `.alert` / confirmation dialogs.

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
5. **Roles exception:** `RolesManager` reads/writes `preferences.json` and posts DistributedNotification `.rolesChanged`. Main app `SettingsContainer` observes that and reloads the store.

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
| 6 | If MarkersExtractor gained a new API: bump the SPM package in `project.pbxproj` (currently minimum **0.4.6**) |
| 7 | Confirm old `preferences.json` / `Configurations/*.json` migrate and the app still loads settings |

**Always migrate** when adding/removing/renaming persisted keys. **Never** rely on `Codable` defaults alone for existing on-disk files.

**Reference implementation:** `allowUTF8InMIDIExport` (issue #148) — property, v7→v8 migration, `FileSettingsView` toggle, `isMIDIFileUTF8EncodingAllowed` in `markersExtractorSettings`, MarkersExtractor 0.4.6.

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
- Share Destination: `Resources/OSAScriptingDefinition.sdef` + Obj‑C under `FCP Share Destination/Objective-C Code/` + Swift `OpenEventHandler`.
- Workflow Extension: DistributedNotificationCenter names + fixed Movies-cache FCPXML path; roles via `preferences.json`.
- Extract panel intake: `FCPXMLIntake` / `FCPXMLDropModifier` — keep Dock Open With (`OpenEventHandler`) and Share Destination paths distinct.

### Drop overlay / shared Roles UI
- Update copy in **`GUARDRAILS.md`** (Drop overlay copy table) when changing messages.
- If Roles overlay types change, ensure Workflow Extension Compile Sources still include them (`DropTargetOverlay`, `ColorExtension`).

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
| **Roles** (app + Workflow Extension) | `RolesManager` `DropDelegate` (`.fcpxml` / file URL); `isDropTargeted` from `dropEntered` / `dropExited` | `DropTargetOverlay(message: "Drop to Retrieve Roles Metadata", subtitle: nil)` |
| **Queue** | `.dropDestination(for: URL.self)` → `QueueModel.performDrop` (directories only; clears queue; scans for `extract_info.json`; disables auto-scan) | `DropTargetOverlay(message: "Drop Extract Folders (Notion or Airtable) into Queue", subtitle: nil, systemImage: "folder.fill")`; hidden while uploading |

**Queue manifest resolution:** `QueueInstance.manifestURL` prefers `{folder}/{json basename}` when that file exists (moved/copied exports), else falls back to absolute `ExtractInfo.jsonURL`. Uploads and `filterMissing()` must use `manifestURL`, not the sidecar path alone.

**Progress across extract → swatch:** use `applyTaskAppearance` (do not `reset()` before swatch). Empty image sets: early-return in renderers + `markAllProcessesFinished()`. Ignore late KVO after a process is finished.

**Temporary pasteboard FCPXML:** `FCPXMLIntake.writeTemporaryFCPXML` → `~/Movies/Marker Data Cache/`.

**Workflow Extension:** shares `RolesSettingsView` / `RolesManager` / `DropTargetOverlay` / `ColorExtension`. Add shared UI types to the extension target’s Compile Sources. Prefer `Color.accentColor` in shared views (extension SDK may lack `Color.accent`).

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

## Common pitfalls
- **Don’t break migrations:** settings JSONs in the wild must upgrade step-by-step.
- **Don’t overwrite configuration names** silently — throw `nameAlreadyExists`.
- **Entitlements & signing:** Apple Events, sandbox Movies access, PyInstaller-helper allowances — coordinate with distribution entitlements.
- **Install location:** app warns if not under `/Applications` (`ContentView`); Workflow Extension opens that path — do not remove the check.
- **Opaque helpers:** only the CLI args in `DatabaseUploader` / `DropboxSetupModel` are the contract.
- **Queue scope:** `extract_info.json` is written only when the export profile is Notion/Airtable **and** a JSON manifest path exists. Queue will not list pure CSV/XLSX/etc. extract folders.
- **Queue relocated folders:** never upload only `ExtractInfo.jsonURL` — use `manifestURL` (see Signs in `GUARDRAILS.md`).
- **Progress `reset()` before swatch:** can leave the bar at 0% when there are no stills — use `applyTaskAppearance`.
- **FCP timeline → Dock:** often pasteboard-only; Extract panel drop is the supported UI path for timelines.
- **Alert icons:** chain `.appDialogIcon()` after every `.alert`.
- **Dual Sparkle controllers:** both `Marker_DataApp` and `ApplicationDelegate` construct `SPUStandardUpdaterController`; update-available UI relies on `ApplicationDelegate.bestValidUpdate(...)` posting `.updateAvailable`. Don’t “simplify” without understanding that path.
- **`OpenEventHandler`:** must re-register on `.FCPShareStart`; registration should stay on the main queue (see comments in that file).

## Definition of done for most changes
- App builds (Debug + Release) for **arm64** (Workflow Extension still embeds).
- Settings still load and migrate cleanly (`preferences.json` + `Configurations/*.json`).
- Extraction works for `.fcpxml` and `.fcpxmld`, including FCP pasteboard / textClipping intake via `FCPXMLIntake`.
- Drop overlays still work on Extract, Roles (app + extension), and Queue.
- Queue scan/upload still works for folders containing `extract_info.json`, including **moved/copied** folders (`manifestURL`).
- Any new `.alert` uses `.appDialogIcon()`.
- If settings changed: version bumped + migration case + UI wired + export bridge if needed.
- If behavior/architecture changed: update `AGENT.md`, `ARCHITECTURE.md`, `GUARDRAILS.md`, and `.cursorrules`.
