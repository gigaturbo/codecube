# v1.0.0 (unreleased)

Major version: the bundled `codeblock` mod reached 1.0.0 with changes that break
existing player programs. See
[codeblock's changelog](https://github.com/gigaturbo/codeblock/blob/master/CHANGELOG.md)
for the full list — the highlights that affect saved programs are wool names
losing their `wool_` prefix, `color()` clamping instead of wrapping, and API
names becoming read-only.

## Breaking

- **Relicensed from a mixed state to AGPL-3.0-only throughout.** The game was
  already AGPLv3 and cannot be anything else while it vendors WorldEdit, so
  `codeblock` moved from GPL-3.0-only to match. Every first-party module now
  carries a licence file, and so do the vendored WorldEdit and formspecs copies.
- `max_minetest_version` removed. It was pinned at 5.5, which the engine never
  enforced but ContentDB filters on, so the game read as incompatible to anyone
  on a current release. `min_minetest_version` stays at 5.4.

## Added

- Continuous integration, split along the line that matters: this repository
  checks that the game *assembles* (`scripts/check_game.sh` — submodules present,
  every mod declaring a name matching its directory, no duplicate names, every
  declared dependency actually shipped, licences in place, `.cdb.json` not stale),
  while `codeblock` owns linting and testing its own code.
- `title` and `author` metadata across the bundled mods.

## Fixed

- The WorldEdit fork no longer ships `code.lua`, which provided arbitrary Lua
  execution in the global namespace. Nothing could reach it, but it had no place
  in a game whose purpose is running untrusted player code.
- `scripts/gen_cdb_json.sh` produced different output depending on the checkout's
  line endings, so `.cdb.json` differed by whoever last ran it.
- Image URLs point at `main` rather than `master`.

## Known limitations

- The bundled WorldEdit fork is mostly unreachable: of 2,299 lines, 448 are used.
  Trimming it, or replacing the four shapes it provides with direct VoxelManip
  calls, is still to do.
- The editor depends on `formspecs`, an unmaintained third-party mod that patches
  the engine namespace. Replacing it is the next planned change.
- `default` supplies 108 node definitions out of 9,744 lines, and its unused
  parts still register six always-on ABMs.

## Verified against

Luanti 5.17.0.
