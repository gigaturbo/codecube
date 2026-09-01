# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository. The response, editing, coding and helper conventions are
in `~/.claude/CLAUDE.md` and are not repeated here.

## What this is

Codecube is a Luanti (formerly Minetest) **game** in which the player programs a
drone in Lua to build structures. It is not a mod, so it belongs in Luanti's
`games/` directory. What the game itself contributes is the setting and the fit:
a flat world, permanent day, build restrictions, the settings a server owner
wants, and a presentation that makes the programming pleasant to use. Branch
`main`.

**The game is thin on purpose.** Everything a player actually does — the sandbox,
the drone, the editor, the API and its limits — belongs to **CodeBlock**, an
upstream ContentDB package by the same author, embedded here as a submodule. The
game is a *consumer of its releases*. This repository's documentation stays
general — what the game is, its features, its settings, how to play — and
redirects to CodeBlock's own package and repository for the API and the detailed
instructions.

## `mods/` is not this project's code

| | |
|---|---|
| `codeblock`, `vector3` | Submodules. Pinned dependencies, **not working copies.** |
| `cc_day`, `cc_mapgen`, `cc_security` | The game's own mods, one Lua file each: permanent daylight, a flat clean mapgen, and the build restrictions. **This is the only Lua this repository owns or lints.** |
| `default`, `dye`, `wool` | Vendored from Minetest Game for their nodes. Third-party, deliberately not linted and not ours to restyle. |

**CodeBlock is developed in its own sibling checkout, not here.** `mods/codeblock`
exists so the game assembles and runs; it has its own repository, its own record,
its own CI and its own release path, and none of that is visible or relevant from
this tree. Do not edit it, commit to it, or read its documents to answer a
question about this game. If a question is really about the sandbox, the drone,
the editor or the API, it belongs to that project.

`.gitmodules` declares both submodules and `scripts/check_game.sh` verifies both
are populated. Both working remotes are SSH; `.gitmodules` deliberately stays on
HTTPS so anyone can clone the game without keys.

### The submodule pointer follows releases, not commits

`mods/codeblock` pins the CodeBlock release this game has **adopted**, not the tip
of upstream. So an ordinary mod change happens entirely upstream and nothing
happens here, and a pointer that lags upstream is *correct*. An unstaged
`mods/codeblock` in `git status` is the normal resting state.

The pointer moves only when the game adopts a new release — and that is the same
moment the game's own documentation is brought up to date with it. The
`release-codecube` skill owns that procedure. At adoption time, and only then, the
old hazard applies:

```bash
cd mods/codeblock && git checkout v<version>   # a tag that is already pushed
cd ../.. && git add mods/codeblock && git commit
```

Recording a hash nobody can fetch is invisible from a working tree that already
has the object; only a fresh `git clone --recurse-submodules` catches it
(`reference is not a tree`).

## The record

Six tracked documents, all in this directory, plus the `.claude/` definitions and
the HTML renderings:

- `ROADMAP.md` — the game's own mods, its packaging and presentation, and which
  CodeBlock release it has adopted. Its milestones are lettered **`G1`–`G5`**,
  deliberately not "Phase N" — that is the mod's scheme and appears in its commit
  messages, and the two must stay distinguishable.
- `TODO.md` — intentions that are not findings. One line per item and a finding
  id where there is one; the description of the work belongs in `ROADMAP.md`, and
  the reasoning in the audit.
- `AUDIT.md` — the game's findings, each with its severity, state and, once
  fixed, how. **Findings only**: no roadmap, no milestones.
- `PLAYTEST.md` — the manual checks nothing else here reaches, each with what to
  do in a running world and a result line. The game has no test suite, so this is
  its only route to verifying behaviour. Groups are lettered `W`, `L`, `R`, `P`,
  chosen not to collide with a finding id or a `G` milestone.
- `CHANGELOG.md` — what shipped, for people who *play* the game. It names the
  CodeBlock release adopted and links to that project's changelog rather than
  repeating it.
