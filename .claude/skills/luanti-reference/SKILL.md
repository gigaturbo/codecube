---
name: luanti-reference
description: Offline Luanti reference documentation — the Lua modding API, every engine setting, the Lua 5.1 manual, ContentDB's packaging rules and the vector3 library — plus the engine and Lua 5.1 behaviours that have already cost findings in these projects. Use whenever a question turns on what the API actually provides, and before writing mod code that touches the map, an entity, a formspec, metadata, a player's inventory or a translated string.
when_to_use: Any question about the Luanti Lua API, a core.* / minetest.* function, mod.conf or game.conf keys, engine settings, ContentDB packaging, Lua 5.1 semantics, or the vector3 library. Also whenever you are about to state that an API exists, is deprecated, was renamed, or takes particular arguments — and before writing map writes, entity lifecycle code, a formspec handler, a metadata read, an inventory change or a new S() key.
---

# Luanti reference

Bundled documentation for Luanti mod and game work, and the traps that the
documentation does not state. Read the files instead of recalling an API or
fetching it over the network. A local grep is faster, works offline, and cannot
come back summarised instead of quoted.

This copy lives **in the repository**, so a fresh checkout on another machine
carries it and no agent here depends on a machine-local store. There is a second
copy under `~/.claude/skills/`; when they disagree, this one is what this game's
agents actually read. `.claude/` never ships to a player — `.gitattributes`
excludes every dotted path from the release archive.

## What is here

All paths relative to this skill's directory.

| File | What it covers |
|---|---|
| `references/luanti-lua_api-5.17.0.md` | The Luanti Lua modding API. 12,785 lines — grep it, never read it whole. |
| `references/lua-5.1-manual.html` | The Lua 5.1 reference manual. The language Luanti runs. |
| `references/luanti-minetest.conf.example-5.17.0.txt` | Every engine setting with its default and description. |
| `references/contentdb-package-config.txt` | What ContentDB reads from `.conf` files, and how releases work. |
| `references/vector3-api.txt` | The `vector3` library these projects ship, generated from its own source. |

## How to grep them

Target the name, not the document. `lua_api.md` is half a megabyte, and reading
it whole wastes the context these files exist to save.

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

## Versions, and when not to trust these

The Luanti files are pinned to **5.17.0**, the release these projects target and
develop against. That is deliberate. `master` documents unreleased behaviour and
would describe functions the game cannot use.

**A pinned copy that has gone stale is worse than no copy**, because it still
looks authoritative. So:

- **A newer engine is still described as 5.17.0 here.** For anything
  version-sensitive — a function's availability, a new argument, a deprecation —
  check the live source too:
  `https://raw.githubusercontent.com/luanti-org/luanti/master/doc/lua_api.md`
- **The ContentDB page was captured 2026-08-25** and is not versioned upstream.
  Treat it as a strong hint rather than gospel when the answer matters.
- **Say which you used.** "5.17.0 says X" and "current master says X" are
  different claims.

To refresh, re-fetch each file at the tag you want and update the version here.

## When `lua_api.md` is silent, the engine source settles it

Several behaviours below appear in no version of `lua_api.md`. The C++ source is
the only authority for them:

- `src/gui/guiFormSpecMenu.cpp` — formspec geometry, which fields arrive, how a
  re-send is handled.
- `src/gui/guiButton.cpp` — how a click becomes an event.
- `src/client/game_formspec.cpp` — showing a form that is already open.

Read them at a tag, not `master`:
`https://github.com/luanti-org/luanti/blob/5.17.0/src/...`

---

# Common traps

Each of these has already been got wrong, in code that shipped or in a claim
made from memory. None of them fails a lint, and most fail silently at runtime.
Finding ids in parentheses point at the project record that holds the detail.

## Namespace, versions and packaging

- **`minetest` is not deprecated.** The namespace is `core` now, and `minetest`
  remains a permanent alias with no warning and no removal date. Do not sweep a
  file for style. What must keep the old spelling: the filename `minetest.conf`,
  and any forbidden-identifier list, which has to catch *both* aliases.
- **`min_minetest_version` / `max_minetest_version` are ContentDB fields, not
  engine ones.** They are absent from `lua_api.md`. The engine does not enforce
  them; ContentDB filters listings on them. There is no `min_luanti_version`.
- **Never set a `max_` version.** It hides the package from everyone on a current
  release, and nothing local fails.
- **`last_mod` is a `game.conf` key, not a `mod.conf` one.** Only one mod can be
  last, so spending it is a whole-game decision.
- **`disabled_settings` takes a `!` prefix to force a setting off.**
  `!creative_mode` and `enable_damage` are different kinds of entry although they
  read alike.
