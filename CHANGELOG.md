# v1.0.0 (unreleased)

The bundled `codeblock` mod reached 1.0.0 with changes that break existing player
programs. See [its changelog](https://github.com/gigaturbo/codeblock/blob/master/CHANGELOG.md)
for the full list.

- [x] **BREAKING** relicensed to AGPL-3.0-only throughout; `codeblock` moved from GPL-3.0-only to match
- [x] **BREAKING** removed `max_minetest_version`, which was pinned at 5.5 and hid the game on ContentDB
- [x] Every bundled mod now carries its own licence, catalogued in `THIRD-PARTY-LICENSES.md`
- [x] Added `title` and `author` metadata to the bundled mods
- [x] Removed the bundled WorldEdit fork: `codeblock` now places its four shapes itself, so nothing needed it
- [x] Removed `code.lua` from that fork first (arbitrary Lua execution in the global namespace)
- [x] Added CI: `scripts/check_game.sh` verifies the game assembles; `codeblock` lints and tests itself
- [x] Fixed `scripts/gen_cdb_json.sh` producing different output depending on line endings
- [x] Repointed image URLs from `master` to `main`
- [x] **BREAKING** removed the `formspecs` submodule; `codeblock` no longer depends on it
- [x] Verified against Luanti 5.17.0
- [ ] Known: `default` supplies 108 node definitions out of ~9700 lines, and registers six always-on ABMs
