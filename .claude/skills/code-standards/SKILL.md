---
name: code-standards
description: The standards and the traps for writing the Codecube game's own Lua and configuration — the game is 177 lines of Lua across three mods, so the craft here is mostly deciding what not to add and what belongs upstream in CodeBlock instead. Covers the restriction boundary cc_security holds, the Luanti behaviours that have already cost findings here, an index of the guards a change would re-break, and what a change drags with it. Use before editing anything under mods/cc_*, scripts/ or the game's configuration, and when auditing them.
when_to_use: Before editing mods/cc_day, mods/cc_mapgen, mods/cc_security, scripts/, game.conf, minetest.conf, .luacheckrc or .gitattributes; when auditing the game's own code; when deciding whether a change belongs to the game or to the mod; and whenever you are about to state that an engine function exists or behaves in a particular way.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Writing code in Codecube

**This game is 177 lines of Lua, and the craft here is almost entirely deciding
what not to add.** Everything a player *does* belongs upstream in CodeBlock; what
is left is the world, the light, the restrictions, the packaging, and a handful
of engine behaviours that have each already cost a finding.

What the game is, what is in `mods/`, and the submodule policy are in `CLAUDE.md`
and are not restated here. The editing, coding and helper conventions are in
`~/.claude/CLAUDE.md`, they apply here unchanged, and they are not restated
either.

## The first question is always *whose is this*

The game owns **177 lines of Lua**, in four files — counted as lines that are
neither blank nor a comment, recounted at `d6e4a12` on 2026-09-08 with the whole
of `G7` in it, which is how the numbers below can be re-derived rather than
trusted. Counting blanks and comments too it is 464 lines, so most of what is
here is prose about why:

| Mod | Lines | What it does |
|---|---|---|
| `cc_day` | 7 | Holds the world at noon, no sky objects |
| `cc_mapgen` | 32 + 37 | `init.lua` sets `mg_flags`, the world's size and its depth, and registers the two nodes the bounds are made of — `cc_mapgen:bedrock`, the floor at `y = 0`, and `cc_mapgen:barrier`, a translucent `glasslike` wall; `mapgen_env.lua` writes both on the emerge threads. It is also the only `cc_*` mod with media: two 16×16 textures in `textures/`, licensed in its own `license.txt` |
| `cc_security` | 101 | Nothing diggable, no drops, no knockback, no inventory form, nothing growing or spreading, and the world-box clamp with the column rescue and its spawn fallback |

Everything a player *does* — the sandbox, the drone, the editor, the API and its
limits — is CodeBlock's, upstream, in its own repository. So a feature-shaped
idea arriving here is usually a change to the mod that has been misfiled, and
the cheapest thing you can do is say so before writing anything.

It belongs to the **game** when it is about the world, the light, what a player
may break or place, what a server owner gets by default, packaging, or the
presentation of the package. It belongs to the **mod** when it is about
programming the drone. `TODO.md` already sorts this way — *"teleport function? —
game-side, a chat command rather than a drone command"* is the triage done
correctly.

**The game is thin on purpose, and a thin game is the design, not a gap.** Adding
to `cc_*` needs a reason that a mod change could not serve.

## The restriction boundary

`cc_security` is what makes a Codecube world read-only to a player's hands: the
drone builds, the player does not. It is 101 lines and every one of them is
load-bearing.

**One rule in it writes to the map, and only one**: the clamp makes the rescue
destination standable before moving a player, because a program is free to have
dug or filled any column and a destination the player cannot stand in is not a
rescue. Since `60259dd` the destination is the player's **own** column — clamped
inside the wall, one bedrock node written at `y = 0` if the floor there will not
hold them, then a scan up for the first height at which both nodes they occupy
are clear. Nothing is cleared on that path; the spawn fallback, `repair_spawn()`,
is the only place that writes air, and it is reached only when the scan finds no
room in 64 nodes above `mgflat_ground_level`. Anything else added here should
deny, not write. (`B50`)

