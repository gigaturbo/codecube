---
name: release-codecube
description: Cut a release of the Codecube game — adopt a chosen CodeBlock release, move the submodule pointer, update the game's documentation and record with it, regenerate .cdb.json from CONTENTDB.md, run check_game.sh, tag on main, upload to ContentDB. The game releases on its own cadence, independently of the mod.
when_to_use: When releasing, tagging or publishing the Codecube game, or when adopting a new CodeBlock release into it. Also read it before changing anything that ships in a game release.
disable-model-invocation: true
argument-hint: "[version]"
allowed-tools: Bash, Read, Glob, Grep
---

# Releasing Codecube

The game bundles the CodeBlock mod as a submodule. **The pointer names an
adopted release, not the tip of `master`** — moving it is the first step of a
game release and a decision in its own right, not routine maintenance.

Do not start until `release-check` reports ready, or you have done its checks
yourself. This skill is the procedure; that agent is the gate.

`mods/codeblock` is a *pinned dependency*, not a working copy. The mod is
developed in its own sibling checkout; the only thing done to it from here is
`git checkout <tag>` at step 2. Never commit to it from this tree.

## 1. Choose the CodeBlock release to adopt

- Read `mods/codeblock/CHANGELOG.md` from the currently adopted version to the
  candidate. **What breaks for players decides the game's version number**, even
  if nothing in this repository changed: saved programs are data the game cannot
  migrate.
- The candidate must be a tag, and its CI must be green on the tagged commit.
  Adopting an untagged `master` commit puts players on something that was never
  released.
- Adopting nothing new is a legitimate outcome. A game release may ship the
  CodeBlock version it already had.

## 2. Move the pointer

```bash
cd mods/codeblock
git fetch origin --tags
git checkout v<mod-version>      # a tag, not a branch
cd ../..
git add mods/codeblock
```

The push-before-you-bump hazard applies here and only here: the tag must exist
on the remote before this repository records it. Bumping first records a hash
nobody can fetch, which is invisible from a working tree that already has the
object and shows up only as `reference is not a tree` in a fresh recursive
clone.

## 3. Update the game's documentation, in the same commit

Adoption and documentation move together — that is the whole point of adopting
releases rather than following commits.

- `CHANGELOG.md` — add the version heading in the existing `- [x]` style.
  **Lead with what breaks**, then additions, then fixes, then known limitations
  as `- [ ]`. Name the CodeBlock version adopted and link to its changelog
  rather than repeating it; describe anything that breaks *players*, since they
  experience the game, not the mod.
- `README.md` — it presents the game, its features, its settings and how to
  play, and redirects to the CodeBlock package or repo for the API and the
  detailed instructions. If a mod change makes anything on this page wrong, fix
  it now.
- `CONTENTDB.md` — the ContentDB long description, and **deliberately not the
  README** (C20). Its rules are in the header of `scripts/gen_cdb_json.sh`: no
  title heading, no badges, no screenshots, no licence line, no link to the
  repository or to the package's own page, and no instruction that leans on an
  image, because images are not visible inside Luanti. If a mod change makes a
  feature description here wrong, fix it now.
- `bash scripts/gen_cdb_json.sh` **if `CONTENTDB.md` changed.** `.cdb.json`
  embeds that file and `check_game.sh` diffs it; a stale one fails CI. A
  `README.md` edit no longer affects it.
- `ROADMAP.md`, `TODO.md`, `AUDIT.md` and `PLAYTEST.md` **at the game root** —
  strike what this release closed, or ask `project-manager` to. The reasoning is
  in `AUDIT.md`; the order of work and the `G1`–`G5` milestones are in
  `ROADMAP.md`. The mod keeps its own record in its own repository and it is
  never edited from here.
- `PLAYTEST.md` — read the `Result:` lines and note what this release has
  actually been observed to do. The game has no test suite, so a release with
  every check `unchecked` ships behaviour nobody has watched; that is the
  author's call to make, not a gate, but it belongs in the release notes to
  yourself rather than being discovered later.
- `.gitattributes` — confirm nothing added since the last release will ship in
  the archive. Nothing in CI checks it, and hidden directories are excluded only
  because a rule says so.
- `game.conf` — `min_minetest_version` honest, no `max_minetest_version`.

## 4. Verify, then tag

