# Playtest — Codecube (the game)

The manual checks nothing else here can reach. **This game has no test suite at
all** — `scripts/check_game.sh` verifies that the game *assembles*, not that it
behaves, and luacheck reads three files without running them. So every claim
about what the game actually does in a world rests on reading three short Lua
files, and this document is where that gap is written down rather than
rediscovered from prose in `ROADMAP.md` and `AUDIT.md`.

The mod's own manual checks are separate and are the larger set:
`mods/codeblock/PLAYTEST.md`. Nothing here re-checks the drone, the editor, the
sandbox or the API. What is checked here is the world those run in, and what a
player gets when they install the package.

`PLAYTEST.md` carries its own `export-ignore` line in `.gitattributes`, so this
file never ships to a player.

## How to record a result

Each check carries a **Result** line. Leave it as `unchecked` until someone
actually does it in a running world, then replace it with:

```
Result: pass — <commit> · engine <version> · <YYYY-MM-DD> — <one line of detail>
```

`fail` and `partial` take the same shape. **Always keep the commit and the
date**: a pass recorded three milestones ago is not evidence about today's code,
and the point of the line is that a stale pass reads as stale rather than as
current. A `fail` is not a finding — report it and let `AUDIT.md` allocate or
widen an id.

Reference the finding id in brackets after the title where there is one; the
reasoning is in `AUDIT.md` under that id. A check with no id exists because
nothing has gone wrong there yet and nothing proves it right either.

Groups are lettered **W** (world), **L** (light), **R** (restrictions) and **P**
(packaging, boot and install). Those letters are deliberately none of `B`, `S`,
`C`, `A` or `F`, so a check id can never be read as a finding id, and none of
`G1`–`G5`, the milestone lettering in `ROADMAP.md`.

## Where it stands

**Two of the eleven have been run, and neither is a behaviour check.** `P2`
passes and `P1` passes in half, both at `8b27f2f` on 2026-09-01 — they are the
two that a shell can perform without Luanti, which is exactly why they went
first. `P2` closes the half of `C15` that reading could not settle.

