# BACKLOG

Codecube is a Luanti **game** in which the player programs a drone in Lua to
build structures. The game is thin on purpose: everything a player actually does
belongs to **CodeBlock**, an upstream ContentDB package embedded as a submodule,
and this game is a consumer of its releases. What is left is the world, the
light, the restrictions, the interface's look and the packaging.

**`v2.0.0` is published on ContentDB**, tagged on `1ca0d2a` on 2026-09-22 with
CodeBlock `v1.0.0` adopted. **`v3.0.0` is next**: CodeBlock `v2.0.0` is
adopted and breaks saved programs, so the game's next release is major.
ContentDB's Git import is disabled for now, so that release goes up by hand
(`F-P-1`).

**Every id here predates the `B-X-N` scheme and keeps its old form for ever**,
because commit messages cite them: `B` bugs, `S` sandbox and security, `C`
compliance and packaging, `A` architecture, `G` milestones, and the in-world
checks under `W`, `L`, `R` and `P`. They were allocated once across this record
and the mod's, so **a gap here is an id that lives in the mod's**, not one
dropped. The categories below are for new items only.

The reasoning behind any item is in the `codecube-kb` skill, not here. The
in-world check recipes are in its `references/playtests.md`.

## Categories

| Letter | Covers |
|---|---|
| `W` | The world, its bounds and the mapgen |
| `R` | What a player may break, place or drop |
| `I` | The sky, the light and the interface |
| `P` | Packaging, licensing and what ships |
| `M` | The adopted CodeBlock release and the submodules |
| `N` | Commands that move a player around the world |
| `V` | How the player moves: speed, jump and gravity |

## Bugs

Nothing open.

## Features

### F-I-1 · a panel lists the player's commands

`todo` `medium` `filed 2026-09-23` `target: v3.0.0`

A panel exposing at least `saveme` and `newplace`, so a player does not have to
know the chat syntax. Still to decide: whether it lives in `cc_commands` and
calls the same subcommand handlers, which is what that mod's one table is built
for, how it opens (`/codecube` with no argument, a tool, or a key through the
inventory form), and whether it wears `cc_gui`'s style. It shows only the
subcommands the player holds the privileges for, as `/codecube`'s usage already
does.

### F-I-2 · a hotbar tool runs the most useful commands

`todo` `medium` `filed 2026-10-01` `target: v3.0.0`

A tool in the hotbar beside the drone's two, so a player reaches `newplace` and
the commands like it without typing. Still to decide: which commands, how one is
chosen (a click, a punch and a place, or a small menu), and whether the tool is
handed out on join or taken from the creative inventory like codeblock's.

### F-P-1 · v3.0.0 is published on ContentDB

`todo` `medium` `filed 2026-11-19` `target: v3.0.0`

ContentDB's Git update detection is disabled for every package (seen
2026-11-19 on CodeBlock's v2.0.0), so a tag publishes nothing and the release
webhook may not either. Before tagging: `CONTENTDB.md`'s *Recent changes* for
v3.0.0, `CHANGELOG.md`'s entry checked against whatever else ships, and `P1`
re-run at the tag. After tagging, if the tag did not publish: upload a zip
built with both submodules filled in, as `codecube-kb`'s `references/release.md`
describes, paste `CONTENTDB.md` into *Edit details*, and compare the live long
description with `.cdb.json`.

## Tests

### P4 · the main menu presents the game

`todo` `playtest`

Never run. Reads what a player sees in Luanti's own main menu before they start
a world: the name, the description, the cover and the menu artwork.

### P5 · the ContentDB page reads as a page

`todo` `playtest` `blocks: C20`

Never run, and runnable since the 2026-09-23 upload. Nothing in this repository
can see the rendered result, so ContentDB's own rules are the only test and the
published page is the only reading.

## Closed

**A check listed here is done against a commit, not for good.** Its recipe is
permanent and lives in `codecube-kb`'s `references/playtests.md`, which also
says which group a change owes. Move the line back into `Tests` as a `todo`
entry the moment the code under it moves, and keep the commit and date below so
whoever re-runs it knows what they are re-reading against.

### Bugs and findings

- `B-W-1` closed `medium` · the rescue near the wall put a player on top of the barrier, then inside it once the mapchunk above generated. **Fixed by** leaving `cc_mapgen:barrier` out of `cc_security`'s `solid` table
- `A20` wontfix `medium` · `A13`'s deletion took the hand's groupcaps with it, so nothing is hand-diggable and the digging restriction is unfalsifiable without a setup. Decided 2026-09-09: the condition is real and permanent, the author declined the only fix on the merits, and the obligation is discharged because `R1` ran falsifiably under a temporary hand override and passed. **Not outstanding work**
- `A8` wontfix `medium` · the every-node `on_mods_loaded` walk stays, and `last_mod` is untested by choice. Decided 2026-09-09: *the case of another mod in this game is not actual*. Its drop-chain half is confirmed by `R2` at `dd83b99`, and no source changed for the decision

