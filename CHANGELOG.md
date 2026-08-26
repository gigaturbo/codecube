# v1.0.0 (unreleased)

The bundled `codeblock` mod reached 1.0.0 with changes that break existing player
programs. See [its changelog](https://github.com/gigaturbo/codeblock/blob/master/CHANGELOG.md)
for the full list.

- [x] **BREAKING** relicensed to AGPL-3.0-only throughout; `codeblock` moved from GPL-3.0-only to match
- [x] **BREAKING** removed `max_minetest_version`, which was pinned at 5.5 and hid the game on ContentDB
- [x] **BREAKING** removed the bundled WorldEdit fork: `codeblock` now places its four shapes itself, so nothing needed it
- [x] **BREAKING** removed the `formspecs` submodule; `codeblock` no longer depends on it
- [x] **BREAKING** on a multiplayer server, a player joining for the first time now starts at codelevel 2 rather than 4. Singleplayer is unchanged at 4, and anyone who has already played keeps the level they have
- [x] **BREAKING** the drone limits were rewritten around what a program actually costs the server - running time, nodes written, map memory - instead of counts of calls and commands. A `minetest.conf` setting an old limit by name now warns in the log and does nothing
- [x] **BREAKING** the two lowest codelevels are paced: the drone waits between commands (250 ms at codelevel 1, 15 ms at codelevel 2) so a beginner can watch their loop happen. Codelevels 3 and 4 do not wait
- [x] **BREAKING** programs are now limited in how much of the world they hold at once. Over that limit a program is slowed down rather than stopped, since the engine frees unused map by itself
- [x] **BREAKING** nothing limits how big a shape may be or how far the drone may fly from home any more. Large shapes no longer freeze the server while they are written - a 150-node cube used to stall it for nearly half a second, and is now written in slabs - and the drone is stopped only at the edge of the world, where a build would not survive anyway
- [x] Server owners can change every drone limit from the settings menu, under Mods → codeblock, instead of editing the mod's source
- [x] Every bundled mod now carries its own licence, catalogued in `THIRD-PARTY-LICENSES.md`
- [x] Added `title` and `author` metadata to the bundled mods
- [x] Added CI: `scripts/check_game.sh` verifies the game assembles; `codeblock` lints and tests itself
- [x] Removed `code.lua` from the WorldEdit fork before dropping it (arbitrary Lua execution in the global namespace)
- [x] Fixed `scripts/gen_cdb_json.sh` producing different output depending on line endings
- [x] Repointed image URLs from `master` to `main`
- [x] Verified against Luanti 5.17.0
- [ ] Known: `default` supplies 108 node definitions out of ~9700 lines, and registers six always-on ABMs