Five questions for any change to it, or to `minetest.conf` and `game.conf`:

1. **Can a player dig, place or drop a node without the drone?** The three
   guards are the `diggable = false` override on every registered node, a
   `handle_node_drops` that hands out nothing, and an empty inventory formspec.
   Removing any one is a change to what the game *is*.
2. **Does it override an engine function by assignment?** `cc_security` replaces
   `handle_node_drops` and `calculate_knockback`, which is why `luacheck` code
   `122` is off for that file and why `last_mod = cc_security` is spent in
   `game.conf` — a **`game.conf` key, not a `mod.conf` one**, only one mod can
   hold it, and it is already spent on this. Read **`A8`** before re-arguing any
   of it, including the chaining and the load order.
3. **Does it depend on load order?** The node override runs in
   `register_on_mods_loaded` because it has to see every mod's registrations. A
   guard moved earlier silently covers fewer nodes, and nothing fails.
4. **Does it grant a privilege?** `default_privs` in `minetest.conf` is
   `interact, shout, fast` — `fly` and `noclip` were dropped on 2026-09-02, which
   is why `PLAYTEST.md`'s `W3` tells you to teleport rather than fly. Every entry
   there is a decision about what an unknown player on someone's server can do,
   and it is the author's, not yours.
5. **Does CodeBlock already do it?** `cc_day` duplicates a block the mod already
   runs (**finding `A7`**). Two mods setting the same thing is not twice as safe;
   it is one of them being wrong later and nobody noticing which.

## The Luanti and Lua facts that hold here

Use the **`luanti-reference`** skill before stating that a `core.*` function
exists, is deprecated, or takes particular arguments. It bundles `lua_api.md`,
the Lua 5.1 manual, ContentDB's own rules and the engine behaviours that have
already cost findings. Answering from memory is how findings get here.

### The language, and what it is called

- `minetest` is a permanent alias for `core` and is **not** deprecated. Leave the
  existing spelling alone rather than sweeping a two-line file.
- Lua 5.1 / LuaJIT: `loadstring`, `setfenv`, `math.pow`, `math.atan2` all exist;
  **`0` is truthy**, and so is `""`; there is no `__pairs`, no `__len`, no
  integer division; you cannot yield across `pcall`.

### `game.conf` and `minetest.conf` keys

