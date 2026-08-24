---
name: release
description: Cut a release of Codecube and codeblock — the ordered procedure for two repositories where one is a submodule of the other, covering version bumps, regenerated metadata, verification, tagging and the ContentDB upload.
when_to_use: When releasing, tagging a version, publishing to ContentDB, or preparing a version bump. Also read it before changing anything that ships in a release, to see what will need regenerating.
disable-model-invocation: true
argument-hint: "[version]"
allowed-tools: Bash, Read, Glob, Grep
---

# Releasing

Two repositories, one nested in the other. **The order is the whole difficulty**:
`codecube` records a `codeblock` commit hash, so a hash that is not pushed yet
produces a game nobody can clone. Everything below follows from that.

Do not start until `release-check` reports ready, or you have done its checks
yourself. This skill is the procedure; that agent is the gate.

## 1. Decide the version

Semantic, and the question that decides it is **whether existing player programs
break**. Programs are data written by players and stored in worlds; the game
cannot migrate them.

Anything in this list is major:

- a name in `lib/api.lua` removed, renamed, or given different arguments
- `color()`, `round()` or similar changing what they return for the same input
- a block name changing (`wools.wool_red` → `wools.red` was one)
- a previously-allowed construct being refused
- relicensing, which breaks redistributors rather than players

v1.0.0 is major for several of these at once.

## 2. codeblock first

```bash
cd mods/codeblock
```

- `CHANGELOG.md` — add the version heading, in the existing `- [x]` style.
  **Lead with what breaks**, then additions, then fixes, then known limitations
  as `- [ ]`. Someone upgrading reads the first section and stops.
- `mod.conf` — confirm `min_minetest_version` still matches what the code needs.
  Only raise it when something actually requires it; an honest floor widens the
  audience. Do not add `max_minetest_version`: the engine ignores it and
  ContentDB uses it to hide the package.
- Regenerate the reference if anything in `lib/api.lua` changed:
  `lua scripts/gen_docs.lua`, or boot with `codeblock_gen_docs = true` and copy
  the result out of the world directory (mod security blocks writing into the mod
  directory).
- Regenerate `.cdb.json`: `bash scripts/gen_cdb_json.sh`. It embeds `README.md`,
  so any README edit needs this.
- Commit, then **push**:
  `git push origin master`
- Tag: `git tag -a v<version> -m "v<version>"` and `git push origin v<version>`.

## 3. Then codecube

```bash
cd ../..
```

- `git add mods/codeblock` — this records the hash you just pushed. Doing it
  before the push records one nobody can fetch.
- `CHANGELOG.md` — same style. Link to codeblock's changelog rather than
  repeating it; note anything that breaks *players*, since they experience the
  game, not the mod.
- `game.conf` — `min_minetest_version` honest, no `max_`.
- `bash scripts/gen_cdb_json.sh` if `README.md` changed.
- `bash scripts/check_game.sh` — must pass.
- Commit, push, tag, push the tag.

## 4. Verify a fresh clone

**Do this every time.** It is the only check that catches a submodule pointing at
an unpushed commit, and that failure is invisible from a working tree that
already has the object.

```bash
git clone --recurse-submodules git@github.com:gigaturbo/codecube.git /tmp/rel-check
cd /tmp/rel-check
git submodule status          # both populated, hashes as expected
bash scripts/check_game.sh    # passes
ls mods/codeblock/lib/        # the new work is actually present
```

A clone that fails with `reference is not a tree` means step 3 ran before step 2
finished. Push `codeblock`, then re-tag `codecube`.

## 5. ContentDB

Two packages, `codecube` (a game) and `codeblock` (a mod), each uploaded
separately at <https://content.luanti.org>.

- The long description comes from `.cdb.json`, which is generated from
  `README.md`. Regenerate before uploading or the listing goes stale.
- Screenshots are loaded from raw GitHub URLs. Check the branch in them: this
  repository is `main`, `codeblock` is `master`. GitHub currently redirects the
  old default-branch name, so a wrong branch may *look* fine — do not rely on
  that.
- Confirm the licence field matches the `LICENSE` file. Both are AGPL-3.0-only.

## 6. After

- Watch CI on both repositories; a red build on a tagged commit is worth fixing
  immediately rather than after someone downloads it.
- Ask `project-manager` to update the audit and changelogs to reflect the
  release.

## Things that have gone wrong here before

- Bumping the submodule before pushing it. Caught only by the fresh-clone check.
- `max_minetest_version` left at an old value, hiding a working game from
  everyone on a current release. The engine never enforced it, so nothing local
  ever failed.
- `.cdb.json` regenerated on a checkout whose line endings differed, producing a
  spurious diff. `check_game.sh` now compares with CRs stripped.
- A licence file written into a submodule we do not control, which was untracked
  and vanished from every fresh clone. Third-party licences live in
  `THIRD-PARTY-LICENSES.md`.