- `CONTENTDB.md` — the ContentDB long description. **Not the README**: write this
  file, never `.cdb.json`, and read the rules in the header of
  `scripts/gen_cdb_json.sh` before adding to it. (C20)
- `.reports/*.html` — gitignored browsable renderings of `ROADMAP.md`, `AUDIT.md`
  and `PLAYTEST.md`. Presentation only: they hold no fact the Markdown does not,
  so a deleted `.reports/` costs nothing.

`AUDIT.md`, `PLAYTEST.md` and `CONTENTDB.md` each carry their own `export-ignore`
line in `.gitattributes`, so none of them ships to a player.

Finding ids — `B` bugs, `S` sandbox and security, `C` compliance and packaging,
`A` architecture — are **never renumbered**, because commit messages cite them. A
gap in a sequence is a finding held by the mod's own audit, from when the two
projects shared one record. The mod's `F` feature series is its own.

The `project-manager` agent owns all six, plus `README.md` and this file, the
renderings, and the `.claude/` definitions beside them; edit one by hand only for
something that agent cannot know.

## The agents and the skills

Three agents divide the work by what each can be trusted with, and each reads its
own skill first. Their definitions are the long form; this is only the map.

| Agent | Owns | Reads |
|---|---|---|
| `project-manager` | the record above, `README.md`, `CONTENTDB.md` and the `.cdb.json` generator over it, `.reports/`, and the `.claude/` definitions | `build-feature` |
| `code-expert` | `mods/cc_day`, `mods/cc_mapgen`, `mods/cc_security`, `scripts/`, `game.conf`, `minetest.conf`, and the packaging and lint configuration | `code-standards`, `references` |
| `test-agent` | the two gates, the CI lookup, `PLAYTEST.md`'s result lines, and the evidence side of `AUDIT.md` | `run-checks`, `references` |

Two rules make the split work: **call the agent rather than doing its work**, and
**never two of them on one file in a turn** — `AUDIT.md` and `PLAYTEST.md` are
the two that can happen to.

The `build-feature` skill holds the order any piece of work follows, and its
step 0 is the one this project needs most: deciding whether the work is the
game's at all, or the mod's.

The `release-codecube` skill carries `disable-model-invocation: true`
deliberately, because a release is not something to start by accident. Ask for it
by name. The `release-check` agent gates it.

## Commands

These are the game's own checks, and they are what this repository's CI runs —
`game assembles` and `luacheck (game mods)`:

```bash
bash scripts/check_game.sh    # the game assembles: metadata, submodules, deps, .cdb.json
luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes
bash scripts/gen_cdb_json.sh  # regenerate after a CONTENTDB.md edit; check_game.sh diffs it
```

The game has **no test suite of its own**, and no automated check reaches its
behaviour at all — `check_game.sh` verifies that the game *assembles*. Say so
plainly rather than reporting a test gate as passed. What behaviour evidence
exists is whatever has been run out of `PLAYTEST.md`, and at present that is
nothing.

Linting and testing the mod belongs to its own repository and CI, and neither
workflow duplicates the other. The consequence: **the two go red
independently.** A mod change turns its CI red and leaves this repository green,
because nothing here re-runs its checks; a broken submodule pointer or a stale
`.cdb.json` turns this one red and leaves the mod's green. Check the repository
you changed.

## Architecture

`cc_mapgen` makes the world flat and clean, `cc_day` holds it at noon,
`cc_security` restricts what a player may break or place; each is a single Lua
file. That is the whole of this game's code.

## Environment notes

- `minetest` is a permanent alias for `core` and is **not** deprecated.
- Lua 5.1 / LuaJIT: `loadstring`, `setfenv`, `math.pow`, `math.atan2` all exist;
  `0` is truthy; you cannot yield across `pcall`.
- `check_game.sh` fails `game.conf` for having a `max_minetest_version`.
- `git archive` does not include submodule contents, so what a ContentDB user
  gets for `mods/codeblock` comes from ContentDB's own dependency resolution, not
  from this repository's release archive.