- **A `minetest.conf` at a game's root supplies defaults, not guarantees.** A
  player or server owner can still change every one. A restriction that matters
  belongs in a mod.
- **`formspec_version[4]` needs 5.4.** Claiming a lower floor is a false claim,
  not a courtesy.
- **ContentDB builds a release with `git archive`.** Any file without an
  `export-ignore` rule in `.gitattributes` ships to players.

## Lua 5.1 and LuaJIT, as they actually are

- **5.1 keeps what later versions removed:** `loadstring`, `setfenv`, `getfenv`,
  `unpack`, `math.pow`, `math.atan2`. It lacks `goto` (LuaJIT has it), `__pairs`,
  `__len` for tables, and integer division.
- **`0` is truthy, and so is `""`.** A callback that stops a timer or an ABM must
  return `false`. Returning `0` restarts it forever, silently.
- **You cannot yield across `pcall`.** Nothing on a coroutine's yield path may be
  wrapped in one.
- **`string.rep`'s separator argument is 5.2+.** LuaJIT honours it; plain 5.1
  ignores it. Code depending on it behaves differently under a standalone
  interpreter than in the engine.
- **`string.format` width takes at most two digits.** `%100d` raises
  `invalid option`.
- **Every string shares one metatable.** `("x"):rep(1e9)` is reachable from a
  literal even with `string` removed from a sandbox environment.
- **`collectgarbage('count')` is the Lua heap only.** A MapBlock is C++ side and
  invisible to it.
- **`os.clock` on POSIX is process CPU time**, not elapsed time. For a duration
  use `core.get_us_time()`.
- **Adding a key to a table during `pairs` is undefined.** Copy the keys first if
  the loop body can register anything.
- **A tail call does not preserve the caller's stack depth.** `error(msg, level)`
  levels have to be counted per path; no single level works for a helper reached
  from several depths.
- **Float angles do not wrap where you expect.** Accumulating
  `dir = (dir + n * pi/2) % (2*pi)` can land a hair under `2*pi`, so `%` does not
  wrap and a table keyed by exact integers misses. Round or normalise before
  using the value as a key.

## Map and nodes

- **`core.set_node` into a mapblock that is not in memory silently does
  nothing.** Call `core.load_area` first. VoxelManip paths need no such call —
  `read_from_map` emerges the region.
- **`core.load_area` does not trigger mapgen.** A load is one resident MapBlock
  plus a synchronous disk read. Measured in a running world: **~16.3 kB resident
  per mapblock**, **~1700 loads/s** served.
- **A per-mapblock memo must be scoped to the resume, not the run**, in anything
  that yields. A block resident when you checked can be gone after a yield, and
  the write is then lost with no error. (codeblock `S5`)
- **Serialising written mapblocks and pushing them to clients is charged to
  nobody.** Both land after your code reports done, and no Lua-side limit sees
  them. Never sell a limit as bounding what a large write costs the server.
- **`server_unload_unused_data_timeout` bounds when the engine *may* drop an idle
  mapblock, not when it does.** Anything keeping the block active holds it, so
  waiting out the timeout does not reproduce an unloaded-block path.
- **There is no API to unregister an ABM.** `core.registered_abms` is listed as a
  table, but only `core.registered_privileges` is documented as modifiable in
  place, which reads as a deliberate distinction. The engine registers each ABM
  by position, so emptying the table leaves registrations pointing at nothing.
  Replacing each `action` keeps the shape — undocumented, so confirm it in a
  world. (codecube `B49`)
- **`diggable = false` is server-side only.** The client predicts a dig from the
  node's groups and its own tool capabilities, so a node it believes a hand can
  break plays the cracking animation before the server refuses. Cosmetic, but it
  teaches a player that digging half-works. (codecube `B48`)
- **A node's formspec can live in its metadata, not its definition.** Overriding
  the definition then leaves the panel on every already-placed node.

## Entities, objects and item callbacks

- **`ObjectRef:remove()` takes effect at the end of the step.** `on_deactivate`
  can therefore fire *after* a replacement object exists under the same key, and
  a deferred entity can be stepped once more and spend the replacement's budget.
- **Guard that with a serial in staticdata, not by comparing `ObjectRef`s** —
  5.17.0's `lua_api.md` says nothing about `ObjectRef` identity. (codeblock
  `B29`)
- **`core.add_entity` can return nil**, typically in an unloaded area. A record
  created without its object is something that silently never steps.
- **Staticdata is a plain string.** `<serial> <name>` split on the first space is
  safe, because a player name cannot contain one.