- `B57` closed `low` · nothing in the game styled a formspec or the hotbar, so every form fell back to the engine's semi-transparent default: `A13`'s deletion of `mods/default` took Minetest Game's prepend and hotbar images with it and nothing replaced them. **Fixed by** a fourth mod, `cc_gui`, at `ba92d52`; neither gate could see the defect and neither can see the fix, so `P6` at `3f404ec` is the whole of its evidence
- `S8` closed `medium` · a bookshelf's own node formspec reached around the blanked player inventory, two `main` lists of its own carrying items in and out. **Fixed by** `register_allow_player_inventory_action` plus the three `allow_metadata_inventory_*` denials in `cc_security`; confirmed by `R6`
- `B50` closed `medium` · a player could fall out of the world, by two routes. **Fixed by** a bedrock floor at `y = 0`, a full-height wall at the generated edge, and a `cc_security` rescue into the player's own column
- `B49` closed `medium` · `default`'s ABMs and saplings rewrote what a program had built. **Fixed by** every ABM's `action` and every node's `on_timer` replaced, in `cc_security`
- `B48` closed `low` · wool played the dig animation before the server refused. **Fixed by** six digging groups stripped from every node's `groups`
- `B47` closed `low` · the sunrise glow was still drawn, so part of the sun showed at dawn. **Fixed by** `set_sun{sunrise_visible = false}`
- `B24` closed `low` · vendored `default` used a deprecated `TileDef.image` field. **Fixed by** renamed to `name`, one token
- `B19` closed `low` · five `NodeResolver` errors on every world load. **Fixed by** two `flowers:*` aliases of `air` in `cc_mapgen`
- `B20` closed `low` · every deprecation warning in the boot came from `mods/formspecs`. **Fixed by** the mod removed
- `C21` closed `low` · a bundled submodule carried the version ceiling this game's own check forbids. **Fixed by** adopting `vector3` `v2.0.2`, which declares `min_minetest_version = 5.3` and no ceiling
- `C22` closed `low` · three menu images shipped to every player with no licence stated anywhere. **Fixed by** a new `menu/license.txt`, two media rows in `THIRD-PARTY-LICENSES.md`, and `media_license` in the generator
- `C20` closed `medium` · the ContentDB long description was `README.md` verbatim, breaking six of ContentDB's page rules. **Fixed by** `CONTENTDB.md` written for its own reader, and the generator repointed at it
- `C15` closed `low` · the release archive shipped `.claude/`, the record documents and the art sources. **Fixed by** `.* export-ignore` plus rules by name
- `C5` closed `medium` · the three `cc_*` mods had no licence file. **Fixed by** a `license.txt` each, enforced by `check_game.sh`
- `C4` closed `medium` · licence metadata disagreed between the game and the mod inside it. **Fixed by** unified on AGPL-3.0-only
- `C3` closed `medium` · bundled AGPL and MIT code shipped without its licence text. **Fixed by** the text, or a `THIRD-PARTY-LICENSES.md` row, enforced by `check_game.sh`
- `C2` closed `low` · image URLs named `master` on a repository that has only `main`. **Fixed by** repointed to `main`
- `A7` closed `medium` · `cc_day` and `codeblock` both registered an `on_joinplayer` calling the same five sky methods, the mod's marked `-- TODO: TEMP fix`. **Fixed by** upstream removed its copy, the setting that had guarded it and its `settingtypes.txt` entry (their `C18`, `3fa9d0c` and `6440ca0`); the game adopted `09c708d` on 2026-09-17 and changed nothing of its own
- `A14` closed `medium` · CI conflated the component with the composite: the game's badge reported on the mod's internals and the mod had no CI at all. **Fixed by** split along the component/composite line; the mod took its own `.luacheckrc`, specs and badge
- `A13` closed `medium` · `mods/default`, `mods/dye` and `mods/wool` were 9,744 lines vendored to supply 106 node definitions. **Fixed by** all three deleted at `50fd05f`, once CodeBlock registered its own 105 nodes; `cc_mapgen` took the three essential mapgen aliases and the world's surface material
- `A19` closed `medium` · permanent noon reached the light level and the sky objects but not the sky's own colour, so the horizon and the fog still moved with the time of day — and with the player's yaw. **Fixed by** one `set_sky{type = "plain", base_color = "#90d3f6"}` in `cc_day`, `plain` being the one sky type the engine excludes from the directional tint

