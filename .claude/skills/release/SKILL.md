---
name: release
description: Cut a new Gazeling release. Picks the next semantic version from what changed, writes the changelog section, opens and merges the release PR, tags, pushes the tag and watches the release workflow. Use only when the owner types /release. Pass --dry-run to stop after the draft.
disable-model-invocation: true
argument-hint: "[--dry-run]"
---

# /release

Publish a new version of Gazeling. The manual steps are in `docs/releasing.md`; this skill does them. The pushed tag starts `.github/workflows/release.yml`, which builds the zip and creates the GitHub Release from the `CHANGELOG.md` section for that version.

Use `--dry-run` to do steps 1 to 5 only and change nothing.

## Rules

- **Two approvals, always asked fresh in this run:** (A) the version and notes, (B) merge the PR and push the tag. Earlier "go ahead" messages do not count. Merging and pushing a tag are public and hard to undo.
- Never move or reuse a tag. If a tag run fails, follow "If the workflow fails" in `docs/releasing.md`, and ask first.
- Stop and report on any unexpected state. Do not repair it silently.
- Release notes live only in `CHANGELOG.md`. The workflow copies the section into the GitHub Release.
- Do not set `CURRENT_PROJECT_VERSION`; the workflow sets it from the run number.
- Keep eye-health claims modest (see `CLAUDE.md`). Write notes for users, not as commit messages.
- Use no personal details (name, email) in the notes.

## Steps

### 1. Preflight

Run and check; stop with a clear message if any fails:

- `git branch --show-current` is `main`.
- `git status --porcelain` is empty.
- `git fetch --tags origin`, then `git rev-parse HEAD` equals `git rev-parse origin/main`.
- `gh auth status` works.
- CI on `main` is green: `gh run list --branch main --workflow CI --limit 1 --json conclusion,status`.

`main` only accepts squash-merged PRs with the `test-and-build` check passing, so the release change must go through a PR (steps 6 to 9).

### 2. Find what changed

- Last tag: `git describe --tags --abbrev=0 --match 'v*'`.
- Commits since: `git log <tag>..HEAD --pretty='%s'`. Each squash-merged PR is one commit, titled with its PR number.
- For detail, read the PRs: `gh pr view <n> --json title,body`.
- Read the lines already under `## [Unreleased]` in `CHANGELOG.md`.
- Ignore changes users cannot notice (docs, CI, refactors, tests) except to mention a notable one in "Changed" if it affects building from source.

If nothing user-visible changed since the last tag, say so and stop.

### 3. Propose the version

Current version: `MARKETING_VERSION` in `project.yml` (equals the last tag without `v`; if not, stop and report).

- Breaking change (settings reset, minimum macOS raised, removed feature): major.
- New user-visible feature: minor.
- Fixes only: patch.

While the major version is 0, show the reasoning and ask; do not decide alone.

### 4. Draft the changelog section

Keep a Changelog groups: Added, Changed, Fixed, Removed. Start from the `[Unreleased]` lines, fill gaps from the PRs. One line per change, plain English, no PR numbers. Date is today's date, `YYYY-MM-DD`.

### 5. Approval A

Show: the proposed version, why, the drafted section, and the list of PRs it covers. Ask the owner to approve or edit. With `--dry-run`, print this and stop.

### 6. Prepare the release PR

- `git checkout -b release-X.Y.Z`
- `CHANGELOG.md`: leave an empty `## [Unreleased]`, put the approved text under `## [X.Y.Z] - DATE`, set the links at the bottom:
  - `[Unreleased]: https://github.com/danielabar/gazeling/compare/vX.Y.Z...HEAD`
  - `[X.Y.Z]: https://github.com/danielabar/gazeling/compare/vPREV...vX.Y.Z`
- `project.yml`: set `MARKETING_VERSION: "X.Y.Z"`.
- Commit `Release X.Y.Z` (with the commit attribution line the session gives), `git push -u origin release-X.Y.Z`, `gh pr create` with the notes in the body.

### 7. Wait for CI

`gh pr checks <n> --watch`. If it fails, stop and report; do not merge.

### 8. Approval B

Ask: "Merge PR #n and push tag vX.Y.Z?" Wait for a yes.

### 9. Merge, tag, push

```sh
gh pr merge <n> --squash --delete-branch
git checkout main && git pull
git tag vX.Y.Z
git push origin vX.Y.Z
```

The tag must point at the merge commit: check `git rev-parse HEAD` equals `origin/main` before tagging.

### 10. Watch and report

- `gh run watch` on the Release run for the tag (find it with `gh run list --workflow Release --limit 1`).
- `gh release view vX.Y.Z` to confirm the zip and `.sha256` are attached and the notes are right.
- Give the owner the Release page link, and remind them to download the zip in a browser, open it and check the first-launch steps.
