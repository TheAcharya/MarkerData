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
| **Settings** | Bump `SettingsStore.version`, add a dict migration `case`, wire UI, and pass export-related fields through `markersExtractorSettings(fcpxmlFileUrl:)`. The Workflow Extension compiles `SettingsStore` and decodes prefs **without** running migrations — main app must launch after a schema bump. |
| **Config names** | Throw `ConfigurationSaveError.nameAlreadyExists` on add / rename / duplicate collisions — never overwrite `{name}.json` silently. |
| **Alerts** | Chain `.appDialogIcon()` after every `.alert` / `.confirmationDialog` (`DialogIcon.swift` → `@MainActor` `MarkerDataAppIcon` from compiled `Marker-Data.icon`). It is environment-propagating, so an existing single trailing call already covers a whole chain — see **Signs**. AppKit `NSAlert` uses the counterpart `MarkerDataAppIcon.alertImage`; Pagemaker’s JavaScript panels are the only ones, and must be built by `PagemakerUIDelegate.makeAlert(message:)`. Uninstaller is a separate target and uses `applicationIconImage`. |
| **Extract intake** | Route Finder files, text clippings, and Final Cut Pro pasteboard drops through `FCPXMLIntake` → `ExtractionModel.receiveFiles` / `receiveItemProviders`. |
| **Drop overlays** | Use shared `DropTargetOverlay` on main-app Extract / Roles / Queue **and** Workflow Extension Extract + Roles. Shared files have **two** Compile Sources memberships in `project.pbxproj` (one file, two targets) — never delete one row. Extension membership includes overlay + `ColorExtension` + `DialogIcon.swift` + `HelpButton` / `OverlayHelpButton` plus Roles/settings files listed in **ARCHITECTURE.md**. |
| **Shared WE chrome color** | Use `Color.markerAccent` (system indigo) for overlay borders and other shared chrome hosted in FCP — not `Color.accentColor`. |
| **Queue uploads** | Upload via `QueueInstance.manifestURL` (prefer JSON beside the scanned/dropped folder; fall back to sidecar `jsonURL`). |
| **Progress phases** | Do **not** `ProgressViewModel.reset()` when entering swatch. Call `await applyTaskAppearance` **only inside** `ColorPaletteRenderer` after image checks pass (MainActor). On skip: `markProcessAsFinished` → **“Extract done”**. On render: `markAllProcessesFinished` (`ImageRenderService` replaces extract URLs with image URLs). |
| **No-media / empty swatch** | `ColorPaletteRenderer.render` returns `false` without retitling; finish the extract URL with `markProcessAsFinished` so the bar never shows **“Analysing swatch done”**. |
| **Install location** | Keep the `/Applications` warning; Workflow Extension opens `/Applications/Marker Data.app`. |
| **Uninstaller** | If the app gains new on-disk paths, update `MarkerDataUninstaller.run()` cleanup list. |
| **Architecture** | Prefer Apple Silicon (`arm64`) only; CI uses `macos-26` + **Xcode 26.6.0**. |
| **Opaque CLIs** | Treat `airlift` / `csv2notion_neo` as black boxes; only the args in `DatabaseUploader` / `DropboxSetupModel` are the contract. |
| **App icon** | Main app: Icon Composer **`Marker-Data.icon`** (name matches `ASSETCATALOG_COMPILER_APPICON_NAME`). Keep the empty main-app `AppIcon.appiconset` placeholder. Do not flatten the layer PNG into `AppIconSingle`. Workflow Extension **header** loads the icon from the containing `Marker Data.app`. Do **not** replace the Workflow Extension bundle/plugin icon (`AppIcon.appiconset`). |
| **FCPXML UTTypes** | Resolve `.fcpxml` / `.fcpxmld` with `UTType(identifier) ?? UTType(importedAs:identifier, conformingTo:)` (`.xml` / `.package`). Keep `UTImportedTypeDeclarations` and Asset Description File `LSItemContentTypes` in `Marker-Data-Info.plist`. |
| **File menu** | Custom File items replace `.newItem` (`FileCommands`) so system Close / Close All stay last. |

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
| **Shared pbxproj membership** | Never remove a second `Foo.swift in Sources` row for a file that both the main app and Workflow Extension compile. |
| **Intel** | Never add `x86_64` as a supported architecture. |
| **Silent config overwrite** | Never replace an existing configuration file because the name already exists. |
| **AppIconSingle flatten** | Never copy the Icon Composer layer PNG into `AppIconSingle` (skips glass / fill). |
| **WE header icon** | Never use the appex `AppIcon.appiconset` / `applicationIconImage` for the Workflow Extension window header — that is the bundle/plugin icon (update separately). |
| **FCPXML `UTType` unwrap** | Never force-unwrap `com.apple.finalcutpro.xml` / `.xmld`. Never split or rename the Share Destination **Asset Description File** document type. |
| **File menu Close** | Never empty `.newItem` in `Marker_DataApp` (that puts system Close first). Never add a second Close item. |

