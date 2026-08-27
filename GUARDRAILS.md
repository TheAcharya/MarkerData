# GUARDRAILS.md

Hard constraints for humans and AI agents working in **Marker Data**.  
Read with **`AGENT.md`** (how to change things), **`ARCHITECTURE.md`** (how it works), and **`.cursorrules`** (Cursor enforcement). Keep all four consistent when behavior or architecture changes.

## Table of contents

- [Always](#always)
- [Never](#never)
- [Drop overlay copy (keep in sync with UI)](#drop-overlay-copy-keep-in-sync-with-ui)
- [Signs (learned pitfalls)](#signs-learned-pitfalls)
- [Definition of done (guardrail checklist)](#definition-of-done-guardrail-checklist)

---

## Always

| Area | Rule |
|------|------|
| **Settings** | Bump `SettingsStore.version`, add a dict migration `case`, wire UI, and pass export-related fields through `markersExtractorSettings(fcpxmlFileUrl:)`. |
| **Config names** | Throw `ConfigurationSaveError.nameAlreadyExists` on add / rename / duplicate collisions — never overwrite `{name}.json` silently. |
| **Alerts** | Chain `.appDialogIcon()` after every `.alert` / confirmation dialog (`DialogIcon.swift` → `@MainActor` `MarkerDataAppIcon` from compiled `Marker-Data.icon`). |
| **Extract intake** | Route Finder files, text clippings, and Final Cut Pro pasteboard drops through `FCPXMLIntake` → `ExtractionModel.receiveFiles` / `receiveItemProviders`. |
| **Drop overlays** | Use shared `DropTargetOverlay` on main-app Extract / Roles / Queue **and** Workflow Extension Extract + Roles; keep extension Compile Sources including `DropTargetOverlay` + `ColorExtension` + `DialogIcon.swift` + `HelpButton` / `OverlayHelpButton` (+ shared Roles sources). |
| **Shared WE chrome color** | Use `Color.markerAccent` (system indigo) for overlay borders and other shared chrome hosted in FCP — not `Color.accentColor`. |
| **Queue uploads** | Upload via `QueueInstance.manifestURL` (prefer JSON beside the scanned/dropped folder; fall back to sidecar `jsonURL`). |
| **Progress phases** | Do **not** `ProgressViewModel.reset()` when entering swatch. Call `await applyTaskAppearance` **only inside** `ColorPaletteRenderer` after image checks pass (MainActor). On skip: `markProcessAsFinished` → **“Extract done”**. On render: `markAllProcessesFinished`. |
| **No-media / empty swatch** | `ColorPaletteRenderer.render` returns `false` without retitling; finish the extract URL with `markProcessAsFinished` so the bar never shows **“Analysing swatch done”**. |
| **Install location** | Keep the `/Applications` warning; Workflow Extension opens `/Applications/Marker Data.app`. |
| **Uninstaller** | If the app gains new on-disk paths, update `MarkerDataUninstaller.run()` cleanup list. |
| **Architecture** | Prefer Apple Silicon (`arm64`) only; CI uses `macos-26` + **Xcode 26.6.0**. |
| **Opaque CLIs** | Treat `airlift` / `csv2notion_neo` as black boxes; only the args in `DatabaseUploader` / `DropboxSetupModel` are the contract. |
| **App icon** | Main app: Icon Composer **`Marker-Data.icon`** (name matches `ASSETCATALOG_COMPILER_APPICON_NAME`). Keep the empty main-app `AppIcon.appiconset` placeholder. Do not flatten the layer PNG into `AppIconSingle`. Workflow Extension **header** loads the icon from the containing `Marker Data.app`. Do **not** replace the Workflow Extension bundle/plugin icon (`AppIcon.appiconset`). |

---

## Never

| Area | Rule |
|------|------|
| **Settings keys** | Never remove or rename persisted JSON keys without a migration. |
| **Roles shape** | Never break `roles` / `RoleModel` compatibility between the main app and Workflow Extension (`preferences.json` + `.rolesChanged`). |
| **Share Destination** | Never break `OSAScriptingDefinition.sdef` + Obj‑C `MakeCommand` / Media Asset Protocol without intentional product work. |
| **Workflow Extension path** | Never change `~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml` or the hard-coded `/Applications/Marker Data.app` open without updating both sides. |
| **Queue scope** | Never assume CSV/XLSX/MIDI-only extract folders appear in Queue — only Notion/Airtable jobs with `extract_info.json`. |
| **Absolute Queue paths** | Never upload solely from `ExtractInfo.jsonURL` when a same-named JSON exists in the queue folder (moved/copied exports). |
| **Host accent in WE** | Never rely on `Color.accentColor` / `.accent` for shared UI inside the Workflow Extension (inherits Final Cut Pro’s blue). |
| **`plaform`** | Never “fix” the spelling on database models unless intentionally migrating. |
| **Intel** | Never add `x86_64` as a supported architecture. |
| **Silent config overwrite** | Never replace an existing configuration file because the name already exists. |
| **AppIconSingle flatten** | Never copy the Icon Composer layer PNG into `AppIconSingle` (skips glass / fill). |
| **WE header icon** | Never use the appex `AppIcon.appiconset` / `applicationIconImage` for the Workflow Extension window header — that is the bundle/plugin icon (update separately). |

---

## Drop overlay copy (keep in sync with UI)

| Surface | Message | Icon | Notes |
|---------|---------|------|-------|
| **Extract** (main app) | Default: **“Drop to Extract Marker Metadata”**; subtitle **“Use Marker Data's Share Destination for Image Extraction”**. Hero caption under title: **“Drop a timeline from Final Cut Pro, or an .fcpxml / .fcpxmld file”** | `arrow.down.doc.fill` | Hide while `extractionInProgress`. Border: `Color.markerAccent`; arrow: `Color.heroGradient`. |
| **Extract** (Workflow Extension) | **“Drop to Open Marker Data”** | default | `WorkflowExtensionView` + `isExtractDropTargeted`; `subtitle: nil`; handoff writes Movies-cache FCPXML then opens the app. Idle hint: *“Drag & Drop Final Cut Pro Project to Open Marker Data”*. Header: `MarkerDataAppIcon.image()` 100×100 from containing `Marker Data.app`. `TabView` `.padding(.bottom, 40)` so the drop zone stays above `overlayHelpButton`. |
| **Roles** (app + Workflow Extension) | **“Drop to Retrieve Roles Metadata”** | default | `subtitle: nil`; hide while `loadingInProgress`. |
| **Queue** | **“Drop Extract Folders (Notion or Airtable) into Queue”** | `folder.fill` | `subtitle: nil`; hide while `uploadInProgress`; drop blocked during upload. |

Shared component: `Views/Components/DropTargetOverlay.swift` (main app + Workflow Extension Compile Sources).

---

## Signs (learned pitfalls)

1. **`extract_info.json` stores absolute `jsonURL`.** After the user moves/copies an export folder, uploading the sidecar path fails (`FileNotFoundError`). Always resolve with `manifestURL`.
2. **Progress `reset()` before swatch** clears processes and can leave 0% — never reset when entering swatch. Retitle with `await applyTaskAppearance` only after `ColorPaletteRenderer` confirms images (returns `true`); then `markAllProcessesFinished`. If render returns `false`, keep **“Extract done”** via `markProcessAsFinished` (avoids **“Analysing swatch done”** with no stills).
3. **`applyTaskAppearance` is `@MainActor`.** From `ColorPaletteRenderer` (nonisolated), call `await progress.applyTaskAppearance(...)` — a bare call fails isolation.
4. **Ignore late KVO** after a process is marked finished (`ProgressViewModel.updateProgress`) or the bar can bounce backward.
5. **FCP timeline → Dock** often cannot deliver a file URL (pasteboard-only). Supported paths: drop on Extract panel, open `.fcpxml`/`.fcpxmld` via Dock/Finder Open With, Workflow Extension / Share Destination handoffs.
6. **Temporary FCP pasteboard XML** is written under `~/Movies/Marker Data Cache/` (`FCPXMLIntake.writeTemporaryFCPXML`) — Marker Data convention, not App Support Cache.
7. **Workflow Extension accent:** `Color.accentColor` / `.accent` inside the appex often resolves to Final Cut Pro’s blue. Shared chrome (e.g. `DropTargetOverlay` border) must use `Color.markerAccent` (system indigo, matching Assets `AccentColor`). Extension Compile Sources must still include `DropTargetOverlay` + `ColorExtension` + `DialogIcon.swift` + `HelpButton` / `OverlayHelpButton`.
8. **Workflow Extension Extract vs Roles:** Extract handoff lives in `WorkflowExtensionView` (`.onDrop([.fcpxml])`); Roles uses shared `RolesSettingsView` / `RolesManager` `DropDelegate`. Both show overlays — do not assume only Roles has one.
9. **Icon Composer dialogs / WE header:** SwiftUI `.alert` still needs `.appDialogIcon()` (`@MainActor` `MarkerDataAppIcon` from compiled `Marker-Data.icon`). Do not flatten the layer PNG into `AppIconSingle` (skips glass / fill). Workflow Extension **header** loads the icon from the containing `Marker Data.app` (`appex` → `PlugIns` → `Contents` → `.app`) — the appex’s `applicationIconImage` is its `AppIcon.appiconset` (or Final Cut Pro). Leave the extension’s bundle/plugin `AppIcon.appiconset` unchanged.
10. **Dual Sparkle controllers** (`Marker_DataApp` + `ApplicationDelegate`) — don’t “simplify” without understanding `.updateAvailable` / `bestValidUpdate`.
11. **`OpenEventHandler`** must re-register on `.FCPShareStart`; keep registration on the main queue.
12. **Failed Tasks table** (`FailedExtractionsView`): one-line truncate + `.help()` tooltips; min frame ~640×240.
13. **Workflow Extension help vs drop:** `overlayHelpButton` is bottom-trailing. Keep Extract/Roles `TabView` `.padding(.bottom, 40)` so the drop overlay does not crowd the “?”.

---

## Definition of done (guardrail checklist)

- [ ] arm64 Debug + Release build succeeds (main app embeds Workflow Extension).
- [ ] Settings load/migrate (`preferences.json` + `Configurations/*.json`).
- [ ] Extract accepts `.fcpxml` / `.fcpxmld`, FCP pasteboard drop, and text clippings via `FCPXMLIntake`.
- [ ] Drop overlays appear on main-app Extract / Roles / Queue **and** Workflow Extension Extract + Roles with the copy above.
- [ ] Queue finds `extract_info.json` folders and uploads via `manifestURL` (relocated folders work).
- [ ] No-media / skipped swatch finishes as **“Extract done”** (not **“Analysing swatch done”**); `ColorPaletteRenderer.render` → `Bool` drives finish path.
- [ ] New alerts use `.appDialogIcon()` (`MarkerDataAppIcon` from compiled `Marker-Data.icon`).
- [ ] App icon still Icon Composer `Marker-Data.icon` for the **main app** (not inside `Assets.xcassets`; do not flatten layer PNG into `AppIconSingle`). Workflow Extension **header** uses the containing `Marker Data.app` icon; bundle/plugin icon stays `AppIcon.appiconset`.
- [ ] Settings changes include version + migration + UI + export bridge when required.
- [ ] New on-disk paths are reflected in the Uninstaller.
- [ ] `AGENT.md` / `ARCHITECTURE.md` / `GUARDRAILS.md` / `.cursorrules` updated when behavior changes.
