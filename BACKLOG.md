# BACKLOG

Codecube is a Luanti **game** in which the player programs a drone in Lua to
build structures. The game is thin on purpose: everything a player actually does
belongs to **CodeBlock**, an upstream ContentDB package embedded as a submodule,
and this game is a consumer of its releases. What is left is the world, the
light, the restrictions, the interface's look and the packaging.

**`v2.0.0` is published on ContentDB**, tagged on `1ca0d2a` on 2026-09-22 with
CodeBlock `v1.0.0` adopted. A release webhook now fires on each new tag. What is
left is in-world checks: nothing has been played against the release.

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

### F-V-1 · the player walks and runs at the game's own speed

`todo` `small` `filed 2026-09-24` `target: v2.1.0`

Change the default walking and running speed, so crossing a large build does not
take long. Still to decide: the values, whether through the `movement_speed_*`
settings forced onto the world or a per-player `set_physics_override` on join
(which also scales the drone's owner in flight and climbing), and whether a
server owner can change them.

### F-N-4 · settle the command namespace and where the commands live

`todo` `medium` `filed 2026-09-23` `target: v2.1.0` `blocks: F-N-1` `blocks: F-N-2` `blocks: F-N-3`

The three commands below need one namespace, bare `/saveme` or a prefix such as
`/cc`, and one home. A separate, self-contained mod another game could copy
would fit the thin-game design better than more code in `cc_security`, as long
as the column rescue it would share with `B50` is not duplicated.

### F-N-3 · a player buried in a program's build can get out

`todo` `medium` `filed 2026-09-23` `target: v2.1.0`

A `saveme` command for a player walled in by generated nodes, who cannot dig
out because nothing is diggable. Still to decide: where the player lands (the
first free space above, the nearest free space, or the surface of the column),
and whether it reuses the `cc_security` rescue that already finds a standable
spot in a column.

### F-N-1 · a player can move to a fresh area to build in

`todo` `medium` `filed 2026-09-23` `target: v2.1.0`

A `newplace` command teleports the player to an area that is probably empty.
Still to decide: how "empty" is judged (never generated, far from other players,
far from placed nodes), whether it needs a privilege, and whether it is a chat
command, a function or both.

### F-N-2 · an admin can spread players far apart

`todo` `large` `filed 2026-09-23` `target: v2.1.0`

A `spreadplayers` command gives each player in a group an empty area far from
the others, so builds are less likely to be fought over. Still to decide: the
privilege that grants it, how players are chosen (all online, a list, a
filter), and the layout (a large circle, a grid, a jittered grid, or maximised
spacing), all within the world box from `get_mapgen_edges()`.

### F-I-1 · a panel lists the player's commands

`todo` `medium` `filed 2026-09-23` `target: v2.1.0` `needs: F-N-4`

A panel exposing at least `saveme` and `newplace`, so a player does not have to
know the chat syntax. Still to decide: how it opens (a chat command, a tool, or a
key through the inventory form), and whether it wears `cc_gui`'s style.

## Tests

### P3 · the boot log is clean

`todo` `playtest` `blocks: B19` `blocks: B24`

Never run. **One sitting closes both `B19` and `B24`**, which are resolved in
code at `e51f969` and unverified in a world, and this is the only thing that can
close them. The game has no test suite, so nothing else reaches it.

### P4 · the main menu presents the game

`todo` `playtest`

Never run. Reads what a player sees in Luanti's own main menu before they start
a world: the name, the description, the cover and the menu artwork.

### P5 · the ContentDB page reads as a page

`todo` `playtest` `blocks: C20`

Never run, and runnable since the 2026-09-23 upload. Nothing in this repository
can see the rendered result, so ContentDB's own rules are the only test and the
published page is the only reading.

### P7 · a new player can get the drone tools at all

`todo` `playtest`

Never run. The mod stopped handing its two tools out on join at its `F10`, so a
player now takes them from the creative inventory or runs `/codeblock tools`.
**This is the game's check, not the mod's**: what it reads is whether a player
who installs *this package* and starts a world can reach the drone at all.

### P1 · a fresh recursive clone boots

`todo` `playtest` `partial` `target: v2.0.0`

Carries a partial from `7f649d8` on 2026-09-01: the clone half ran, the boot
half did not.

**Do:** re-run the boot half against the release tag.

## Closed

**A check listed here is done against a commit, not for good.** Its recipe is
permanent and lives in `codecube-kb`'s `references/playtests.md`, which also
says which group a change owes. Move the line back into `Tests` as a `todo`
entry the moment the code under it moves, and keep the commit and date below so
whoever re-runs it knows what they are re-reading against.

### Bugs and findings

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

- `W1` done `playtest` 2026-09-01 · a new world is flat and clean at spawn
- `W2` done `playtest` 2026-09-01 · the mapgen flags survive a world that was created with others
- `W3` done `playtest` 2026-09-01 · the world is flat far from spawn, and far from where anyone has been
- `W4` done `playtest` 2026-09-07 · the floor is there and you cannot fall through it
- `W5` done `playtest` 2026-09-07 · the wall stands, full height, all the way along
- `W6` done `playtest` 2026-09-07 · the drone's bound followed the number
- `W7` done `playtest` 2026-09-07 · an existing world is re-bounded
- `W8` done `playtest` 2026-09-07 · a player who falls through a program-made hole is put back
- `W9` done `playtest` 2026-09-07 · the place the rescue puts you is a place you can stand
- `W10` done `playtest` 2026-09-08 · the wall is a barrier you can see through, and still a wall
- `W11` done `playtest` 2026-09-22 · the floor and the wall are the game's own artwork, and the floor does not tile
- `W12` done `playtest` 2026-09-08 · a new world puts you 128 nodes above the floor
- `W13` done `playtest` 2026-09-08 · an existing world's surface moves to 128 when you open it
- `W14` done `playtest` 2026-09-08 · the rescue still knows where the surface is
- `W15` done `playtest` 2026-09-09 · the surface is one layer of grass over dirt, at the right height
- `W16` done `playtest` 2026-09-09 · no node in the world is unknown, anywhere in the column
- `L1` done `playtest` 2026-09-01 · permanent noon, no sky objects
- `L2` done `playtest` 2026-09-01 · it survives a rejoin, and it applies to a second player
- `L3` done `playtest` 2026-09-09 · permanent noon still holds when only `cc_day` is setting the sky
- `L4` done `playtest` 2026-09-09 · the sky's own colour and the fog do not move with the time of day, or with where you look
- `R1` done `playtest` 2026-09-09 · nothing is diggable
- `R2` done `playtest` 2026-09-09 · the inventory is empty and no item ever drops
- `R3` done `playtest` 2026-09-09 · no knockback
- `R4` done `playtest` 2026-09-01 · the drone can still build
- `R5` done `playtest` 2026-09-09 · the chained drop handler still hands out nothing
- `R6` done `playtest` 2026-09-01 · a bookshelf opens nothing you can use
- `R7` done `playtest` 2026-09-02 · the world does not change on its own
- `R8` done `playtest` 2026-09-09 · no node ever plays a dig animation
- `R9` done `playtest` 2026-09-09 · the drone places and removes CodeBlock's own blocks, and nothing else exists
- `P2` done `playtest` 2026-09-01 · the release archive holds only what a player needs
- `P6` done `playtest` 2026-09-22 · every form and the hotbar wear the game's own style
