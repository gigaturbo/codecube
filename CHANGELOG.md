# vX.Y.Z (unreleased)

**The version number is unchosen and this heading is the only place it is
written.** `v1.0.0`, `v1.0.1` and `v1.0.2` are already tagged and pushed — the
last of them, `9d83f11`, is what a player has — so the next number is the
author's to pick. Everything below compares against `v1.0.2`, not against any
unreleased state.

**This release breaks saved player programs, and it breaks worlds you have
already played in.** Programs break because the drone's limits were rewritten
around what a program costs the server rather than around counts of calls,
because nothing bounds a shape's size or the drone's distance from home any
more, and because several API names are gone with no replacement. Worlds change
because the world is now bounded — a wall around it and a bedrock floor beneath
it — and because it is about twice as wide and sixteen times as deep under your
feet. It also needs a newer engine: **Luanti 5.9 or newer**, up from 5.4.

The bundled `codeblock` mod reached 1.0.0 with changes that break existing player
programs. See [its changelog](https://github.com/gigaturbo/codeblock/blob/master/CHANGELOG.md)
for the full list.

## Breaking

- [x] **BREAKING** the game's code is relicensed to AGPL-3.0-only, and `codeblock` moved from GPL-3.0-only to match. The game's own artwork is **CC BY-SA 4.0** rather than AGPL, so it can be reused in another game on the same share-alike terms
- [x] **BREAKING** removed `max_minetest_version`, which was pinned at 5.5 and hid the game on ContentDB
- [x] **BREAKING** removed the bundled WorldEdit fork: `codeblock` now places its four shapes itself, so nothing needed it
- [x] **BREAKING** removed the `formspecs` submodule; `codeblock` no longer depends on it
- [x] **BREAKING** on a multiplayer server, a player joining for the first time now starts at codelevel 2 rather than 4, and a single player starts at 3 rather than 4. Anyone who has already played keeps the level they have
- [x] **BREAKING** the drone limits were rewritten around what a program actually costs the server - running time, nodes written, map memory - instead of counts of calls and commands. A `minetest.conf` setting an old limit by name now warns in the log and does nothing
- [x] **BREAKING** the two lowest codelevels are paced: the drone waits between commands (250 ms at codelevel 1, 5 ms at codelevel 2) so a beginner can watch their loop happen. Codelevels 3 and 4 do not wait
- [x] **BREAKING** programs are now limited in how much of the world they hold at once. Over that limit a program is slowed down rather than stopped, since the engine frees unused map by itself
- [x] **BREAKING** nothing limits how big a shape may be or how far the drone may fly from home any more. Large shapes no longer freeze the server while they are written - a 150-node cube used to stall it for nearly half a second, and is now written in slabs - and the drone is stopped only at the edge of the world, where a build would not survive anyway
- [x] **BREAKING** Codecube now needs **Luanti 5.9 or newer**, up from 5.4. The world's floor and walls are written on the engine's mapgen threads, and the call that does it does not exist before 5.9
- [x] **BREAKING** the world is now **bounded**, and it is bigger. There is a wall at each edge, standing the full height of the world, made of a translucent barrier rather than solid rock — the edge of the world is meant to read as a limit you can see past, not as the inside of a box. It stops you and it cannot be dug. Under it is a bedrock floor at `y = 0` you cannot dig either, with nothing generated below it, and **that floor is now 128 nodes beneath the surface rather than 8**, so there is solid ground the whole way down and the world is something to dig into. You still meet the floor only where a program has cleared a shaft to it. The size setting bounds every axis, so **the field goes from about 3920 nodes on a side to about 8080** and the ceiling rises with it — about 4047 nodes up. An existing world is re-bounded when you open it, but only ground that has not been generated yet gets the wall, the floor or the new height. The drone shares the same limit, so it can never build where you cannot walk
- [x] **BREAKING** the bundled vector library is now **2.0.2**, up from 1.5, and two things a program could do quietly now stop it. Writing to one of the library's own constants - `vector.zero` and the like - is an error rather than a change everything else on the server then sees. And giving a vector constructor a bad argument is an error where it used to hand back nothing, so a program that was wrong in one line failed somewhere else entirely
- [x] **BREAKING** the game no longer bundles `default`, `wool` and `dye` from Minetest Game. Every block a program can place now comes from `codeblock` itself — 35 colours in solid, glass and lamp — so a program that named a block by an old name places nothing. The world's ground changes with them: the surface is a layer of the game's own grass over its own dirt, where it used to be Minetest Game's stone the whole way down
- [x] **BREAKING** several API names are gone with **no alias**, so a saved program using one now stops on that line: the whole `table` namespace, `random.block`, `random.plant`, `random.wool`, `table.randomizer` and the per-category colour ramps. `random.of(list)` and `random.hues()` replace the pickers and `ramp.hues` and `ramp.of` replace the ramps; `table.randomizer(t)` becomes `function() return random.of(t) end`

## Added

- [x] **You can no longer fall out of the world.** If you end up outside it anyway - a program can `remove` a floor tile, since bedrock is an ordinary node to the drone - you are put back where you were rather than sent to the spawn point: the floor is made whole underneath you and you are stood on the first free space in that column, which is the bottom of the hole you fell down, or the top of the ground if you were clamped back inside the wall. You may land in a shaft you cannot climb out of; point the drone at its wall and program your way out. If that column is solid for 72 nodes with no room anywhere in it, you go to the spawn point instead, and the game makes sure that place is one you can stand in rather than mid-air or inside rock
- [x] Server owners can set the world's size **and the height of its surface** from the settings menu, under Content: Games → Codecube. The surface height is how much ground there is between where you stand and the bedrock floor, which stays at `y = 0` whatever it is set to
- [x] Server owners can change every drone limit from the settings menu, under Mods → codeblock, instead of editing the mod's source
- [x] Every bundled mod now carries its own licence, catalogued in `THIRD-PARTY-LICENSES.md`
- [x] The game's own artwork now states its licence where you receive it: `menu/license.txt` covers the three main-menu images and `mods/cc_mapgen/license.txt` the four textures the world is made of, all seven CC BY-SA 4.0, and both are listed in `THIRD-PARTY-LICENSES.md`. The ContentDB page shows the media licence beside the code licence
- [x] Added `title` and `author` metadata to the bundled mods
- [x] Added CI: `scripts/check_game.sh` verifies the game assembles; `codeblock` lints and tests itself

## Changed

- [x] Every surface in the world is drawn with the game's own artwork: grass, dirt, the bedrock floor and the barrier wall. The floor and the wall used to borrow two textures from the bundled `default` mod, and the ground came from it entirely; nothing about how the world is drawn depends on a mod any more. All four are flat colours with a few flecks in them rather than fine-grained noise, so a large area reads as one calm surface instead of static
- [x] **The sky is now a single flat colour** rather than a gradient from a pale horizon up to a deeper blue. That is what makes permanent noon reach the sky at all - the gradient is what the engine was tinting - and it is a trade: there is no depth to the sky any more, and the sky and the haze no longer turn grey when you stand inside something you have built
- [x] Reframed the documentation: the README presents the game, its features and its settings, and points at the `codeblock` package for the programming API and the detailed instructions. The game's own record is `ROADMAP.md`, `TODO.md`, `AUDIT.md` and `PLAYTEST.md`; none of them ships to a player
- [x] The ContentDB page is now written for someone reading it on ContentDB, rather than being `README.md` verbatim. The README's badges, licence line and repository links were noise on a page the reader is already on, and its nine images - five of them tool icons used inline in the instructions - are not visible at all to anyone browsing from inside Luanti, which is where the instructions were most needed
- [x] The download from ContentDB now holds only what the game needs to run: 3.29 MB down to 1.93 MB. Hidden files and directories are excluded, which is what stops `.claude/` (993 kB), `.reports/` and `.github/` reaching players, along with the art sources, `scripts/` and the record documents. `menu/*.png` is kept - it is what the main menu reads
- [x] Verified against Luanti 5.17.0

## Removed

- [x] Removed the bundled `default`, `wool` and `dye` mods from Minetest Game. They were there for their block definitions and `codeblock` now brings its own, so they supplied nothing a player could reach: about 9,700 lines of code, six always-on world-changing rules, 101 craft recipes and a set of tools, none of it usable in this game. The download is smaller again for it
- [x] Removed `code.lua` from the WorldEdit fork before dropping it (arbitrary Lua execution in the global namespace)

## Fixed

- [x] **The world no longer changes on its own.** Dirt you placed used to sprout grass from a neighbouring block, a grass floor quietly turned back into plain dirt wherever you built a roof over it, and a sapling grew into a tree that could overwrite what your program had put above it. None of that happens now: every block in the world is one a program placed, which is what the game always claimed and did not do
- [x] Fixed the breaking animation on nodes that cannot be broken: punching wool used to crack it through all five stages before the block stayed put. No node carries a digging group any more, so the client no longer guesses ahead of the server
- [x] Fixed errors in the log when the game starts: two unresolved node names and one deprecated field in a bundled mod
- [x] Fixed the sun showing at dawn and dusk: the sky hid the sun itself but not the sunrise glow drawn behind it
- [x] **Fixed the sky still changing with the time of day.** Permanent noon held the light level and hid the sun, moon, stars and clouds, but the sky's own colour and the haze over distant ground were still the engine's, so the horizon carried a sunrise tint and shifted as you turned on the spot. A new world started at that tinted hour, so it was the game's default look rather than something you had to set the time to see
- [x] Fixed a way into your own inventory. A bookshelf from the old bundled blocks could be opened, a drone tool dragged out of the hotbar into a row below it, and that row is one the game otherwise keeps shut - so the tool looked lost. Nothing can be moved anywhere now, in a node or in your own inventory, and no block in the game opens a panel of its own any more
- [x] **A player program can no longer reach the vector library the rest of the server uses.** Before 2.0.2 the library handed the same table of methods back off every vector it made, so a program that replaced one could replace it for everything on the server that works with vectors. `codeblock` warned about the old library in the log on every start; the warning is gone with the cause
- [x] Fixed a way to hang the server from a program: asking the vector library for a random point exactly on the surface of a circle, disk, sphere or ball sent it looking in a space with nothing in it, for ever, and the server stopped with it
- [x] Fixed `scripts/gen_cdb_json.sh` producing different output depending on line endings
- [x] Repointed image URLs from `master` to `main`

## Known limitations

- [ ] Known: a world you created before this release is re-bounded when you open it, but the wall and the floor are only built into ground that has not been generated yet. Where you have already been, the world simply stops where it used to, with no wall to see and no bedrock under it
- [ ] Known: the same applies to the deeper surface. A world you created before this release keeps the ground it has already generated at the old height, and only newly generated ground comes in at 128, so there is a step where the two meet — and the same for its material: ground you have already generated stays the stone it was made of
- [ ] Known: nothing in CI checks `.gitattributes`, so a file added to this repository ships inside the release archive unless a rule excludes it, and nothing fails locally when one does
