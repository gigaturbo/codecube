# Third-party licences

Codecube itself is AGPL-3.0-only (see `LICENSE`). It bundles the mods below,
which keep their own licences.

Each carries its licence text in its own directory.

| Mod | Licence | Copyright | Text |
|-----|---------|-----------|------|
| `codeblock` | AGPL-3.0-only | giga-turbo | `mods/codeblock/LICENSE` (submodule, carries its own) |
| `vector3` | see file | ISs25u / giga-turbo | `mods/vector3/LICENSE` (submodule, carries its own) |
| `worldedit` | AGPL-3.0 | 2012 sfan5, Anthony Zhang, Brett O'Donnell, ShadowNinja | `mods/worldedit/LICENSE` |
| `default` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/default/license.txt` |
| `dye` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/dye/license.txt` |
| `wool` | LGPL-2.1+ / CC BY-SA 3.0 | Minetest Game contributors | `mods/wool/license.txt` |
| `cc_day`, `cc_mapgen`, `cc_security` | AGPL-3.0-only | giga-turbo | each mod's `license.txt` |

## Notes on the bundled copies

`mods/worldedit` is a **reduced fork**. Its chat commands were already absent
when it was vendored, and `code.lua` — which executed arbitrary Lua in the global
namespace — has been removed. Only `common.lua` and `primitives.lua` are reachable
from the game, supplying the four shape functions `codeblock` uses.

`mods/default`, `mods/dye` and `mods/wool` are copies from Minetest Game. Of
`default`, only its node definitions are used: 108 of them, out of roughly 9,700
lines.

`mods/formspecs` (ActiveFormspecs, MIT, by Leslie E. Krause) was removed in
v1.0.0. Its formspec session handling is now `mods/codeblock/lib/forms.lua`,
built on `core.show_formspec` directly. It is recorded here only so the history
is legible; nothing in the game bundles it any more.
