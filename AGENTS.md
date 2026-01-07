# CodexSkillManager

## What this app is
CodexSkillManager is a small macOS SwiftUI app built with SwiftPM (no Xcode project) that lists the Codex skills installed in the user's public skills folder.

## How it works
- The app scans `~/.codex/skills/public` for subdirectories.
- Each directory name becomes a skill entry.
- The UI is a SwiftUI `NavigationSplitView` with a list on the left and a detail view on the right.
- The detail view shows the skill name and its full path.

## Build and run
- Build: `swift build`
- Run: `swift run CodexSkillManager`
When editing this app, build after each change and fix any compile errors before continuing.

## Packaging and release
Use the `macos-spm-app-packaging` skill for packaging, notarization, appcast, and GitHub release steps.
Local packaging helpers live in `Scripts/`:
- `Scripts/compile_and_run.sh`: package (adhoc sign) + launch the `.app`.
- `Scripts/package_app.sh`: build and create `CodexSkillManager.app`.
- `Scripts/sign-and-notarize.sh`: sign + notarize for releases.
- `Scripts/make_appcast.sh`: generate Sparkle appcast from a zip.

## Project layout
- `Package.swift`: SwiftPM manifest for the executable target.
- `Sources/CodexSkillManager/App/CodexSkillManagerApp.swift`: App entry point + dependency injection.
- `Sources/CodexSkillManager/Skills/SkillStore.swift`: Loads skills + selected SKILL.md content.
- `Sources/CodexSkillManager/Skills/SkillSplitView.swift`: Split view shell with list + detail.
- `Sources/CodexSkillManager/Skills/SkillDetailView.swift`: Markdown rendering for SKILL.md content.
- `version.env`: Template version file (used by the packaging scripts if added later).
