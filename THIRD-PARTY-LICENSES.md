# Third-party licences

Codecube itself is AGPL-3.0-only (see `LICENSE`). It bundles the mods below,
which keep their own licences.

Most carry their licence text in their own directory. `mods/formspecs` cannot:
it is a git submodule pointing at a repository we do not control, so a file
placed there would be untracked and would disappear from any fresh clone. Its
licence is therefore reproduced in full at the end of this file.

| Mod | Licence | Copyright | Text |
|-----|---------|-----------|------|
| `codeblock` | AGPL-3.0-only | giga-turbo | `mods/codeblock/LICENSE` (submodule, carries its own) |
| `vector3` | see file | ISs25u / giga-turbo | `mods/vector3/LICENSE` (submodule, carries its own) |
| `formspecs` | MIT | 2016-2017 Leslie E. Krause | **below** — submodule cannot carry it |
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

---

## mods/formspecs — ActiveFormspecs, by Leslie E. Krause

Reproduced from the mod's own `README.txt`, since the submodule cannot carry a
licence file added by us.

```
The MIT License (MIT)

Copyright (c) 2016-2017, Leslie E. Krause

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
```