- **`on_place` fires only with a node under the crosshair.** Aiming at sky or
  unloaded ground calls `on_secondary_use` instead — "same as `on_place` but
  called when not pointing at a node". An empty callback is a decision, and
  should carry a comment saying what the empty means. (codeblock `B38`)

## Formspecs

Most of this is visible only in `guiFormSpecMenu.cpp`.

- **A scrollbar is in the field table on every submit.** `parseScrollBar` sets
  `send = true` at parse time and `acceptInput` emits `VAL:n` unconditionally.
- **A checkbox is absent unless it was the box clicked.** `lua_api.md` reads as
  though the opposite were true for both.
- **So in one `elseif` chain, every always-sent field comes last** or is read
  before the chain. Otherwise an unrelated scrollbar swallows the real event.
  (codeblock `B37`)
- **Capture a text area's content once, before the branch chain.** Every redraw
  re-renders the area, so reading it inside a branch loses everything typed.
  (codeblock `B35`)
- **Enter in a field is `fields.key_enter_field == '<name>'`** and nothing else
  sets it. With `field_close_on_enter[name;false]` the engine calls
  `acceptInput()` without closing the form.
- **Re-sending a form that is already open rebuilds it.** An identical string
  does nothing; a changed string destroys every element and builds it again. A
  button records its press on the object, so a rebuild between mouse-down and
  mouse-up **swallows the click** — a self-refreshing panel loses roughly
  *hold ÷ period* of all clicks, and `on_close` never runs, so no handler can see
  it. Focus *is* carried across the rebuild; a press in flight is not. (codeblock
  `B47`)
- **One submission is capped at 640 kB** — `pkt_read_formspec_fields` sums every
  field name and value and drops the whole submission over it. That check arrives
  in **5.7.0**. On 5.6.0 a single field is bounded only by `LONG_STRING_MAX_LEN`,
  64 MB, so a modified client is a real route into anything a form writes.
- **In legacy coordinates a `button`'s `W` is short by a fixed 0.2 units**, and
  its `H` only shifts it down. Not in `lua_api.md`; it cannot settle a
  misalignment.
- **A `scroll_container` maps its contents into a different space and clips
  them.** An `item_image_button` inside one gets a hit area that does not match
  where it is drawn.
- **Ask which inventories a form names, not what it is a form for.** A node's
  form can name inventories other than that node's, and a restriction placed on
  the node alone then leaks. (codecube `S8`)

## Metadata, players and files

- **`get_int` cannot tell an unset key from a stored `0`.** Read an optional or a
  boolean with `get_string`, where absent is `""`. (codeblock `B5`)
- **Player meta written from `register_on_shutdown` is saved.** Observed on
  5.17.0, not documented.
- **Never clear a player's inventory — add what is missing.** And read both
  `main` *and* `craft` before deciding an item is absent, or a tool parked in the
  craft grid is duplicated on every join. This is the most damaging class of
  defect these projects have recorded. (codeblock `B39`)
- **`file:read(n)` returns nil at end of file, not `""`.** A file created and not
  yet written is exactly that.
- **Bound a player-supplied file in the read itself** — read `limit + 1` bytes
  and refuse by name when it comes back longer. Any check on the content happens
  after the read, so it protects nothing. An unbounded `read('*a')` of a 168 MB
  file took Luanti to about **14 GB resident**. (codeblock `B40`)

## Translation

- **Never build a translation key with `..`**, and never edit an `S()` key in the
  source alone — the template and every `.tr` carry it.
- **An error value handed straight through from an engine or C call reaches the
  player untranslated**, in English, and no checker sees it, because a checker
  only reads literals. (codeblock `S7`)

## Windows and tooling

- **In Windows PowerShell 5.1, `-Encoding utf8` means UTF-8 *with* a BOM.**
  Luanti's settings parser trims whitespace but not a BOM, so a script that
  rewrites `minetest.conf` that way silently kills its first setting. Write
  through `[IO.File]` with an explicit `UTF8Encoding $false`. (codeblock `B31`)
- **Appending to `minetest.conf` needs an explicit newline.** A glued
  `some_setting = xmy_flag = true` line is inert and can never be matched again
  for removal. (codeblock `B32`)

---

## The rule this exists to enforce

Before asserting that a function exists, is deprecated, was renamed, or takes
particular arguments — grep for it. A wrong claim about an API costs more than
the ten seconds the check takes, because it is repeated downstream as though it
had been checked.

And when the answer is not in these files, say so, rather than filling the gap
from memory. "`lua_api.md` at 5.17.0 does not mention it" is a useful answer.