---

## Drop overlay copy (keep in sync with UI)

| Surface | Message | Icon | Notes |
|---------|---------|------|-------|
| **Extract** (main app) | Default: **“Drop to Extract Marker Metadata”**; subtitle **“Use Marker Data's Share Destination for Image Extraction”**. Hero caption under title: **“Drop a timeline from Final Cut Pro, or an .fcpxml / .fcpxmld file”** | `arrow.down.doc.fill` | Hide while `extractionInProgress`. Border: `Color.markerAccent`; arrow: `Color.heroGradient`. |
| **Extract** (Workflow Extension) | **“Drop to Open Marker Data”** | default | `WorkflowExtensionView` + `isExtractDropTargeted`; `subtitle: nil`; handoff writes Movies-cache FCPXML then opens the app. Idle hint: *“Drag & Drop Final Cut Pro Project to Open Marker Data”*. Header: `MarkerDataAppIcon.image()` 100×100 from containing `Marker Data.app`. `TabView` `.padding(.bottom, 40)` so the drop zone stays above `overlayHelpButton`. |
| **Roles** (app + Workflow Extension) | **“Drop to Retrieve Roles Metadata”** | default | `subtitle: nil`; hide while `loadingInProgress`. Idle empty-state text is separate from the overlay. |
| **Queue** | **“Drop Extract Folders (Notion or Airtable) into Queue”** | `folder.fill` | `subtitle: nil`; hide while `uploadInProgress`; drop blocked during upload. |

Shared component: `Views/Components/DropTargetOverlay.swift` (main app + Workflow Extension Compile Sources).

---

## Signs (learned pitfalls)

