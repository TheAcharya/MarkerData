# GUARDRAILS.md

Hard constraints for humans and AI agents working in **Marker Data**.  
Read with **`AGENT.md`** (how to change things), **`ARCHITECTURE.md`** (how it works), and **`.cursorrules`** (Cursor enforcement). Keep all four consistent when behavior or architecture changes.

---

## Always

| Area | Rule |
|------|------|
| **Settings** | Bump `SettingsStore.version`, add a dict migration `case`, wire UI, and pass export-related fields through `markersExtractorSettings(fcpxmlFileUrl:)`. |
| **Config names** | Throw `ConfigurationSaveError.nameAlreadyExists` on add / rename / duplicate collisions — never overwrite `{name}.json` silently. |
| **Alerts** | Chain `.appDialogIcon()` after every `.alert` / confirmation dialog (`DialogIcon.swift` → PNG `AppIconSingle`). |
| **Extract intake** | Route Finder files, text clippings, and Final Cut Pro pasteboard drops through `FCPXMLIntake` → `ExtractionModel.receiveFiles` / `receiveItemProviders`. |
| **Drop overlays** | Use shared `DropTargetOverlay` on Extract, Roles, and Queue; keep Workflow Extension compiling `DropTargetOverlay` + `RolesSettingsView` + `ColorExtension`. |
| **Queue uploads** | Upload via `QueueInstance.manifestURL` (prefer JSON beside the scanned/dropped folder; fall back to sidecar `jsonURL`). |
| **Progress phases** | Between extract → swatch, call `ProgressViewModel.applyTaskAppearance` — do **not** `reset()` (wipes processes and can leave the bar at 0% when there are no stills). |
| **No-media / empty swatch** | Early-return when there are no images; finish with `markAllProcessesFinished()` so the bar reaches 100%. |
| **Install location** | Keep the `/Applications` warning; Workflow Extension opens `/Applications/Marker Data.app`. |
| **Uninstaller** | If the app gains new on-disk paths, update `MarkerDataUninstaller.run()` cleanup list. |
| **Architecture** | Prefer Apple Silicon (`arm64`) only; CI uses `macos-26` + **Xcode 26.6.0**. |
| **Opaque CLIs** | Treat `airlift` / `csv2notion_neo` as black boxes; only the args in `DatabaseUploader` / `DropboxSetupModel` are the contract. |

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
| **`plaform`** | Never “fix” the spelling on database models unless intentionally migrating. |
| **Intel** | Never add `x86_64` as a supported architecture. |
| **Silent config overwrite** | Never replace an existing configuration file because the name already exists. |

---

## Drop overlay copy (keep in sync with UI)

| Surface | Message | Icon | Notes |
|---------|---------|------|-------|
| **Extract** | Default: **“Drop to Extract Marker Metadata”**; subtitle **“Use Marker Data's Share Destination for Image Extraction”**. Hero caption under title: **“Drop a timeline from Final Cut Pro, or an .fcpxml / .fcpxmld file”** | `arrow.down.doc.fill` | Hide while `extractionInProgress`. Border: `Color.markerAccent` (explicit indigo — not `accentColor`, which becomes host blue in FCP); arrow: `Color.heroGradient`. |
| **Roles** (app + Workflow Extension) | **“Drop to Retrieve Roles Metadata”** | default | `subtitle: nil`; hide while `loadingInProgress`. |
| **Queue** | **“Drop Extract Folders (Notion or Airtable) into Queue”** | `folder.fill` | `subtitle: nil`; hide while `uploadInProgress`; drop blocked during upload. |

Shared component: `Views/Components/DropTargetOverlay.swift`.

---

## Signs (learned pitfalls)

1. **`extract_info.json` stores absolute `jsonURL`.** After the user moves/copies an export folder, uploading the sidecar path fails (`FileNotFoundError`). Always resolve with `manifestURL`.
2. **Progress `reset()` before swatch** clears processes and can leave 0% when Skip Image Generation / empty image sets skip render — use `applyTaskAppearance` + `markAllProcessesFinished`.
3. **Ignore late KVO** after a process is marked finished (`ProgressViewModel.updateProgress`) or the bar can bounce backward.
4. **FCP timeline → Dock** often cannot deliver a file URL (pasteboard-only). Supported paths: drop on Extract panel, open `.fcpxml`/`.fcpxmld` via Dock/Finder Open With, Workflow Extension / Share Destination handoffs.
5. **Temporary FCP pasteboard XML** is written under `~/Movies/Marker Data Cache/` (`FCPXMLIntake.writeTemporaryFCPXML`) — Marker Data convention, not App Support Cache.
6. **Workflow Extension accent:** `Color.accentColor` / `.accent` inside the appex often resolves to Final Cut Pro’s blue. Shared chrome (e.g. `DropTargetOverlay` border) must use `Color.markerAccent` (system indigo, matching Assets `AccentColor`). Extension Compile Sources must still include `DropTargetOverlay` + `ColorExtension`.
7. **Icon Composer** Dock asset (`Marker-Data.icon`) often yields a blank `.alert` glyph — PNG via `.appDialogIcon()` is mandatory.
8. **Dual Sparkle controllers** (`Marker_DataApp` + `ApplicationDelegate`) — don’t “simplify” without understanding `.updateAvailable` / `bestValidUpdate`.
9. **`OpenEventHandler`** must re-register on `.FCPShareStart`; keep registration on the main queue.
10. **Failed Tasks table** (`FailedExtractionsView`): one-line truncate + `.help()` tooltips; min frame ~640×240.

---

## Definition of done (guardrail checklist)

- [ ] arm64 Debug + Release build succeeds (main app embeds Workflow Extension).
- [ ] Settings load/migrate (`preferences.json` + `Configurations/*.json`).
- [ ] Extract accepts `.fcpxml` / `.fcpxmld`, FCP pasteboard drop, and text clippings via `FCPXMLIntake`.
- [ ] Drop overlays appear on Extract / Roles / Queue with the copy above.
- [ ] Queue finds `extract_info.json` folders and uploads via `manifestURL` (relocated folders work).
- [ ] New alerts use `.appDialogIcon()`.
- [ ] Settings changes include version + migration + UI + export bridge when required.
- [ ] New on-disk paths are reflected in the Uninstaller.
- [ ] `AGENT.md` / `ARCHITECTURE.md` / `GUARDRAILS.md` / `.cursorrules` updated when behavior changes.
