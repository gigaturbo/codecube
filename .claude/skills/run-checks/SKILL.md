---
name: run-checks
description: Run the Codecube game's gates and read them honestly — scripts/check_game.sh, luacheck on the game's own three mods, the .cdb.json freshness diff, and CI on the exact commit. The game has no test suite, so these prove that it assembles and never that it behaves; the only route to behaviour is PLAYTEST.md, run by the author in a world. Covers what each gate does and does not guarantee, how to read the output, and how to turn a playtest into a result line.
when_to_use: After changing anything in this repository, before committing, before a release, when asked to run or verify the checks, when checking whether the record and the code still agree, or when a playtest has just been run and its results need recording.
allowed-tools: Bash, PowerShell, Read, Glob, Grep, AskUserQuestion
---

# Running the checks

**There is no test suite here, and saying so is part of every report.** The
gates verify that the game *assembles* — that the pieces are present, declare
themselves, refer only to things that exist, and are licensed and packaged
honestly. Not one of them runs a line of the game's Lua.

The suite belongs to CodeBlock, in its own repository, and this repository
deliberately does not re-run it. The consequence: **the two go red
independently.** A mod change turns its CI red and leaves this one green; a
broken submodule pointer or a stale `.cdb.json` turns this one red and leaves the
mod's green. Check the repository you changed.

## The two gates

From the repository root:

```bash
bash scripts/check_game.sh
```

```bash
wsl bash -lc 'cd /mnt/c/Users/lacba/PRogrammation/codecube && luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes'
```

Lua and luacheck live in WSL on this machine, not on Windows, and that is the
same toolchain CI uses, so the results match. Pass the three paths explicitly
rather than `.`: CI has to, because `gh-actions-luarocks` installs a toolchain
into the workspace that `.` would lint, and matching it here keeps the two
runs comparable.

**Read the output, not the exit code.** `$?` does not survive this machine's WSL
layer. Green is:

- `all game integration checks passed` as the last line of `check_game.sh`, with
  no `FAIL:` above it, and
- luacheck **silent** — no `mods/...:line:col:` lines at all.

## What `check_game.sh` actually guarantees

Read the script before reporting on it; it is short, commented, and it is the
only description of what "the game assembles" means here. As it stands:

| Section | What it proves |
|---|---|
| `game.conf` | a `title` exists, and **no `max_minetest_version`** — that key is read by ContentDB, never enforced by the engine, and a stale one hides a working game from everyone on a current release |
| submodules | `mods/codeblock` and `mods/vector3` are populated, not that the pointer is a pushed commit |
| mod declarations | every `mods/*/` has a `mod.conf` whose `name` matches its directory, and no two collide |
| dependencies | every `depends` names a mod this game actually ships |
| licensing | every bundled mod carries a licence file or is catalogued in `THIRD-PARTY-LICENSES.md`, and the root `LICENSE` exists |
| `.cdb.json` | it matches what `gen_cdb_json.sh` produces from `CONTENTDB.md`, compared with CRs stripped |

Two things about that last one. It **regenerates `.cdb.json` and restores the
committed file afterwards**, so a run leaves the tree clean — verify with
`git status` rather than assuming, and if the tree is dirty afterwards, that is a
finding. And the comparison strips CRs on purpose: a checkout whose line endings
differ produces a file differing by one byte per line and nothing else, which is
not staleness. A fresh clone hit exactly that.

What it does **not** prove: that the game boots, that a world is flat, that
nothing is diggable, that the drone works, or that the release archive contains
what it should. Those are `PLAYTEST.md`'s, and `P1` and `P2` in particular.

## CI

Same two gates, `game assembles` and `luacheck (game mods)`:

```
https://api.github.com/repos/gigaturbo/codecube/actions/runs?per_page=5
```

then `/actions/runs/<id>/jobs`. Check that the run is on **the commit you mean**,
not merely the most recent one. A green run here says nothing about CodeBlock:
its workflow is separate and is looked up separately, at
`https://api.github.com/repos/gigaturbo/codeblock/actions/runs`, and that lookup
matters at exactly one moment — when the game is adopting one of its releases.

## PLAYTEST.md is the only evidence about behaviour

Everything the game does in a world rests on reading three short Lua files unless
a `PLAYTEST.md` check has been run. **Nothing in it has ever been run.** That is
the honest state and it is reported as such — never as passing, never as "should
be fine".

Groups are `W` world and mapgen, `L` light, `R` restrictions, `P` packaging, boot
and install. `W`, `L` and `R` are an hour's work in one world and are the
cheapest evidence available anywhere in this repository.

A result line replaces `unchecked`:

```
Result: pass — <commit> · engine <version> · <YYYY-MM-DD> — <one line of detail>
```

`fail` and `partial` take the same shape. Rules that carry the value:

- **Only a person who ran it in a world may move a result off `unchecked`.**
  Reading the code is not running the check; a result moved on reading is a lie
  the document exists to prevent.
- **Always the commit, the engine version and the date.** A pass recorded three
  milestones ago is not evidence about today's code, and the line's whole job is
  that a stale pass reads as stale.
- **A `fail` is not a finding.** Report it, and `AUDIT.md` allocates or widens an
  id.
- A check that only proves the game did not crash has not been run. Say what
  distinguished the pass.

## Asking the author to run one

You cannot enter a world. When a question needs one, put it to the author with
**`AskUserQuestion`** — a small set of options and a recommendation, never a
survey — and put it the way `PLAYTEST.md` needs it: what to do in-world, what a
pass looks like, and what would distinguish a pass from something that merely did
not crash. If you cannot reach the author, put the same question in your reply
for the calling session to put. Do not guess and record the guess as a check.

Do not ask the author to run the two gates. Those are yours.

## What a good check looks like here

- **It reaches something reading cannot settle.** A check restating what a
  six-line file plainly says is a check that will always pass.
- **One observation per check.** A check asserting four things reports the first
  and hides the rest.
- **It names what a *near miss* looks like.** `W3` exists because flat at spawn
  and flat two thousand nodes out are different claims; `R4` exists because `R1`
  passing could mean the drone stopped building too.
- **It carries its finding id** where there is one, so the reasoning stays in
  `AUDIT.md` and is not copied into two documents that will disagree.
- **A wrong check is a defect in the record, not in the code**, and is fixed in
  `PLAYTEST.md`.

## Related

Releases have their own gate: the `release-check` agent, which runs these two
plus licensing, packaging, archive contents and a fresh recursive clone. The
release procedure itself is the `release-codecube` skill, which is not
model-invocable on purpose — ask for it by name.