1. **`extract_info.json` stores absolute `jsonURL`.** After the user moves/copies an export folder, uploading the sidecar path fails (`FileNotFoundError`). Always resolve with `manifestURL`.
2. **Progress `reset()` before swatch** clears processes and can leave 0% — never reset when entering swatch. Retitle with `await applyTaskAppearance` only after `ColorPaletteRenderer` confirms images (returns `true`); then `markAllProcessesFinished` because `ImageRenderService.setProcesses` replaces FCPXML URLs with image URLs. If render returns `false`, keep **“Extract done”** via `markProcessAsFinished` (avoids **“Analysing swatch done”** with no stills).
3. **`applyTaskAppearance` is `@MainActor`.** From `ColorPaletteRenderer` (nonisolated), call `await progress.applyTaskAppearance(...)` — a bare call fails isolation.
4. **Ignore late KVO** after a process is marked finished (`ProgressViewModel.updateProgress`) or the bar can bounce backward.
5. **FCP timeline → Dock** often cannot deliver a file URL (pasteboard-only). Supported paths: drop on Extract panel, open `.fcpxml`/`.fcpxmld` via Dock/Finder Open With, Workflow Extension / Share Destination handoffs.
6. **Temporary FCP pasteboard XML** is written under `~/Movies/Marker Data Cache/` (`FCPXMLIntake.writeTemporaryFCPXML`) — Marker Data convention, not App Support Cache. Intake creates that folder; the Workflow Extension **write** of `WorkflowExtensionExport.fcpxml` does **not**.
7. **Workflow Extension accent:** `Color.accentColor` / `.accent` inside the appex often resolves to Final Cut Pro’s blue. Shared chrome (e.g. `DropTargetOverlay` border) must use `Color.markerAccent` (system indigo, matching Assets `AccentColor`).
8. **Workflow Extension Extract vs Roles:** Extract handoff lives in `WorkflowExtensionView` (`.onDrop([.fcpxml])`); Roles uses shared `RolesSettingsView` / `RolesManager` `DropDelegate`. Both show overlays — do not assume only Roles has one.
9. **Icon Composer dialogs / WE header:** SwiftUI `.alert` and `.confirmationDialog` still need `.appDialogIcon()` (`@MainActor` `MarkerDataAppIcon` from compiled `Marker-Data.icon`). Do not flatten the layer PNG into `AppIconSingle` (skips glass / fill). Workflow Extension **header** loads the icon from the containing `Marker Data.app` (`appex` → `PlugIns` → `Contents` → `.app`) — the appex’s `applicationIconImage` is its `AppIcon.appiconset` (or Final Cut Pro). Leave the extension’s bundle/plugin `AppIcon.appiconset` unchanged.
10. **Dual Sparkle controllers** (`Marker_DataApp` + `ApplicationDelegate`) — don’t “simplify” without understanding `.updateAvailable` / `bestValidUpdate`.
11. **`OpenEventHandler`** must re-register on `.FCPShareStart`; keep registration on the main queue. `setupHandler()` also runs from `init` and `Marker_DataApp` `.task`.
12. **Failed Tasks table** (`FailedExtractionsView`): one-line truncate + `.help()` tooltips; min frame ~640×240.
13. **Workflow Extension help vs drop:** `overlayHelpButton` is bottom-trailing. Keep Extract/Roles `TabView` `.padding(.bottom, 40)` so the drop overlay does not crowd the “?”.
14. **Shared Compile Sources look duplicated in `pbxproj`.** One `DialogIcon.swift` (and other shared files, including `WorkflowExtensionView.swift`) correctly appears twice as `PBXBuildFile` — main app + Workflow Extension. Deleting one membership breaks the extension (or, for `WorkflowExtensionView`, still violates the two-row contract — leave the unused main-app row). `WorkflowExtensionViewController.swift` is the only appex-only Swift file.
15. **Workflow Extension does not migrate settings.** `RolesManager` JSON-decodes `SettingsStore` with no `SettingsVersioningManager`. Open the main app after a schema bump.
16. **FCPXML `UTType` force-unwrap** — `UTType("com.apple.finalcutpro.xml")!` traps on Extract first layout when Final Cut Pro is absent (App Preview / review Macs). Use `importedAs` fallback and Info.plist imported types. Do not copy the old Marker Data force-unwrap.
17. **File menu Close last:** custom File items replace `.newItem`. Emptying `.newItem` makes system Close the first File item; do not duplicate Close.
18. **`Task { try await MainActor.run { … } }` inside a `throws` method swallows the error.** The task result is discarded, so the method always returns normally and the caller’s `catch` is dead. `DatabaseManager` is already `@MainActor` — call directly and let the error propagate. `duplicateProfile` was fixed this way; `setActiveProfile` and `loadProfilesFromDisk` still use the wrapper but throw nothing, so they are harmless. Do not reintroduce the pattern for anything that validates.
19. **Record an extract failure once.** `extractAndUpdateProgress` must rethrow the `MarkersExtractor` error, not append to `failedTasks` — appending there and then tripping the `exportResultisNil` guard produced two entries for one file, the second reading “Failed to get export result”, and duplicate `ExtractionFailure.id` (the URL) in `FailedExtractionsView`. The task group `catch` is the single recording point.
20. **`NSAlert` does not pick up the Icon Composer icon**, and its `alertStyle` defaults to `.warning`. Pagemaker’s WebView JavaScript panels are the app’s only `NSAlert`s — route them through `PagemakerUIDelegate.makeAlert(message:)` (sets `MarkerDataAppIcon.alertImage`, `.informational`, message as `messageText`). Never re-add generic “Alert” / “Confirm” / “Prompt” titles; SwiftUI dialogs elsewhere have no such title. Keep `confirm` returning `.alertFirstButtonReturn` so Cancel reaches JavaScript as `false`.
21. **`Color ==` is tolerant, app-wide, and not transitive.** `ColorExtension.swift` defines `static func == (Color, Color)` delegating to `isEqual(to:tolerance: 0.1)`; Swift prefers the same-module declaration, so this shadows SwiftUI's exact `==` for **every** `Color` comparison compiled into the main app — including synthesized `Equatable` on `SettingsStore` (verified). Consequences: a colour tweak under ~25/255 in all three channels leaves `SettingsContainer.checkForUnsavedChanges()` false, so the Configurations “Changed” badge and ⌘S / ⌘Z stay disabled even though `preferences.json` was already updated; and `0.0 == 0.1`, `0.1 == 0.2`, `0.0 != 0.2` breaks `Equatable` transitivity, so never put `Color` (or `SettingsStore`) in a `Set`, use it as a dictionary key, or dedupe an array of them. The tolerance exists because `Color.hex` **truncates** (`Int(components.red * 255.0)`): 179 of 256 sampled colours drift one step through encode/decode, which under exact equality would mark the store permanently dirty. Fix properly by rounding in `hex` and comparing `lhs.hex == rhs.hex` — measured zero round-trip failures — not by lowering the tolerance alone. Note `hex` also feeds `imageLabelFontColor` / `imageLabelFontStrokeColor`, so the drift reaches rendered labels.
22. **Pagemaker’s `confirm` panel is unreachable in-app — do not “verify” it by clicking.** The only `confirm(` in bundled `Resources/Pagemaker.html` is gated behind `isMacOSSafari()`, and WKWebView’s default user agent carries no `Safari` token, so the branch never runs inside Marker Data. `webView(_:runJavaScriptConfirmPanelWithMessage:…)` must still return `.alertFirstButtonReturn` correctly (Sign 20), but that contract cannot be exercised from the UI — reason about it, don’t test-and-conclude. Two things would make it live: setting `applicationNameForUserAgent` to include `Safari`, or an upstream Pagemaker change, since `update_pagemaker.yml` refreshes that HTML outside this repo’s review.
23. **`.appDialogIcon()` propagates through the environment.** It wraps SwiftUI `.dialogIcon(_:)`, so one trailing call covers every `.alert` / `.confirmationDialog` earlier in the same modifier chain. `ConfigurationSettingsView` has four dialogs and **one** call — that is correct, not a missing icon; `DatabaseSettingsView`’s three calls are redundant but harmless. Only a dialog-bearing chain with **no** call anywhere is broken. Keep adding one per dialog in new code (safe habit), but do not “fix” an existing single trailing call.

