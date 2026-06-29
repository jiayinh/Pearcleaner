# PearBrew

PearBrew is a small macOS utility focused on two workflows:

- managing Homebrew packages, casks, taps, cleanup, doctor, and auto-update settings
- checking and updating installed apps from supported update sources

This project is an unofficial, non-commercial fork of
[alienator88/Pearcleaner](https://github.com/alienator88/Pearcleaner). It keeps
the Homebrew and app-updater parts of Pearcleaner, while removing the app-cleaner,
orphan-file search, privileged helper, Finder extension, package manager, lipo,
services, plugin, and developer-environment tools from the user-facing app.

PearBrew is not affiliated with, endorsed by, or maintained by the original
Pearcleaner author. The original Pearcleaner project and its official website
remain the upstream sources for Pearcleaner itself.

## Project Status

PearBrew is maintained as a personal-use fork. Builds from this repository are
unsigned and not notarized unless otherwise stated.

Because this fork does not use Pearcleaner's privileged helper, it is intended
for workflows that can run with normal user permissions or through Homebrew's
own command-line behavior.

## Features

- Homebrew package and cask browsing
- Homebrew install, uninstall, upgrade, cleanup, doctor, and tap management
- Homebrew auto-update controls
- App update discovery across the supported updater sources inherited from
  Pearcleaner
- Batch update controls and update logging
- Lightweight UI with the unrelated cleaner utilities hidden from the app

## Requirements

| macOS Version | Supported |
|---------------|-----------|
| 13.x Ventura  | Yes       |
| 14.x Sonoma   | Yes       |
| 15.x Sequoia  | Yes       |
| 26.x Tahoe    | Yes       |

Homebrew is required for Homebrew management features.

## Builds

The GitHub Actions workflow builds an unsigned app artifact. Unsigned builds may
show normal macOS Gatekeeper warnings. This fork intentionally avoids the
privileged helper path so it can remain useful for personal builds without a paid
Apple Developer account.

## Relationship to Pearcleaner

PearBrew is based on Pearcleaner source code and retains Pearcleaner's license
notices. The fork removes or hides the cleaner-specific features and is not a
drop-in replacement for Pearcleaner.

For a detailed modification record, see [NOTICE_MODIFICATIONS.md](NOTICE_MODIFICATIONS.md).

## License

Pearcleaner is licensed under Apache 2.0 with the Commons Clause. PearBrew is
distributed under the same license terms.

The Commons Clause prohibits selling or otherwise commercializing Pearcleaner or
modified versions of it. This fork is provided for free, personal/community use
only and must not be monetized. See [LICENSE.md](LICENSE.md) for the full license.

## Attribution

PearBrew is derived from:

- [alienator88/Pearcleaner](https://github.com/alienator88/Pearcleaner)

Thanks to the original Pearcleaner author and contributors for the Homebrew and
app-updater foundations this fork builds on.
