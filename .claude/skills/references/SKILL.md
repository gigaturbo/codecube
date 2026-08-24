---
name: references
description: Offline reference documentation for Luanti, Lua 5.1 and ContentDB, bundled as files. Use whenever a question turns on what an API actually provides — whether a function exists, its exact signature, whether something is deprecated, what a config key means, what ContentDB reads — instead of answering from memory or fetching over the network.
when_to_use: Any question about the Luanti Lua API, a core.* / minetest.* function, mod.conf or game.conf keys, ContentDB packaging, Lua 5.1 semantics, or the vector3 library. Also whenever you are about to state that an API exists, is deprecated, was renamed, or takes particular arguments.
---

# Reference documentation

Bundled copies of the documentation this project depends on. Read them instead of
recalling an API or fetching it over the network — a local grep is faster, works
offline, and cannot come back summarised instead of quoted.

## What is here

All paths relative to this skill's directory.

| File | What it covers |
|---|---|
| `references/luanti-lua_api-5.17.0.md` | The Luanti Lua modding API. 12,785 lines — grep it, do not read it whole. |
| `references/lua-5.1-manual.html` | The Lua 5.1 reference manual. The language Luanti runs. |
| `references/luanti-minetest.conf.example-5.17.0.txt` | Every engine setting with its default and description. |
| `references/contentdb-package-config.txt` | What ContentDB reads from `.conf` files, and how releases work. |
| `references/vector3-api.txt` | The vector library this game ships, generated from its own source. |

## Versions, and when not to trust these

The Luanti files are pinned to **5.17.0**, the release this project targets and
develops against. That is deliberate: `master` documents unreleased behaviour and
would describe functions the game cannot use.

**A pinned copy that has gone stale is worse than no copy**, because it still
looks authoritative. So:

- If the engine in use is newer than 5.17.0, these still describe 5.17.0. For
  anything version-sensitive — a function's availability, a new argument, a
  deprecation — check the live source as well:
  `https://raw.githubusercontent.com/luanti-org/luanti/master/doc/lua_api.md`
- The ContentDB page was captured 2026-08-25 and is not versioned upstream. Treat
  it as a strong hint rather than gospel if the answer matters.
- Say which you used. "5.17.0 says X" and "current master says X" are different
  claims.

To refresh, re-fetch each file from the URL in the table above at the tag you
want, and update the version in this document.

## How to use them

Target the name, not the document. `lua_api.md` is half a megabyte; reading it
whole wastes the context these files exist to save.

```
grep -n "bulk_set_node" references/luanti-lua_api-5.17.0.md
grep -n "^\* \`core.override_item" -A 10 references/luanti-lua_api-5.17.0.md
grep -n "on_deactivate" references/luanti-lua_api-5.17.0.md
```

For settings, the example config gives the default and the units, which the API
document does not:

```
grep -n "dedicated_server_step" -A 4 references/luanti-minetest.conf.example-5.17.0.txt
```

## Things these files settle that memory gets wrong

Recorded because each one has actually been got wrong here:

- **`minetest` is not deprecated.** The namespace is `core` now, and `minetest`
  remains a permanent alias. The API document says so explicitly.
- **`min_minetest_version` / `max_minetest_version` are not in `lua_api.md`.**
  They are ContentDB fields, not engine ones, and the engine does not enforce
  them — a game with `max_minetest_version = 5.5` runs fine on 5.17 but is
  filtered out of ContentDB listings. There is no `min_luanti_version`.
- **Lua 5.1 keeps what later versions removed**: `loadstring`, `setfenv`,
  `getfenv`, `unpack`, `math.pow`, `math.atan2`. It lacks `goto` (LuaJIT has it),
  `__pairs`, and `__len` for tables.
- **`string.rep`'s separator argument is 5.2+.** LuaJIT honours it; plain Lua 5.1
  ignores it. Code depending on it behaves differently between the interpreter CI
  uses and the one the game runs.
- **`string.format` cannot pad arbitrarily.** The format scanner takes at most
  two digits of width, so `%100d` raises `invalid option`.

## The rule this exists to enforce

Before asserting that a function exists, is deprecated, was renamed, or takes
particular arguments — grep for it. A wrong claim about an API costs more than
the ten seconds the check takes, because it is repeated downstream as though it
were checked.