---

## Definition of done (guardrail checklist)

- [ ] Unsigned arm64 Debug + Release build succeeds (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`; main app embeds Workflow Extension).
- [ ] Settings load/migrate (`preferences.json` + `Configurations/*.json`).
- [ ] Extract accepts `.fcpxml` / `.fcpxmld`, FCP pasteboard drop, and text clippings via `FCPXMLIntake`.
- [ ] FCPXML `UTType`s still use `importedAs` fallback (no `!` on `com.apple.finalcutpro.xml` / `.xmld`); Info.plist still has `UTImportedTypeDeclarations`; Share Destination **Asset Description File** type is unchanged.
- [ ] File menu still replaces `.newItem` with app actions; system Close stays last (no second Close; do not empty `.newItem`).
- [ ] Drop overlays appear on main-app Extract / Roles / Queue **and** Workflow Extension Extract + Roles with the copy above.
- [ ] Queue finds `extract_info.json` folders and uploads via `manifestURL` (relocated folders work).
- [ ] No-media / skipped swatch finishes as **“Extract done”** (not **“Analysing swatch done”**); `ColorPaletteRenderer.render` → `Bool` drives finish path.
- [ ] New alerts **and** confirmation dialogs use `.appDialogIcon()` (`MarkerDataAppIcon` from compiled `Marker-Data.icon`); any `NSAlert` uses `MarkerDataAppIcon.alertImage` via `PagemakerUIDelegate.makeAlert(message:)`.
- [ ] App icon still Icon Composer `Marker-Data.icon` for the **main app** (not inside `Assets.xcassets`; do not flatten layer PNG into `AppIconSingle`). Workflow Extension **header** uses the containing `Marker Data.app` icon; bundle/plugin icon stays `AppIcon.appiconset`.
- [ ] Settings changes include version + migration + UI + export bridge when required.
- [ ] New on-disk paths are reflected in the Uninstaller.
- [ ] `AGENT.md` / `ARCHITECTURE.md` / `GUARDRAILS.md` / `.cursorrules` updated when behavior changes.
