# Modifications Notice

This repository is a personal fork of [alienator88/Pearcleaner](https://github.com/alienator88/Pearcleaner),
maintained for personal/community use only.

## License

Pearcleaner is licensed under the **Apache License 2.0 with the Commons Clause**.
This fork is distributed under the same license. In accordance with the license:

- The original LICENSE and copyright notices are retained (see LICENSE.md).
- This file documents modifications made to the original work, as required by
  Section 4(b) of the Apache License 2.0.
- **Commons Clause restriction:** This software, including any modified versions,
  may NOT be sold or otherwise commercialized. This fork is provided free of charge
  and is not monetized in any way.

This is an **unofficial build**. The only official source of Pearcleaner is
https://itsalin.com and the upstream repository. This fork is not affiliated with
or endorsed by the original author.

## Modifications made in this fork

1. Replaced the hard-coded absolute module-map path
   `/Users/alin/GitHub/PearcleanerGH` with the portable `$(SRCROOT)` build
   variable in `Pearcleaner.xcodeproj/project.pbxproj`, so the project can be
   built on any machine / CI environment.

2. Added a GitHub Actions workflow (`.github/workflows/build.yml`) that builds
   the app unsigned on a `macos-latest` runner and uploads it as an artifact.

3. (Where applicable) incorporated selected community bug-fix pull requests from
   the upstream repository. See the commit history for details and attribution.

## Note on the unsigned build

Builds produced by the CI workflow are **not code-signed or notarized**. macOS
Gatekeeper will warn that the app is from an unidentified developer. Some features
that rely on the privileged helper or hardened runtime may behave differently than
the official signed release.
