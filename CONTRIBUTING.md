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

1. Ensure package dependencies are set to version numbers and not branch names.
2. Ensure dependant binaries are update to date.
3. Perform the following file modifications:
   - Update the version number string literal in `Source/Marker Data/Marker Data.xcodeproj/project.pbxproj` under `MARKETING_VERSION`.
   - Update the build number string literal in `Source/Marker Data/Marker Data.xcodeproj/project.pbxproj` under `MARKETING_VERSION`.
   - Update root `CHANGELOG.md`
     - with a condensed bullet-point list of changes/fixes/improvements according to its established format
     - where possible, reference the Issue/PR number(s) or commit(s) where each change was made
   - Update `https://markerdata.theacharya.co/release-notes/` with identical notes from `CHANGELOG.md`.
   - Update `https://markerdata.theacharya.co/release-notes-appcast.html` with identical notes from `CHANGELOG.md`.
4. Commit the changes made in Step 3 using the new version number (ie: `1.0.0`) as the commit message, and push to main.
5. Update the version number of `Distribution/version.txt`.
6. Create [Test Build](https://github.com/TheAcharya/MarkerData/actions/workflows/test_build.yml) for internal and private (closed) beta test.
7. Make GitHub Release using [Release GitHub](https://github.com/TheAcharya/MarkerData/actions/workflows/release_github_sparkle.yml).
8. Update latest GitHub Release Notes from `CHANGELOG.md` accordingly.
