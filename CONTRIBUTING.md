# Contributing to Marker Data

This file contains general guidelines but is subject to change and evolve over time.

## Code Contributions

Before contributing, it is encouraged to post an Issue to discuss a bug or new feature prior to implementing it. Once implemented on your fork, Pull Requests are welcome for features that benefit the core functionality of the application.

Code Owners & Maintainers reserve the right to revise or reject contributions if they are not deemed fit.

### Languages

We kindly request that all pull requests be submitted in English. Pull requests submitted in other languages will unfortunately have to be declined.

### Code Formatting

Code formatting is not strictly enforced but is a courtesy we would like contributors to employ.

[SwiftFormat](https://github.com/nicklockwood/SwiftFormat) is used to format `*.swift` files.

```bash
cd <path to repo root>
swiftformat .
```

## Releases
Publishing releases and tags should be left to Code Owners & Maintainers.

For Code Owners & Maintainers, the following release specification is used:

### Pre-Release Verification
1. Check GitHub macOS Action Runner Version at https://github.com/actions/runner-images and verify compatibility with the macOS requirements.
2. Test Marker Data's build with the latest GitHub macOS Action Runner Version to ensure compatibility.
3. Ensure package dependencies are set to version numbers and not branch names.
4. Ensure dependent binaries are up to date.

### Release Process
5. Perform the following file modifications:
   - Update the version number string literal in `Source/Marker Data/Marker Data.xcodeproj/project.pbxproj` under `MARKETING_VERSION` (4 occurrences).
   - Update the build number string literal in `Source/Marker Data/Marker Data.xcodeproj/project.pbxproj` under `CURRENT_PROJECT_VERSION` (4 occurrences).
   - Update root `CHANGELOG.md`:
     - with a condensed bullet-point list of changes/fixes/improvements according to its established format
     - where possible, reference the Issue/PR number(s) or commit(s) where each change was made
   - Update `Distribution/version.txt` with the new version number.
   - Update `SECURITY.md` if security-related changes are included in the release.
   - Update `https://markerdata.theacharya.co/release-notes/` with identical notes from `CHANGELOG.md`.
   - Update `https://markerdata.theacharya.co/release-notes-appcast.html` with identical notes from `CHANGELOG.md`.

6. Commit the changes made in Step 5 using the new version number (ie: `1.0.0`) as the commit message, and push to main.

### Testing & Validation
7. Create [Test Build](https://github.com/TheAcharya/MarkerData/actions/workflows/test_build.yml) for internal and private (closed) beta testing.
8. Verify that all features are working correctly and that fixes have been properly addressed.
9. Update or add any pages in the documentation site at https://markerdata.theacharya.co if needed.

### Final Release
10. Make GitHub Release using [Release GitHub](https://github.com/TheAcharya/MarkerData/actions/workflows/release_github_sparkle.yml).
11. Update the draft release to public release with the latest release notes from `CHANGELOG.md`.

### Post-Release Verification
12. Verify that all version and build numbering is consistent across all files.
13. Confirm that release notes are accurately reflected in all documentation locations.

## FAQ

### Why do we use the `.app` from Derived Data instead of Archive?

We distribute the Release build `.app` directly from **Xcode's Derived Data** rather than using `Archive`, because it improves debug visibility, ensures consistency, and simplifies our workflow—particularly valuable in an open-source setting.

#### 1. Consistent Development and Distribution Builds
- We ship the same `.app` used during development.
- Avoids discrepancies between development and release versions.
- Prevents "it worked in dev but broke in production" issues.

#### 2. Built-In Debuggability
- Crash logs from users (e.g. via Console.app) are automatically symbolicated—no `.dSYM` needed.
- Full debug symbols are preserved in the `.app` bundle.
- You can match crash logs directly to specific commits in the repo.

#### 3. Faster and Simpler CI/CD
- No need for a separate `Archive` step in GitHub Actions or CI tools.
- Fewer steps = faster builds and less room for breakage.
- Simplifies automated workflows significantly.

#### 4. Open-Source Friendly
- Contributors can reproduce the exact same `.app` locally.
- Transparency helps others trace, debug, and report issues effectively.
- Ideal for fast iteration cycles in collaborative projects.

### Doesn’t Archive Produce Smaller or More Optimised Builds?

Yes — Archive strips debug info, resulting in smaller binaries. However:

- Our final DMG is already **under 50MB**.
- The slight size gain isn’t worth sacrificing debug convenience.
- We prioritise **debuggability and reproducibility** over minimal file size.

### **Does this affect notarisation?**

No. Apple’s notarisation works identically for Derived Data and Archive builds.

### Summary

For open-source Mac apps distributed via DMG, using the Derived Data `.app` gives us faster builds, better crash analysis, and full reproducibility—making it a better fit than Archive in our case.
