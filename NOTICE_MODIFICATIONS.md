# Modifications Notice

This repository is an unofficial, non-commercial fork of [alienator88/Pearcleaner](https://github.com/alienator88/Pearcleaner).

## License

Pearcleaner is licensed under the Apache License 2.0 with the Commons Clause. This fork is distributed under the same license. In accordance with the license:

- the original LICENSE and copyright notices are retained in `LICENSE.md`
- - this file documents modifications made to the original work
  - - the Commons Clause restriction remains in effect: this software, including modified versions, may not be sold or otherwise commercialized
   
    - This fork is provided free of charge for personal/community use only.
   
    - ## Unofficial Fork Notice
   
    - PearBrew is not affiliated with, endorsed by, sponsored by, or maintained by the original Pearcleaner author. The name PearBrew is used to distinguish this fork from Pearcleaner.
   
    - ## Modifications Made In This Fork
   
    - ### Interface & Scope Refocus (initial refocus)
    - - Renamed the user-facing app from Pearcleaner to PearBrew.
      - - Refocused the app on Homebrew management and app update workflows.
        - - Removed the app-cleaner features from the user-facing interface, including: app uninstall, orphaned file search, file search, app lipo, package manager, plugin manager, services manager, development environment cleanup, delete history, drag/drop uninstall, Finder-service entry points, and helper prompts.
          - - Removed privileged-helper and background-cleaner behavior from app startup and from the final app bundle copy phases. The related source may remain in the repository for traceability, but it is not part of PearBrew's intended user experience.
            - - Kept the GitHub Actions build unsigned for personal-use builds. Unsigned builds are not notarized and may trigger normal macOS Gatekeeper warnings.
              - - Replaced the original Pearcleaner README text with PearBrew-specific documentation and attribution.
               
                - ### Source Code Cleanup (subsequent slimming)
                - - Refactored `AppState.swift`: removed all App Cleaner state (`AppInfo`, `ZombieFile`, `sortedApps`, volume info, sensitivity levels, etc.) and retained only `currentPage` and hidden-pages management needed by Homebrew/Updater. Removed `FinderSync` dependency. (835 → 43 lines)
                  - - Refactored `Logic.swift`: removed all App Cleaner scan logic (`loadApps`, `getSortedApps`, `AppPathFinder`, etc.) and retained only the `sortKey` String extension used by `HomebrewManager` for CJK-aware sorting. (1476 → 31 lines)
                    - - Refactored `AppCommands.swift`: removed debug menu items (Debug Console, Export Debug Info, Export Updater Debug Log) and the `UpdaterDebugLogger` dependency; retained only Homebrew/Updater navigation, refresh, settings, and GitHub link commands. (178 → 124 lines)
                      - - Cleaned `HomebrewController.swift`: removed leftover TEMPORARY test comment (`// Fake Sequoia for testing`) and the outdated `//MARK: THIS WILL NEED TO BE UDPATED` maintenance note from `getCurrentOSCodename()`.
                       
                        - ## Important Limitations
                       
                        - PearBrew is not a full app cleaner and does not include Pearcleaner's privileged helper flow. System-level deletion and privileged cleaning workflows are outside the scope of this fork.
