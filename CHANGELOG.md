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
- [x] **BREAKING** Codecube now needs **Luanti 5.9 or newer**, up from 5.4. The world's floor and walls are written on the engine's mapgen threads, and the call that does it does not exist before 5.9
- [x] **BREAKING** the world is now a finite tray, **2048 nodes across** instead of roughly 8160. There is a wall at each edge, standing full height, and it is made of a translucent barrier rather than solid rock — the edge of the world is meant to read as a limit you can see past, not as the inside of a box. It still stops you and it still cannot be dug. Under it is a bedrock floor you cannot dig either, with nothing generated below it. **That floor is now 128 nodes beneath the surface rather than 8**, so the world is something to dig down into: there is solid stone the whole way from where you stand to the floor. You still meet the floor only where a program has cleared a shaft to it. An existing world is re-bounded to the new size when you open it, so ground beyond 1024 that you have already visited is now outside the wall. The drone shares the same limit, so it can never build where you cannot walk
- [x] **You can no longer fall out of the world.** If you end up outside it anyway - a program can `remove` a floor tile, since bedrock is an ordinary node to the drone - you are put back where you were rather than sent to the spawn point: the floor is made whole underneath you and you are stood on the first free space in that column, which is the bottom of the hole you fell down, or the top of the ground if you were clamped back inside the wall. You may land in a shaft you cannot climb out of; point the drone at its wall and program your way out. If that column is solid for 72 nodes with no room anywhere in it, you go to the spawn point instead, and the game makes sure that place is one you can stand in rather than mid-air or inside rock
- [x] Server owners can set the world's size **and the height of its surface** from the settings menu, under Content: Games → Codecube. The surface height is how much stone there is between where you stand and the bedrock floor, which stays at `y = 0` whatever it is set to
- [x] The bedrock floor and the barrier wall are drawn with the game's own textures. They used to borrow two textures from the bundled `default` mod; they are the game's own now, so nothing about how the world's edges are drawn depends on a mod that may later be removed
- [x] Server owners can change every drone limit from the settings menu, under Mods → codeblock, instead of editing the mod's source
- [x] Every bundled mod now carries its own licence, catalogued in `THIRD-PARTY-LICENSES.md`
- [x] Added `title` and `author` metadata to the bundled mods
- [x] Added CI: `scripts/check_game.sh` verifies the game assembles; `codeblock` lints and tests itself
- [x] Removed `code.lua` from the WorldEdit fork before dropping it (arbitrary Lua execution in the global namespace)
- [x] Fixed `scripts/gen_cdb_json.sh` producing different output depending on line endings
- [x] Repointed image URLs from `master` to `main`
- [x] Verified against Luanti 5.17.0
- [x] The bundled `codeblock` mod is now adopted as a tagged release rather than followed commit by commit; the game's documentation is brought up to date at the same time
- [x] Reframed the documentation: the README presents the game, its features and its settings, and points at the `codeblock` package for the programming API and the detailed instructions. The game's own record is `ROADMAP.md`, `TODO.md`, `AUDIT.md` and `PLAYTEST.md`; none of them ships to a player
- [x] The ContentDB page is now written for someone reading it on ContentDB, rather than being `README.md` verbatim. The README's badges, licence line and repository links were noise on a page the reader is already on, and its nine images - five of them tool icons used inline in the instructions - are not visible at all to anyone browsing from inside Luanti, which is where the instructions were most needed
- [x] The download from ContentDB now holds only what the game needs to run: 3.29 MB down to 1.93 MB. Hidden files and directories are excluded, which is what stops `.claude/` (993 kB), `.reports/` and `.github/` reaching players, along with the art sources, `scripts/` and the record documents. `menu/*.png` is kept - it is what the main menu reads
- [x] **The world no longer changes on its own.** Dirt you placed used to sprout grass from a neighbouring block, a grass floor quietly turned back into plain dirt wherever you built a roof over it, and a sapling grew into a tree that could overwrite what your program had put above it. None of that happens now: every block in the world is one a program placed, which is what the game always claimed and did not do
- [x] Fixed the breaking animation on nodes that cannot be broken: punching wool used to crack it through all five stages before the block stayed put. No node carries a digging group any more, so the client no longer guesses ahead of the server
- [x] Fixed errors in the log when the game starts: two unresolved node names and one deprecated field in a bundled mod
- [x] Fixed the sun showing at dawn and dusk: the sky hid the sun itself but not the sunrise glow drawn behind it
- [x] Fixed a bookshelf being a way into your own inventory. A bookshelf could be opened, a drone tool dragged out of the hotbar into a row below it, and that row is one the game otherwise keeps shut - so the tool looked lost. Nothing can be moved anywhere now, in a node or in your own inventory
- [ ] Known: right-clicking a bookshelf still opens a panel showing your own inventory. Nothing in it can be moved, so it is display only
- [ ] Known: a world you created before this release is re-bounded when you open it, but the wall is only built into ground that has not been generated yet. Where you have already been, the world simply stops at 1024 with no wall to see
- [ ] Known: the same applies to the deeper surface. A world you created before this release keeps the ground it has already generated at the old height, and only newly generated ground comes in at 128, so there is a step where the two meet
- [ ] Known: `default` supplies 106 node definitions out of ~9700 lines, and registers six always-on ABMs
- [ ] Known: nothing in CI checks `.gitattributes`, so a file added to this repository ships inside the release archive unless a rule excludes it, and nothing fails locally when one does
