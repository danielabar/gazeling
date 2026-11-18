# Releasing

Gazeling uses [Semantic Versioning](https://semver.org/) and git tags named `vX.Y.Z`. Pushing a tag builds the app and publishes a GitHub Release automatically (`.github/workflows/release.yml`).

## Cut a release

The easy way: in Claude Code, on a clean, up-to-date `main`, type `/release` (`.claude/skills/release/SKILL.md`). It proposes the version, drafts the changelog section, and asks you twice: to approve the version and notes, and to merge and tag. `/release --dry-run` stops after the draft. The manual steps below do the same thing.

1. **Changelog.** In `CHANGELOG.md`, rename `## [Unreleased]` content into a new `## [X.Y.Z] - YYYY-MM-DD` section, leave an empty `## [Unreleased]` above it, and update the compare links at the bottom.
2. **Version.** Set `MARKETING_VERSION` in `project.yml` to `X.Y.Z`.
3. **Pull request.** Commit both changes on a branch, open a PR and merge it once CI is green.
4. **Tag.** On `main`, after the merge:
   ```sh
   git checkout main && git pull
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
5. **Check.** Watch the *Release* run in the Actions tab. When it finishes, open the Release page, download the zip, unzip it and open the app (see the [first-launch steps](user-guide.md#the-first-time-you-open-it)).

## What the workflow does

1. Fails if the tag does not match `MARKETING_VERSION`.
2. Runs the unit tests.
3. Runs `scripts/release-build.sh` with the build number (`CURRENT_PROJECT_VERSION`) set to the workflow run number.
4. Uses the version's section of `CHANGELOG.md` as the release notes, and adds the note on opening an unsigned app.
5. Creates the Release with `Gazeling-X.Y.Z.zip` and its SHA-256 checksum.

If the workflow fails before the Release is created, fix the problem, delete the tag (`git push origin :refs/tags/vX.Y.Z` and `git tag -d vX.Y.Z`) and tag again.

## Build a release locally

```sh
scripts/release-build.sh
```

Output is in `build/release/` (git-ignored): `Gazeling.app`, the zip and the checksum. It is a universal binary (Apple silicon and Intel), ad-hoc signed.

## Signing

Releases are ad-hoc signed, not signed with an Apple Developer ID and not notarized, so macOS blocks the first launch until the user clicks **Open Anyway**. Developer ID signing and notarization would remove that step; it needs a paid Apple Developer account and is not set up.