- `min_minetest_version` / `max_minetest_version` in `game.conf` are read by
  **ContentDB, not enforced by the engine**. Never set a `max_` — it hides a
  working game from everyone on a current release, and nothing local fails.
  `check_game.sh` fails the build on a reinstated one (**`C1`**'s counterpart).
- **`disabled_settings` in `game.conf` hides each setting it names and
  initialises it to `false`; a `!` prefix initialises it to `true` instead.** So
  this game's `!creative_mode, enable_damage` turns creative mode *on* and damage
  *off*, and it is correct as written — the two entries read alike and mean
  opposite things. Only `enable_damage`, `creative_mode` and `enable_server` are
  supported, and `!` does not work for `enable_server`.
- `minetest.conf` at the game root supplies **defaults a player or server owner
  can still change**. It is presentation and courtesy, never a guarantee; a
  restriction that matters belongs in `cc_security`.
- **The engine floor is 5.9 and unguarded** — `min_minetest_version` in
  `game.conf`, and the author has ruled against buying compatibility with a
  guarded call. So the bundled 5.17.0 `lua_api.md` proves a function exists
  *today*, not that the game may call it: check the same name at
  `https://raw.githubusercontent.com/luanti-org/luanti/5.9.0/doc/lua_api.md`
  before using it. `core.settings:get_pos` is 5.10 and later; the spelling that
  works at the floor is `core.setting_get_pos(name)`, deprecated at 5.17 but
  present and documented.

### Engine behaviours, each of which has already cost something here

- **`core.get_mapgen_edges()` is safe to call at mod load time**, and its result
  is the right one for the game because `last_mod = cc_security` puts every
  `cc_*` mod's `set_mapgen_setting` before it. The engine reads a *copy* of the
  mapgen params for this call — `l_mapgen.cpp` says so in a comment, at 5.9.0 and
  at 5.17.0 alike — so unlike `makeMapgenParams` it does not freeze mapgen
  settings against later mods.
- **`core.get_spawn_level` cannot be called at mod load time.** It goes through
  the emerge manager, and mapgens initialise *after* every mod has loaded, so it
  returns `1` and writes a line to `errorstream` on every boot. The height a
  new player actually spawns at comes from
  `core.get_mapgen_setting("mgflat_ground_level")`, and it is a string. **The
  engine's default is 8; this game's is 128**, set in `minetest.conf` and forced
  by `cc_mapgen`. This cost a defect in `G6`'s clamp before it shipped: a
  fallback spawn written as `y = 1` would have put a rescued player inside solid
  stone, because the bedrock plane at `y = 0` is the whole surface height under
  the ground a player walks on.
- **Every `mgflat_*` parameter is stored per world in `map_meta.txt`**, exactly
  as `mapgen_limit` is — `MapgenFlatParams::writeParams` writes the lot, and a
  real world's file carries every one. So `minetest.conf` alone changes new
  worlds only, and an existing world silently keeps its old value. The third
  argument to `core.set_mapgen_setting` is what reaches it, and it is generic:
  `MapSettingsManager::setMapSetting` writes the name straight into the
  map-meta settings object, so `override_meta` works for any mapgen setting and
  not only for the ones in `MapgenParams`.
- **`walkable` defaults to true, and the Lua definition table keeps the
  omission.** The engine applies the default when it reads the definition, so
  `core.registered_nodes[name].walkable` is `nil` for ordinary solid nodes such
  as `default:stone`. Test `def.walkable ~= false`; testing it for truthiness
  reads every solid node as walk-through.
- **`core.get_node` answers `ignore` for an unloaded mapblock**, which is
  indistinguishable from a real node unless you look at the name. Use
  `core.get_node_or_nil`, treat `ignore` as "no answer" in a loaded block too,
  and `core.load_area` first when you intend to write — `core.set_node` into a
  non-resident block silently does nothing. All three spellings exist at the
  5.9 floor. (`B50`)
- **The world's surface is stone.** `mg_flags` carries `nobiomes`, so `mgflat`
  has no top or filler node and fills stone to `mgflat_ground_level`. There is no
  dirt and no grass in a Codecube world until a program places some — `B49` is
  about what `default` *registers*, not about what the mapgen produces.
- **`glasslike_framed` is a trap for a see-through wall.** It draws its faces
  from the *second* tile, not the first, and on a one-node-thick wall it hides
  every frame edge lying in the plane of the wall, keeping only the four that run
  through its thickness — seen end-on, so a dot at each node corner rather than a
  grid of lines (`content_mapblock.cpp`, `drawGlasslikeFramedNode`, at 5.9.0).
  Vendored `default_obsidian_glass_detail.png` is alpha 0 in every pixel, so
  those faces draw nothing at all and the wall comes out near-invisible: the
  `airlike` outcome, reached by accident. Plain `glasslike` puts tile 0 on every
  face whose neighbour differs, so a texture that is a dark one-pixel border
  around a transparent centre gives a wall a player can see. `cc_mapgen:barrier`
  uses that drawtype and `cc_mapgen_barrier.png`, its own texture, for that
  reason; `cc_mapgen` no longer borrows anything from `default`.
- **`use_texture_alpha` takes a string** — `"opaque"`, `"clip"`, `"blend"`, since
  5.4.0. The boolean form is deprecated and costs a line in the boot log, which
  `B19` and `B24` exist to keep clean. The default is `"clip"` for every drawtype
  except normal, liquid, flowingliquid, mesh and nodebox.

## The vendored mods are not ours

`default`, `dye` and `wool` come from Minetest Game and exist for their node
definitions. They are excluded from `.luacheckrc` deliberately and are **not to
be restyled, linted or refactored**. The one sanctioned change is **`A13`**:
trimming `default` down to the nodes the game actually uses — 9,744 lines for 106
node definitions — and that is a *deletion* job. It closes `B19` and `B24` with
it. Deleting a node the palette tables in the mod's config name would break the
drone, so check the names before removing anything.

`mods/codeblock` and `mods/vector3` are submodules: pinned dependencies, never
working copies. Do not edit, commit to, or lint them from this tree.

## What a change drags with it

**Nothing fails when one of these is missed** — that is what makes them worth a
table.

| A change to | drags | checked by |
|---|---|---|
| any file added to the tree | an `export-ignore` line in `.gitattributes`, or it ships to a player | nothing. ContentDB builds the release with `git archive` and no CI reads that file (`C15`) |
| a new mod under `mods/` | `name` in `mod.conf` matching the directory, a licence file or a `THIRD-PARTY-LICENSES.md` entry, an `.luacheckrc` exclude if it is not ours | `scripts/check_game.sh` |
| `CONTENTDB.md` | `.cdb.json`, regenerated with `bash scripts/gen_cdb_json.sh` — never hand-edited | `check_game.sh` diffs it, CRs stripped |
| a `game.conf` key | ContentDB's reading of it, and `check_game.sh`'s expectations | `check_game.sh`, for `title` and `max_minetest_version` only |
| what a player sees or may do | `README.md` and `CONTENTDB.md` if it is player-facing | nothing |
| behaviour in a running world | a `PLAYTEST.md` entry — nothing else here reaches it | nothing. `project-manager` writes it |
| a finding fixed | its state and commit in `AUDIT.md` | nothing. Report it; `project-manager` files it |

Regenerating `.cdb.json` is part of the change, not a follow-up. The generator's
header holds ContentDB's page rules and is the thing to read before adding to
`CONTENTDB.md` — the long description is not a README, and using one as the other
is what `C20` was.

## Comments

A few lines saying what a file does, plus anything genuinely non-obvious: a
constraint that would be re-broken if forgotten, a load-order dependency, a
finding id as a short reference. Never the history of what the code replaced.

In a six-line file, a comment longer than the code is usually the file being in
the wrong project.

## Before handing the change back

```bash
bash scripts/check_game.sh
wsl bash -lc 'cd /mnt/c/Users/lacba/PRogrammation/codecube && luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes'
```

**Read the output, not the exit code** — `$?` does not survive this machine's WSL
layer. Green is `all game integration checks passed` and luacheck silent.
`check_game.sh` regenerates `.cdb.json` to compare it and restores it, so
`git status` should be no dirtier afterwards than before; check rather than
assume.

The gates and the CI lookup are the **`run-checks`** skill's, and `test-agent`
owns them.

**Make a new check fail once**, against a deliberately broken input, before
trusting it. A check that cannot fail is indistinguishable from one that passes.
`check_game.sh` earned its place that way — a reinstated version ceiling, a
dangling `depends` and a stale `.cdb.json` were each injected, and each was
caught. Anything added to it gets the same treatment, and the injection is
reverted before the change is handed back.

Then say plainly, in the reply: which gates ran and what they printed; that the
game **has no test suite**, so nothing you ran demonstrates behaviour; what
therefore needs a `PLAYTEST.md` entry; and any defect found in code you did not
write, so it can get a finding id.

## The guards, and where each is written

Every row is an invariant a plausible change would re-break with nothing
failing. The reasoning is in the finding, or in the comment beside the code —
this is an index, not a second copy of either.

| Guard | Finding | Where it is written |
|---|---|---|
| `last_mod = cc_security`, so the two engine-function replacements survive, and so every `cc_*` mod's `set_mapgen_setting` runs before `cc_security` reads the values back | `A8` | `game.conf` |
| `disabled_settings = !creative_mode, enable_damage` — creative on, damage off; the `!` is not a typo | — | `game.conf` |
| The node override pass runs in `register_on_mods_loaded`, so it sees every mod's registrations; moved earlier it silently covers fewer nodes | — | `cc_security/init.lua` |
| `handle_node_drops` chains to the captured handler with an empty list; `calculate_knockback` is replaced outright and deliberately not chained | `A8` | `cc_security/init.lua`, `.luacheckrc` (`122`) |
| The six digging groups are stripped from every node as well as `diggable = false`, because `diggable` is server-side only and the client predicts a dig from groups; every other group is kept | `B48` | `cc_security/init.lua` |
| `never()` returns `false`, not `deny()`'s `0` — a truthy return restarts a node timer | `B49` | `cc_security/init.lua` |
| Each ABM's `action` is replaced with a no-op and `registered_abms` is never cleared, since the engine registers each by position | `B49` | `cc_security/init.lua` |
| `register_allow_player_inventory_action` and the three `allow_metadata_inventory_*` denials, because a node's own formspec reaches around the blanked inventory | `S8` | `cc_security/init.lua` |
| `walkable()` returns `true`, `false` or `nil`, and every caller compares against a literal — `walkable` defaults to true and definitions omit it, and an unanswerable node is unusable in both directions | `B50` | `cc_security/init.lua` |
| `get_node_or_nil`, never `get_node`, and `load_area` before every read and every write in the rescue | `B50` | `cc_security/init.lua` |
| The rescue is the one place this game writes to the map; `repair_spawn()` is the one place it writes air. Everything else here denies | `B50` | `cc_security/init.lua` |
| `p.y < 0` and not `<= 0` — feet on the exposed floor read `0.5` | `B50` | `cc_security/init.lua` |
| The world box comes from `get_mapgen_edges()`, not from `mapgen_limit`: only mapchunks wholly inside the limit are generated | `B50` | `cc_security/init.lua`, `cc_mapgen/mapgen_env.lua` |
| The rescue height comes from `get_mapgen_setting("mgflat_ground_level")`, never `get_spawn_level`, and its fallback is the game's 128 and not the engine's 8 | `B50` | `cc_security/init.lua` |
| `set_mapgen_setting(..., true)` on both `mapgen_limit` and `mgflat_ground_level` — the engine stores every mapgen setting per world in `map_meta.txt`, so without the force an existing world keeps its old value | — | `cc_mapgen/init.lua` |
| `cc_mapgen:barrier` is plain `glasslike` — not `glasslike_framed`, which draws from a second tile this node does not have, and not `glasslike_framed_optional`, whose look follows a client setting | — | `cc_mapgen/init.lua` |
| `paramtype = "light"` and `sunlight_propagates` are a pair: `light_propagates` is derived from `paramtype`, which defaults to `"none"`, so a see-through wall without them shadows for no visible reason | — | `cc_mapgen/init.lua` |
| `pointable = false` is deliberately *not* set on the barrier — the client alone honours it, and pointing through would let a player place a node on its far side | — | `cc_mapgen/init.lua` |
| `use_texture_alpha` takes the string form; the boolean is deprecated and costs a boot-log line | `B19`, `B24` | `cc_mapgen/init.lua` |
| Neither bounds node carries a dig group, for the same reason as the override pass | `B48` | `cc_mapgen/init.lua` |
| `flowers:mushroom_brown` and `_red` are aliased to `air`, so `default`'s log schematics resolve and the boot log opens clean | `B19` | `cc_mapgen/init.lua` |
| `mapgen_env.lua` writes `minp..maxp` only, never the emerged shell, which belongs to the neighbouring chunks | — | `cc_mapgen/mapgen_env.lua` |
| An interior chunk wholly above `y = 0` returns before `get_data`, which would otherwise be half a million nodes read and written on an emerge thread to change none of them | — | `cc_mapgen/mapgen_env.lua` |
| `sunrise_visible = false` is a field of its own — hiding the sun leaves the sunrise texture drawn | `B47` | `cc_day/init.lua` |
| Every tracked document carries its own `export-ignore` line, or `git archive` ships it to a player | `C15` | `.gitattributes` |