### Features

- `F-M-1` done `medium` · CodeBlock `v2.0.0` adopted, up from `v1.0.0`: 3930 colours, the 35 named ones as bricks, and faster drones. It breaks saved programs, so the game's next release is `v3.0.0`
- `F-N-3` done `medium` · a player holding `saveme`, granted to each player once on their first join and revocable for good after that, climbs out of a build with `/codecube saveme`, once a second. They land on top of a build nearby, the highest node of a mapblock column drawn at random within 32, 64 then 128 nodes, and the mapblocks around them are carved to air only when no column drawn has room. The rescue from the void uses the same search, with a bedrock platform under the player as its last resort, and no longer keeps them in their own column or falls back to spawn
- `F-N-2` done `large` · a player holding `spreadplayers` sends players to plots of `codecube_plot_size` nodes with `/codecube spreadplayers <random|spaced>`, everyone online but the caller or the players named, `*` globs and `-` exclusions. The 100 by 100 core of every plot used, and of every spot a player stood on at a spread, is recorded in mod storage and never handed out again, and a core found built is recorded and swapped for another
- `F-N-1` done `medium` · a player holding `newplace`, granted to each player once on their first join and revocable for good after that, moves to a random column of the surface with `/codecube newplace`, at least 500 nodes from the wall or a tenth of the world's width when that is less, once per `codecube_newplace_cooldown` seconds unless they hold `server`
- `F-V-1` done `small` · a player holding `server` sets anyone's speed with `/codecube speed <slow|normal|fast|fastest> [<player>]`, one `speed` physics multiplier of 2, 2.5, 3 or 3.5 over walking, fast mode and flight, kept in the player's metadata. A player never given one moves at `normal`, and even `slow` is twice the engine's speed and the old default
- `F-N-4` done `medium` · the game's commands got one home and one namespace: a self-contained mod, `cc_commands`, with every command a subcommand of `/codecube` checking its own privileges, as codeblock does under `/codeblock`

### Milestones

- `G5` done `large` `1ca0d2a` · CodeBlock `v1.0.0` adopted and `v2.0.0` published on ContentDB on 2026-09-23. The published zip is 94 files and 2.92 MB, with both submodules bundled at the tagged pointers, `menu/` and every `cc_*` texture present, and no dotfile or record document
- `G8` done `medium` `ba92d52` · the interface got the game's own style: one formspec prepend and two hotbar images in a fourth mod, `cc_gui`, after `A13`'s deletion took Minetest Game's with it
- `G7` done `medium` `dd83b99` · the world became something to be in: the texture rework, all seven tiles generated from `scripts/gen_textures.py`
- `G6` done `large` `60259dd` · the world was bounded: a bedrock floor at `y = 0`, a full-height barrier wall at the generated edge, and a rescue into the player's own column
- `G4` done `medium` `dd83b99` · the game's own mods were made to behave: the plain sky, the dig-group strip, the inventory denials and the end of the duplicated sky block
- `G3` done `large` `50fd05f` · the vendored `default`, `dye` and `wool` were deleted outright once CodeBlock registered its own 105 nodes; 9,744 lines went, and the three essential mapgen aliases moved into `cc_mapgen`
- `G2` done `medium` · the game got a check of its own, `scripts/check_game.sh`, which verifies that the game assembles and deliberately re-checks nothing of the mod's
- `G1` done `medium` · the package was made honest and installable: licence files, metadata, an archive that ships only what a player needs, and a long description written for its own reader

### In-world checks

