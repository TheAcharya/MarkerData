## Purpose
This repository contains **Marker Data**, a macOS Swift/SwiftUI app that extracts Final Cut Pro marker metadata (via `MarkersExtractor`), optionally renders images/palettes, and can upload results to Notion/Airtable via bundled CLIs. It also ships a **Final Cut Pro Workflow Extension** and a **Share Destination** integration.

This `AGENT.md` is guidance for humans and AI agents working in this repo: how to build, where to look, what to avoid, and how changes should be made.

## What you’re working on
- **Main app (SwiftUI)**: `Source/Marker Data/Marker Data/`
- **Workflow Extension target**: `Source/Marker Data/Workflow Extension/`
- **Uninstaller app (SwiftUI)**: `Source/Marker Data/Marker Data Uninstaller/` — target **Uninstall Marker Data**; product name `Uninstall Marker Data.app`; display name “Marker Data Uninstaller”. Built as part of the Marker Data scheme.
- **Share Destination / scripting bridge**:
  - Swift install UI: `Source/Marker Data/Marker Data/FCP Share Destination/Install View/`
  - Objective‑C scripting/doc controller: `Source/Marker Data/Marker Data/FCP Share Destination/Objective-C Code/`
- **Bundled helper executables** (opaque binaries invoked via `Process`): `Source/Marker Data/Marker Data/Resources/airlift`, `.../csv2notion_neo`
- **Distribution/CI**: `.github/workflows/`, `Distribution/`

## Key entry points (start here)
- **App**: `Source/Marker Data/Marker Data/Marker_DataApp.swift`
  - Constructs `SettingsContainer`, `DatabaseManager`, `ExtractionModel`, `QueueModel`
  - Adds menu commands and extra windows
- **Navigation**: `Source/Marker Data/Marker Data/Views/Main/ContentView.swift`
- **Extraction orchestration**: `Source/Marker Data/Marker Data/Models/Extract/Extraction Model/ExtractionModel.swift`
- **Queue scanning/upload**: `Source/Marker Data/Marker Data/Models/Queue/QueueModel.swift`
- **Database uploads (Notion/Airtable)**: `Source/Marker Data/Marker Data/Models/Extract/DatabaseUploader.swift`
- **Settings schema**: `Source/Marker Data/Marker Data/Models/Settings/SettingsStore.swift`
- **Settings migrations**: `Source/Marker Data/Marker Data/Models/Settings/SettingsVersioningManager.swift`

## Build & run (local)
Open the Xcode project:
- `Source/Marker Data/Marker Data.xcodeproj`

Recommended:
- Build/run on **Apple Silicon**.
- The repo’s CI uses **Xcode 26.3.0** on **macos-26** runners.

## CI / release basics (what to know)
- CI builds use `xcodebuild` and install the Workflow Extensions SDK from `SDK/Workflow_Extensions_1.0.3.dmg`.
- Release workflows: build the **Marker Data** scheme (which includes the **Uninstall Marker Data** target); copy both `Marker Data.app` and `Uninstall Marker Data.app` from build products to `latest-build/`. Codesign: Workflow Extension, Sparkle framework components, main app, then Uninstaller app.
- DMG packaging uses `appdmg` with `Distribution/dmg-builds/build-marker-data-dmg.json`.
- Sparkle feed is `appcast.xml` and is updated by `Distribution/dmg-builds/sparkle/generate_appcast_script.py`.

## Code conventions & repo expectations
- **Formatting**: SwiftFormat is used (see `CONTRIBUTING.md`).
- **Threading model**:
  - Many models are `@MainActor` and are expected to mutate published state on main.
  - Extraction uses `TaskGroup` for parallelism; cancellation is supported via `Task.cancel()`.
- **Persistence**:
  - Settings are stored as JSON in `~/Library/Application Support/Marker Data/` (see `URLExtension.swift`).
  - `SettingsStore.version` is authoritative; schema changes must include migrations.
- **External tools**:
  - Notion/Airtable uploads are done by spawning bundled executables; treat them as opaque.
  - Progress parsing depends on `NN%` output lines.

## “When you change X, also change Y”
- **SettingsStore changes**:
  - Increment `SettingsStore.version`.
  - Add a new migration step in `SettingsVersioningManager.upgradeVersion(...)`.
  - Ensure UI bindings (Settings views) remain consistent.
- **New export fields / overlays**:
  - Update UI in `OverlaySettingsView` (and any Notion merge-only lists).
  - Ensure the export pipeline supports it through `MarkersExtractor` / manifest fields.
- **New database platform**:
  - Add `DatabasePlatform` case.
  - Add a `DatabaseProfileModel` subclass + validation + Codable.
  - Update `DatabaseManager.loadProfilesFromDisk()` and `DatabaseUploader.uploadToDatabase(...)`.
  - Update UI sheets/pickers (Database settings + export profile picker).
- **FCP integrations**:
  - Share Destination scripting contract lives in `Resources/OSAScriptingDefinition.sdef` and Obj‑C files.
  - Workflow Extension communicates via `DistributedNotificationCenter` and shared disk files in Movies cache.

## Common pitfalls
- **Don’t break migrations**: settings JSONs in the wild must be upgradable; never remove keys without a migration plan.
- **Entitlements & signing**: changes that touch Apple Events, sandboxing, or extension behavior may require entitlement updates.
- **Install location**: app expects to run from `/Applications` (warning is shown in `ContentView`).
- **Opaque helpers**: `airlift` / `csv2notion_neo` are binaries; don’t assume internal behavior beyond CLI contracts used in `DatabaseUploader`.

## “Definition of done” for most changes
- App builds (Debug + Release) for arm64.
- Settings still load and migrate cleanly.
- Extraction flow works for `.fcpxml` and `.fcpxmld`.
- Queue scan/upload still works for folders with `extract_info.json`.

