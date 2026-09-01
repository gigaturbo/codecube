---
name: code-standards
description: The standards and the traps for writing the Codecube game's own Lua and configuration — the game is 21 lines of Lua across three mods, so the craft here is mostly deciding what not to add and what belongs upstream in CodeBlock instead. Covers the restriction boundary cc_security holds, the Luanti behaviours that have already cost findings here, and what a change drags with it. Use before editing anything under mods/cc_*, scripts/ or the game's configuration, and when auditing them.
when_to_use: Before editing mods/cc_day, mods/cc_mapgen, mods/cc_security, scripts/, game.conf, minetest.conf, .luacheckrc or .gitattributes; when auditing the game's own code; when deciding whether a change belongs to the game or to the mod; and whenever you are about to state that an engine function exists or behaves in a particular way.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Writing code in Codecube

What the game is, what is in `mods/`, and the submodule policy are in `CLAUDE.md`
and are not restated here. The editing, coding and helper conventions are in
`~/.claude/CLAUDE.md`, they apply here unchanged, and they are not restated
either.

This skill is the craft: what this game may hold, what it must not, and the
behaviours that have already cost findings.

## The first question is always *whose is this*

The game owns **21 lines of Lua**, in three files:

| Mod | Lines | What it does |
|---|---|---|
| `cc_day` | 6 | Holds the world at noon, no sky objects |
| `cc_mapgen` | 2 | Sets `mg_flags` so a new world is flat and clean |
| `cc_security` | 13 | Nothing diggable, no drops, no knockback, no inventory form |

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
drone builds, the player does not. It is thirteen lines and every one of them is
load-bearing.

Five questions for any change to it, or to `minetest.conf` and `game.conf`:

1. **Can a player dig, place or drop a node without the drone?** The three
   guards are the `diggable = false` override on every registered node, an empty
   `handle_node_drops`, and an empty inventory formspec. Removing any one is a
   change to what the game *is*.
2. **Does it override an engine function by assignment?** `cc_security` does
   `function minetest.handle_node_drops() end`, which clobbers any other mod's
   override and is clobbered in turn by whatever loads after it. That is
   **finding `A8`**, `luacheck` code `122` is ignored for that file because of
   it, and the fix is to capture the previous value and chain — a behaviour
   change, not a lint fix.
3. **Does it depend on load order?** The node override runs in
   `register_on_mods_loaded` because it has to see every mod's registrations. A
   guard moved earlier silently covers fewer nodes, and nothing fails.
4. **Does it grant a privilege?** `default_privs` in `minetest.conf` is
   `interact, shout, fast, fly, noclip`. Every entry there is a decision about
   what an unknown player on someone's server can do, and it is the author's,
   not yours.
5. **Does CodeBlock already do it?** `cc_day` duplicates a block the mod already
   runs (**finding `A7`**). Two mods setting the same thing is not twice as safe;
   it is one of them being wrong later and nobody noticing which.

## The Luanti and Lua facts that hold here

- `minetest` is a permanent alias for `core` and is **not** deprecated. Leave the
  existing spelling alone rather than sweeping a two-line file.
- Lua 5.1 / LuaJIT: `loadstring`, `setfenv`, `math.pow`, `math.atan2` all exist;
  **`0` is truthy**, and so is `""`; there is no `__pairs`, no `__len`, no
  integer division; you cannot yield across `pcall`.
- `min_minetest_version` / `max_minetest_version` in `game.conf` are read by
  **ContentDB, not enforced by the engine**. Never set a `max_` — it hides a
  working game from everyone on a current release, and nothing local fails.
  `check_game.sh` fails the build on a reinstated one (**`C1`**'s counterpart).
- `disabled_settings` in `game.conf` takes a `!` prefix to force a setting off —
  `!creative_mode` and `enable_damage` are not the same kind of entry, and they
  read as though they were.
- `minetest.conf` at the game root supplies **defaults a player or server owner
  can still change**. It is presentation and courtesy, never a guarantee; a
  restriction that matters belongs in `cc_security`.

Use the **`references`** skill before stating that a `core.*` function exists, is
deprecated, or takes particular arguments. It bundles `lua_api.md`, the Lua 5.1
manual and ContentDB's own rules offline. Answering from memory is how findings
get here.

## The vendored mods are not ours

`default`, `dye` and `wool` come from Minetest Game and exist for their node
definitions. They are excluded from `.luacheckrc` deliberately and are **not to
be restyled, linted or refactored**. The one sanctioned change is **`A13`**:
trimming `default` down to the nodes the game actually uses — 9,744 lines for 108
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

Then say plainly, in the reply: which gates ran and what they printed; that the
game **has no test suite**, so nothing you ran demonstrates behaviour; what
therefore needs a `PLAYTEST.md` entry; and any defect found in code you did not
write, so it can get a finding id.