`test-agent` owns both gates and the `run-checks` skill describes what each one
does and does not guarantee. Either call it or run them here:

```bash
bash scripts/check_game.sh    # must pass, and leave the tree clean
wsl bash -lc 'cd /mnt/c/Users/lacba/PRogrammation/codecube && luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes'
```

Read the output, not the exit code. Neither gate runs a line of the game's Lua,
so passing them is not evidence that the release behaves — that is what step 3's
`PLAYTEST.md` reading is for.

Then commit, `git push origin main`, `git tag -a v<version> -m "v<version>"`,
`git push origin v<version>`.

## 5. Verify a fresh recursive clone

**Do this every time.** It is the only check that catches a submodule pointing at
a commit the remote does not have.

```bash
git clone --recurse-submodules git@github.com:gigaturbo/codecube.git /tmp/rel-check
cd /tmp/rel-check
git submodule status          # both populated, at the adopted release
bash scripts/check_game.sh    # passes
ls mods/codeblock/lib/        # the adopted work is actually present
```

`reference is not a tree` means the pointer was recorded before the mod tag was
pushed. Push the tag in `codeblock`, then re-tag here.

## 6. ContentDB

The `codecube` package (a game) at <https://content.luanti.org>. `codeblock` is
a separate package with its own upload — see `release-codeblock`; do not upload
both from here out of habit.

- The long description comes from `.cdb.json`, generated from `CONTENTDB.md`.
  Regenerate before uploading or the listing goes stale.
- **Read the page from inside Luanti**, in the content browser, not only in a web
  browser. That is the reader ContentDB's image rule exists for and the one a web
  preview does not show you. `PLAYTEST.md` `P5`.
- Screenshots load from raw GitHub URLs. Check the branch: this repository is
  `main`, `codeblock` is `master`. GitHub currently redirects the old
  default-branch name, so a wrong branch may *look* fine — do not rely on that.
- Confirm the licence field matches the `LICENSE` file: AGPL-3.0-only.

ContentDB's own page guidance is <https://content.luanti.org/help/appealing_page/>
and the index of the rest is <https://content.luanti.org/help/>. The short
version is in the header of `scripts/gen_cdb_json.sh`, which is the file to read
before writing `CONTENTDB.md`.

### The release webhook

<https://content.luanti.org/help/release_webhooks/>. Optional; it replaces the
manual upload with a push from the repository.

- An API token from *Profile → API Tokens → Manage* on ContentDB is the webhook
  **secret**. Payload URL `https://content.luanti.org/github/webhook/`, content
  type JSON, under the repository's *Settings → Webhooks*.
- **Select "Branch or tag creation", not push events.** This game tags — step 4
  above — so a tag is the release. Push events are for a rolling project and
  would publish every commit on `main`.
- A push-triggered webhook watches the default branch only; a tag-triggered one
  works on any branch. Where several ContentDB packages match one repository,
  **only the first gets the release**.
- Once it exists, step 5 gains a check: after pushing the tag, confirm the
  release actually appeared. A webhook that has silently stopped looks exactly
  like one nobody configured.

## 7. After

- Watch this repository's CI on the tagged commit. It runs `check_game.sh` and
  luacheck on `cc_day`, `cc_mapgen` and `cc_security` only — it never lints or
  tests the mod, so a green run here says nothing about CodeBlock.
- Ask `project-manager` to update this game's audit, changelog and roadmap. A
  game release does not change the mod's record.

## Things that have gone wrong here before

- Bumping the submodule before pushing what it points at. Caught only by the
  fresh-clone check.
- `max_minetest_version` left at an old value, hiding a working game from
  everyone on a current release. The engine never enforced it, so nothing local
  ever failed. `check_game.sh` now fails on it.
- `.cdb.json` regenerated on a checkout whose line endings differed, producing a
  spurious diff. `check_game.sh` now compares with CRs stripped.
- A licence file written into a submodule we do not control, which was untracked
  and vanished from every fresh clone. Third-party licences live in
  `THIRD-PARTY-LICENSES.md`.
- The ContentDB long description was `README.md` verbatim for the project's whole
  life, breaking six of ContentDB's own page rules at once — including five tool
  icons used *inline in the instructions*, which the in-game content browser does
  not render at all. `CONTENTDB.md` is now the source (C20).
