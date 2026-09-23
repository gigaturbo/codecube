# CLAUDE.md

## What this is

Codecube is a Luanti (formerly Minetest) **game** in which the player programs a
drone in Lua to build structures. It is not a mod, so it belongs in Luanti's
`games/` directory. Branch `main`. Code AGPL-3.0-only, its own media
CC BY-SA 4.0.

**The game is thin on purpose.** Everything a player actually does, the sandbox,
the drone, the editor, the API and its limits, belongs to **CodeBlock**, an
upstream ContentDB package by the same author, embedded here as a submodule. The
game is a *consumer of its releases*. What the game contributes is the setting
and the fit: a flat world, permanent day, build restrictions, the settings a
server owner wants, and a presentation that makes the programming pleasant.

**The game's own code is 218 lines of Lua in five files.** Re-derive that rather
than trusting it: `grep -hvE '^[[:space:]]*(--.*)?$' mods/cc_*/*.lua | wc -l`.

## Layout

- [mods/cc_day/](mods/cc_day/) holds the world at noon: the light level, a plain
  sky, no sky objects.
- [mods/cc_gui/](mods/cc_gui/) one formspec prepend and the two hotbar images,
  set per player on join.
- [mods/cc_mapgen/](mods/cc_mapgen/) the world's flags, size, depth, its four
  nodes and the three mapgen aliases a non-V6 mapgen needs of a game.
  `mapgen_env.lua` writes three of those nodes on the emerge threads.
- [mods/cc_security/](mods/cc_security/) what a player may break, place or drop,
  and the rescue that puts one back inside the world box.
- `mods/codeblock`, `mods/vector3` **submodules: pinned dependencies, not
  working copies.** Do not edit, commit to, or lint them from this tree.
- [scripts/](scripts/) the game's own check, the `.cdb.json` generator and the
  texture generator. Not shipped.
- [menu/](menu/) the main menu's artwork and its licence file. Shipped.
- [CONTENTDB.md](CONTENTDB.md) the source of the ContentDB long description.
  `.cdb.json` is generated from it. Neither ships.
- [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md) the licence catalogue for
  everything the game bundles. **The one record document that ships**, because a
  licence notice has to travel with what it licenses.
- [CHANGELOG.md](CHANGELOG.md) what shipped, for people who play the game.
  Shipped.
- [BACKLOG.md](BACKLOG.md) all open work, with what has closed compressed below
  it. Not shipped.

**`mods/` holds exactly six directories.** `check_game.sh` prints
`6 mods declared`; anything higher means a mod has come back. `default`, `dye`
and `wool` were deleted outright once CodeBlock started registering its own 105
nodes, and putting one back is a whole-game decision about licensing and about
9,744 lines nobody here maintains.

## Architecture

**`cc_mapgen` makes the world flat, clean and bounded.** `cc_mapgen:dirt` is the
fill the engine writes through the `mapgen_stone` alias, `cc_mapgen:grass` is
one layer at `mgflat_ground_level`, `cc_mapgen:bedrock` is the floor at `y = 0`
and `cc_mapgen:barrier` is a translucent wall at the outermost generated column.
The world's size is `mapgen_limit` and its depth is `mgflat_ground_level`, both
forced onto the world because the engine stores every mapgen setting per world.

**`cc_security` denies, with one exception.** The rescue that puts a player back
inside the world box is the only place this game writes to the map.

**`cc_day` and `cc_gui` are the look**: a plain sky immune to the time of day,
one formspec prepend and two hotbar images.

**The submodule pointer follows releases, not commits.** `mods/codeblock` pins
the release this game has **adopted**, not the tip of upstream, so a pointer
that lags upstream is correct and an unstaged `mods/codeblock` in `git status`
is the normal resting state.

Everything else is in the `codecube-kb` skill: the constraints each area
carries, the decisions already argued out, the in-world check recipes, the
adoption procedure and the release gate. **Read the reference for the file you
are about to touch.**

## Commands

The game's own checks, and what this repository's CI runs as `game assembles`
and `luacheck (game mods)`. Both from the repository root.

```powershell
bash scripts/check_game.sh
wsl bash -lc 'luacheck mods/cc_*/ --formatter plain --codes'
```

**Use the glob, never a list of mod names.** It is what CI lints, so the two
cannot disagree about which mods exist; a hardcoded list is how `cc_gui` shipped
unlinted.

```powershell
bash scripts/gen_cdb_json.sh     # after a CONTENTDB.md edit; check_game.sh diffs it
py -3 scripts/gen_textures.py    # redraws all seven textures the game ships
```

`gen_textures.py` draws every texture from the palettes and seeds in its own
table, byte-identically on every run. The seven PNGs are **committed
artefacts**, so nothing fails if it is never run again. It exists so the
palettes and the seeds do not rot in a comment.

**Report.** Rebuilds `.reports/backlog.html` from the JSON.

```powershell
py -3 $HOME/.claude/skills/project-architecture/tools/gen_report.py --json .reports/backlog.json --out .reports/backlog.html --backlog BACKLOG.md
```

**Read the output, not the exit code.** `$?` does not survive this machine's WSL
layer. Green is `all game integration checks passed` and luacheck silent.
`check_game.sh` regenerates `.cdb.json` to compare it and restores it, so
`git status` should be no dirtier afterwards; check rather than assume.

**The game has no test suite, and no automated check reaches its behaviour at
all.** `check_game.sh` verifies that the game *assembles*. Say so plainly rather
than reporting a test gate as passed. Every claim about behaviour rests on an
in-world check with a result naming a commit, an engine version and a date.

**Linting and testing the mod belongs to its own repository**, and neither
workflow duplicates the other. So **the two go red independently**: a mod change
turns its CI red and leaves this repository green, and a broken submodule
pointer or a stale `.cdb.json` turns this one red and leaves the mod's green.
Check the repository you changed.

## Packaging

`game.conf` declares `min_minetest_version = 5.9`, which is what writing from
the mapgen environment needs, and **no ceiling**: `check_game.sh` fails the
build on a reinstated one. ContentDB builds the release with `git archive` and
nothing in CI checks [.gitattributes](.gitattributes), so verify what actually
ships:

```powershell
git archive --format=tar -o $env:TEMP\archive-check.tar HEAD
tar -tf $env:TEMP\archive-check.tar | ForEach-Object { ($_ -split '/')[0] } | Sort-Object -Unique
```

`menu/` and every `mods/cc_*/textures/*.png` must be present, or the floor, the
wall and the game's own panels render untextured. **`git archive` does not
include submodule contents**, so what a ContentDB user gets for `mods/codeblock`
comes from ContentDB's own dependency resolution.