- `T-N-3` done `playtest` 2026-11-19 `29f20e4` Luanti 5.17.0, scripted · sealed in a box, three runs land on top of a build or the grass, never inside, at two different places out of three (one mapblock column always answers the same node); on open ground it gives the `newplace` hint and moves no one; a second call inside a second is told to wait. A player who joined `871aa60`, before `saveme` existed, gets it on rejoining `29f20e4` and keeps `newplace`; once revoked, it stays revoked across a rejoin
- `W9` done `playtest` 2026-11-19 with the `B-W-1` fix in the working tree over `0fdd732`, Luanti 5.17.0, scripted · out through a gap in the wall lands on the grass at `128.5` inside it; three falls beside a cube land twice on its roof and once on the grass, never inside; from below the floor far from anything generated, on the grass at `128.5`
- `R9` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · twenty blocks in five colours and four materials, five distinct solid colours, every lamp lighting its neighbour to 13 at night, the `air` run removing all twenty; `colors.vermilion` and `'vermilion'` each stop the program and place nothing; `'red'` is the same node as `colors.red`; a `v1.0.0` solid block becomes a palette colour once a player is near it. Not seen by eye: the colours, the tint
- `R4` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · `stairs.lua` completes and builds its ten bricks, and the `R9` programs place and remove normally
- `W8` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · a fall through a removed floor tile is rescued once, onto the grass at `128.5`, with no platform built; standing on the exposed floor at `0.5` and beside the wall moves no one
- `P7` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · a new player gets the drone placer and setter from `/codeblock tools`. The creative inventory route not read
- `P3` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · no warning or error from the game in the server's or the client's log, from a cold start. The engine's own *No SHA256 known for builtin file* notes appear in every game on this install and are not the game's
- `P1` done `playtest` 2026-11-19 `f5d34a7`, record-only over `d2d629c`, Luanti 5.17.0, scripted · a recursive clone fetched both submodules from GitHub at `39e579b` and `fc8a5b8`, `check_game.sh` passed inside it, the server booted from it and a client entered the world. Owed again at the `v3.0.0` tag
- `T-N-2` done `playtest` 2026-10-02 `871aa60` Luanti 5.17.0 · `random` and `spaced` each move everyone but the caller onto bare grass, `spaced` puts them far apart, a name, a `student_*` glob and a `-name` exclusion each choose the right players, a second spread never lands anyone on a plot used by the first, a plot built on by hand is skipped, and a player without `spreadplayers` is refused
- `T-N-1` done `playtest` 2026-10-02 `871aa60` Luanti 5.17.0 · newplace lands a player on fresh grass well inside the wall, refuses a second use inside the cooldown with the seconds left except to `server`, stays revoked from a non-admin across a rejoin, and `/codecube` lists only what the caller may run
- `T-V-1` done `playtest` 2026-10-02 `871aa60` Luanti 5.17.0 · a fresh player moves at `normal`, each of the four speed levels changes walking, fast mode and flight, a player without `server` is refused, and a level survives a rejoin
- `W1` done `playtest` 2026-09-01 · a new world is flat and clean at spawn
- `W2` done `playtest` 2026-09-01 · the mapgen flags survive a world that was created with others
- `W3` done `playtest` 2026-09-01 · the world is flat far from spawn, and far from where anyone has been
- `W4` done `playtest` 2026-09-07 · the floor is there and you cannot fall through it
- `W5` done `playtest` 2026-09-07 · the wall stands, full height, all the way along
- `W6` done `playtest` 2026-09-07 · the drone's bound followed the number
- `W7` done `playtest` 2026-09-07 · an existing world is re-bounded
- `W10` done `playtest` 2026-09-08 · the wall is a barrier you can see through, and still a wall
- `W11` done `playtest` 2026-09-22 · the floor and the wall are the game's own artwork, and the floor does not tile
- `W12` done `playtest` 2026-09-08 · a new world puts you 128 nodes above the floor
- `W13` done `playtest` 2026-09-08 · an existing world's surface moves to 128 when you open it
- `W14` done `playtest` 2026-09-08 · the rescue still knows where the surface is · retired 2026-10-02 with the spawn fallback it checked
- `W15` done `playtest` 2026-09-09 · the surface is one layer of grass over dirt, at the right height
- `W16` done `playtest` 2026-09-09 · no node in the world is unknown, anywhere in the column
- `L1` done `playtest` 2026-09-01 · permanent noon, no sky objects
- `L2` done `playtest` 2026-09-01 · it survives a rejoin, and it applies to a second player
- `L3` done `playtest` 2026-09-09 · permanent noon still holds when only `cc_day` is setting the sky
- `L4` done `playtest` 2026-09-09 · the sky's own colour and the fog do not move with the time of day, or with where you look
- `R1` done `playtest` 2026-09-09 · nothing is diggable
- `R2` done `playtest` 2026-09-09 · the inventory is empty and no item ever drops
- `R3` done `playtest` 2026-09-09 · no knockback
- `R5` done `playtest` 2026-09-09 · the chained drop handler still hands out nothing
- `R6` done `playtest` 2026-09-01 · a bookshelf opens nothing you can use
- `R7` done `playtest` 2026-09-02 · the world does not change on its own
- `R8` done `playtest` 2026-09-09 · no node ever plays a dig animation
- `P2` done `playtest` 2026-09-01 · the release archive holds only what a player needs
- `P6` done `playtest` 2026-09-22 · every form and the hotbar wear the game's own style