**No behaviour of this game has been checked in a world.** Every check in `W`,
`L` and `R` is `unchecked`, as are `P3`, `P4` and `P5` and the boot half of `P1`.
The game's behaviour is committed-but-unproven and should be reported as such
rather than as passing.

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` is three lines: one `set_mapgen_setting` call for
`mg_flags`, with `override_meta = true`.

### W1 · A new world is flat and clean at spawn

Create a new world with default settings and enter it. Look around, and fly a few
hundred nodes in one direction.

**Pass:** flat ground to the horizon at one level. No trees, grass, flowers or
any other decoration; no ore visible in the ground when a drone digs into it; no
cave mouths, no dungeon, no water, no biome transition — the ground node and its
colour never change.

Result: unchecked

### W2 · The mapgen flags survive a world that was created with others

Create a world, enter it once, leave. Edit that world's `map_meta.txt` to set
`mg_flags` to something with caves and decorations, then re-enter.

**Pass:** the world is still flat and clean. `override_meta = true` is the third
argument of the one call `cc_mapgen` makes, and this is the only thing that
argument is for. Without it a world remembers the flags it was created with and
the game's setting is read once and never again.

Result: unchecked

### W3 · The world is flat far from spawn, and far from where anyone has been

Fly, or teleport, several thousand nodes from spawn into unemerged map, and
watch the ground generate ahead.

**Pass:** the same flat clean ground, generated live. This distinguishes a
setting that applied at world creation from one that applies to every chunk the
engine emerges, and only the second is what the game promises.

Result: unchecked

---

## L · Light

`mods/cc_day/init.lua` is one `on_joinplayer` calling five player methods.

### L1 · Permanent noon, no sky objects [A7]

Enter a world and look up. Wait, or advance time with `/time`, and look again.

**Pass:** full daylight regardless of the time of day; no sun, no moon, no stars,
no clouds. `override_day_night_ratio(1)` is what pins the light level, and the
other four calls remove the objects — they are separate effects and a partial
result should say which of the two failed.

Result: unchecked

### L2 · It survives a rejoin, and it applies to a second player

Leave the world and rejoin. On a server, have a second player join after the
first.

**Pass:** the same for both, every time. The callback is `on_joinplayer` and
these are per-player settings, not world settings — a rejoin is the path that
matters, and a second player is what would catch a setting applied to whoever
joined first.

Result: unchecked

### L3 · Permanent noon still holds once the duplicate is removed [A7]

**Run this only after `A7` is fixed.** `codeblock` currently registers its own
`on_joinplayer` calling the same five methods with the same arguments, annotated
`-- TODO: TEMP fix`. `A7` removes that copy, leaving `cc_day` as the only thing
setting the sky.

**Pass:** L1 and L2 both still pass with the mod's copy gone. This is the check
that says which of the two was doing the work, and until it runs, `cc_day` being
sufficient on its own is an assumption.

Result: unchecked

---

## R · Restrictions

`mods/cc_security/init.lua`: a blank inventory formspec per player, a pass over
every registered node setting `diggable = false`, and two engine globals
overwritten (`A8`).

### R1 · Nothing is diggable

Punch and hold on the ground, on a wall the drone built, and on several different
block types including one from `wool` and one from `default`.

**Pass:** nothing breaks, anywhere, on any node. The pass runs at
`on_mods_loaded` over `minetest.registered_nodes`, so a node registered later —
by another mod, or by a future `default` trim — would not be covered; try a block
type the drone can place but you have not seen before.

Result: unchecked

### R2 · The inventory is empty and no item ever drops

Open the inventory. Then, with digging somehow permitted or in a world where a
node is destroyed another way, check that nothing appears as a dropped item.

**Pass:** the inventory formspec is blank, and no item entity ever exists in the
world. `handle_node_drops` is stubbed to do nothing.

Result: unchecked

### R3 · No knockback

Take a hit — from another player, or anything that would push you.

**Pass:** you are not moved. `calculate_knockback` returns 0.

Result: unchecked

### R4 · The drone can still build [R1 must not have broken it]

Run `stairs.lua`. Then run a program that places, and one that removes, blocks.

**Pass:** the drone places and removes normally. `diggable = false` is a property
of the node for a *player's* tool; the drone writes the map directly and must be
unaffected. This is the check that a restriction has not been made so broad it
disables the point of the game.

Result: unchecked

### R5 · The two callbacks behave, and the load order is deterministic [A8]

**Run this only after `A8` is fixed.** `A8` replaces two direct assignments to
`minetest.handle_node_drops` and `minetest.calculate_knockback` with capture and
chain, plus a `last_mod` declaration.

**Pass:** R2 and R3 both still pass, and they still pass with another mod
installed that assigns the same two globals. The defect is that the current code
discards whatever another mod installed and is discarded in turn by any later mod
that does the same, with the winner decided alphabetically; a second mod is the
only way to observe either half.

Result: unchecked

---

## P · Packaging, boot and install

### P1 · A fresh recursive clone boots

`git clone --recurse-submodules` into an empty directory, put it in Luanti's
`games/`, create a world, enter it.

**Pass:** it boots and is playable. This is the check that catches a submodule
pointer naming a commit nobody can fetch — `reference is not a tree` — which is
invisible from a working tree that already has the object. It is also the gate
the `release-codecube` skill runs before a tag.

Result: partial — `8b27f2f` · 2026-09-01 — the clone half only. A fresh
`git clone --recurse-submodules` populated both submodules from the HTTPS remotes
in `.gitmodules`: `codeblock` `2647228` (`v0.4.0-98-g2647228`) and `vector3`
`16621648` (`v1.5`), so neither pointer names a commit nobody can fetch, and
`check_game.sh` passes inside the clone. **Not booted in Luanti** — the half that
says it is playable is still unchecked.

### P2 · The release archive holds only what a player needs [C15]

`git archive --format=zip HEAD -o /tmp/codecube.zip` and list it.

**Pass:** no `.claude/`, `.reports/`, `.github/`, `scripts/`, no art sources, and
none of `CLAUDE.md`, `ROADMAP.md`, `TODO.md`, `AUDIT.md`, `PLAYTEST.md` or
`CONTENTDB.md`. `menu/*.png` **is** present — the main menu reads it. Note the
total size; the last measurement was 2.75 MB, down from 4.94 MB.

**This is the half of `C15` that reading cannot settle**, and the reason it stays
worth running: `.gitattributes` decides what reaches a player and **nothing in
either CI checks it**, so a file added to the repository ships unless a rule
excludes it, and nothing fails locally when one does. Run this whenever a tracked
file is added, not only at a release.

Result: pass — `8b27f2f` · 2026-09-01 — 488 entries, **1.93 MB zipped**
(2.26 MB uncompressed). Nothing hidden, no art source, no `scripts/`, and none of
the six record documents; `menu/background.png`, `menu/header.png` and
`menu/icon.png` are all present. Root holds only `CHANGELOG.md`, `LICENSE`,
`README.md`, `THIRD-PARTY-LICENSES.md`, `game.conf` and `minetest.conf`.
`mods/codeblock` and `mods/vector3` are **empty directory entries** — `git
archive` does not descend into submodules, and ContentDB resolves both as
dependencies rather than reading them from here. **The 2.75 MB above does not
reproduce by this method.** Measured both ends with `git archive --format=zip`:
`8d18e8b^` gives 3.29 MB zipped / 4.32 MB in 523 files, `8b27f2f` gives 1.93 MB /
2.26 MB in 488. The reduction is real and slightly larger than recorded; the
absolute pair in `C15` was measured some other way. **Quote the method with the
number** so the next run is comparable.

### P3 · The boot log is clean [B19, B24]

Watch the log while a world loads, from a cold start.

**Pass, once `A13` lands:** no `NodeResolver` errors and no deprecation warnings.

**On current code, expect and confirm exactly these:** five `NodeResolver` errors
from four `default` log schematics embedding `flowers:mushroom_brown` and
`flowers:mushroom_red` with no `flowers` mod vendored (`B19`), and two
`TileDef.image` deprecation warnings, from `default`'s furnace and from
`cc_security`'s `override_item` pass re-processing it (`B24`). Anything else in
the log is new and worth a finding.

**Luanti deduplicates deprecation warnings by message**, so a count here is a
count of distinct messages, not of occurrences — that is what hid these two
behind the `formspecs` warnings until `B20` removed them.

Result: unchecked

### P4 · The main menu presents the game

Open Luanti's main menu with the game installed and select it.

**Pass:** the game's name, its menu artwork and its icon all appear. `menu/*.png`
is what the menu reads, and it is the one thing `.gitattributes` deliberately
keeps in the archive; a `P2` rule written too broadly would break this and
nothing else would notice.

Result: unchecked

### P5 · The ContentDB page reads as a page [C20]

After a release, open the package page on ContentDB and read the long
description as someone who has just arrived there.

**Pass:** it says what the game contains, what distinguishes it and how to play
it once installed. No heading repeating the title, no badges, no screenshots, no
licence line, no link to the repository or back to the page itself. Every
instruction is complete as words — **images are not visible inside Luanti**, so
an instruction that depended on an icon has lost its object for exactly the
readers it was written for.

Also check the page from **inside Luanti**, in the content browser, not only in a
web browser. That is the reader the rule exists for and the one a web preview
does not show you.

Result: unchecked

---

Written 2026-08-30 at `54a2b7e`. Revised 2026-09-01 at `8b27f2f`, when `P2` and
half of `P1` were run — the two that need no running world. Nothing in `W`, `L`
or `R` has been run.
