# Third-party licences

Codecube itself is AGPL-3.0-only (see `LICENSE`). It bundles the mods below,
which keep their own licences.

Each carries its licence text in its own directory.

| Mod | Licence | Copyright | Text |
|-----|---------|-----------|------|
| `codeblock` | AGPL-3.0-only | giga-turbo | `mods/codeblock/LICENSE` (submodule, carries its own) |
| `vector3` | see file | ISs25u / giga-turbo | `mods/vector3/LICENSE` (submodule, carries its own) |
| `default` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/default/license.txt` |
| `dye` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/dye/license.txt` |
| `wool` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/wool/license.txt` |
| `cc_day`, `cc_mapgen`, `cc_security` | AGPL-3.0-only | giga-turbo | each mod's `license.txt` |

## Media

Code and media are licensed separately by convention, and a licence file covering
source code does not cover the textures beside it. This table is the game's own
media; the vendored mods' textures are covered by the *License of media* sections
of their own `license.txt` files, listed above.

| Files | Licence | Copyright | Text |
|-------|---------|-----------|------|
| `mods/cc_mapgen/textures/cc_mapgen_bedrock.png`, `cc_mapgen_barrier.png` | AGPL-3.0-only | giga-turbo | `mods/cc_mapgen/license.txt`, *License of media* |
| `menu/background.png`, `menu/header.png`, `menu/icon.png` | **not stated** | giga-turbo | — (C22) |

Two things about that table are open, and both are the author's to settle.

**The two `cc_mapgen` textures are AGPL-3.0-only, and that is reversible.** They
were licensed with the code on 2026-09-07 to keep Codecube single-licence, so
that the `cc_*` row above stays true without qualification. The convention for
Luanti game art is **CC BY-SA 4.0**, which would let other games reuse them; AGPL
is a stronger restriction than the game needs. Changing it is two lines in
`mods/cc_mapgen/license.txt` plus a `media_license` field in `.cdb.json`.
`ROADMAP.md` `G7` carries the reasoning.

**The three menu images ship to every player with no licence stated anywhere**,
and that is `C22`, open. `P2` lists all three by name in the release archive, and
`.gitattributes` keeps them there deliberately, because `menu/*.png` is what the
main menu reads. No `license.txt` names them, this document had no row for them
until now, and `.cdb.json` carries `license` and **no `media_license`** although
ContentDB's package config accepts one. The root `LICENSE` plausibly covers the
whole repository, so this is an unstated licence rather than a legal void — but
every other piece of media in the game answers the question explicitly, and these
do not. Closing it needs a licence statement, this row filled in, and a
`media_license` in `scripts/gen_cdb_json.sh`. See `AUDIT.md` `C22`.

## Notes on the bundled copies

`mods/worldedit` (a reduced WorldEdit fork, AGPL-3.0, 2012 sfan5, Anthony Zhang,
Brett O'Donnell, ShadowNinja) was removed in v1.0.0. Only four shape functions
were ever reachable from it; they are now `mods/codeblock/lib/shapes.lua`. Listed
here so the history stays legible — nothing in the game bundles it any more.

`mods/default`, `mods/dye` and `mods/wool` are copies from Minetest Game. Of
`default`, only its node definitions are reachable: **106** of them, out of 9,744
lines. `wool` supplies 15 more and `dye` is there because `wool` requires it —
nothing in the game names a dye. The count was 108 here until it was checked by
extracting every `default:` and `wool:` name from CodeBlock's palette and sorting
it unique; the audit records that correction under `A13`.

`mods/formspecs` (ActiveFormspecs, MIT, by Leslie E. Krause) was removed in
v1.0.0. Its formspec session handling is now `mods/codeblock/lib/forms.lua`,
built on `core.show_formspec` directly. It is recorded here only so the history
is legible; nothing in the game bundles it any more.
