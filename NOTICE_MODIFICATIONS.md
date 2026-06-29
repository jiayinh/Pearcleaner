# Modifications Notice

This repository is an unofficial, non-commercial fork of
[alienator88/Pearcleaner](https://github.com/alienator88/Pearcleaner).

## License

Pearcleaner is licensed under the **Apache License 2.0 with the Commons Clause**.
This fork is distributed under the same license. In accordance with the license:

- the original LICENSE and copyright notices are retained in `LICENSE.md`
- this file documents modifications made to the original work
- the Commons Clause restriction remains in effect: this software, including
  modified versions, may not be sold or otherwise commercialized

This fork is provided free of charge for personal/community use only.

## Unofficial Fork Notice

PearBrew is not affiliated with, endorsed by, sponsored by, or maintained by the
original Pearcleaner author. The name PearBrew is used to distinguish this fork
from Pearcleaner.

## Modifications Made In This Fork

1. Renamed the user-facing app from Pearcleaner to PearBrew.

2. Refocused the app on Homebrew management and app update workflows.

3. Removed the app-cleaner features from the user-facing interface, including:
   app uninstall, orphaned file search, file search, app lipo, package manager,
   plugin manager, services manager, development environment cleanup, delete
   history, drag/drop uninstall, Finder-service entry points, and helper prompts.

4. Removed privileged-helper and background-cleaner behavior from app startup and
   from the final app bundle copy phases. The related source may remain in the
   repository for traceability, but it is not part of PearBrew's intended user
   experience.

5. Kept the GitHub Actions build unsigned for personal-use builds. Unsigned builds
   are not notarized and may trigger normal macOS Gatekeeper warnings.

6. Replaced the original Pearcleaner README text with PearBrew-specific
   documentation and attribution.

## Important Limitations

PearBrew is not a full app cleaner and does not include Pearcleaner's privileged
helper flow. System-level deletion and privileged cleaning workflows are outside
the scope of this fork.
