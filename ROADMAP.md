# Roadmap

Where Codecube stands and what to do next. The reasoning behind every item lives
in the audit (`.audit/audit.html`, gitignored — generated locally); the ids below
are stable, so a finding can be looked up there. This file is the index.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

Get the limits rewrite through CI, then start the budget display. `luacheck` and
`lua scripts/gen_docs.lua --check` have never run against milestone 6 — there is
no Lua toolchain on this machine — and that second one matters here specifically,
because the rewrite changed how `gen_docs.lua` decides which limits need a
documented row (C14). After a green run, the budget display is the natural
follow-on: `lib/limits.lua` keeps every cap beside its counter in one table on
the drone precisely so it can be printed, and nothing prints it yet.

## Milestones

### 0. Make change safe — done (2/2)

Run on the current engine, put the sandbox under test, restore linting.

### 1. Ship the compliance fixes — done (8/8)

Installable and honest: no version ceiling, licensing settled across the
bundled mods, user-visible command and editor bugs fixed.

### 2. Rewrite the sandbox preprocessor — done (11/11)

Stop corrupting valid programs; make the environment something a program cannot
reach out of.

### 3. Replace ActiveFormspecs — done (5/5)

Last unmaintained dependency gone; documentation generated from the code.

### 4. Performance — done (4/4)

The drone builds at the speed the hardware allows, not one pinned to the tick
rate; bulk shapes are one VoxelManip pass each.

### 5. Limits that track real load — done (4/4)

Committed as codeblock `43e95a8`, game `e7ef684`, CI green. Every limit given a
resource to stand for, the step budget made a shared pool, `settingtypes.txt`
added, and the default codelevel split between singleplayer and server.

Three of its items were **superseded within the week** by milestone 6 and no
longer exist as described: `max_mapblocks` (became `map_memory_mb`),
`max_distance` stored in nodes (deleted outright), and the deadline inside
`check_drone_yield` (that function is gone). The findings stay closed — each
resource is still bounded — but read the audit, not the old wording.

### 6. Limits that stand for what the server spends — done, uncommitted (3/3)

Eleven per-codelevel limits counted proxies; seven now count what the server
actually spends, in units a player and an administrator can read. Written and
green on the in-engine suite (326 assertions, three runs), living in
`mods/codeblock`'s working tree: no commit, no submodule bump, no CI, no lint.

- [x] Add `lib/limits.lua`: caps converted once into the units they are checked
  in, counters beside them; `charge` stops the run, `hold` makes it wait. (S5)
- [x] Replace `max_calls`/`max_commands` with `max_runtime_s`, `max_volume` with
  `max_nodes_written`, `max_mapblocks` with `map_memory_mb`. (S5)
- [x] Delete `max_distance`, `max_dimension` and the yield-cadence tables; keep
  the drone inside `mapgen_limit` instead. (S5, C13)
- [x] Pace codelevels 1 and 2 with `pace_ms`, so a beginner can watch the loop;
  warn at load when a retired setting name is still in `minetest.conf`.
- [x] Slice `shapes.build` into mapblock-aligned slabs, charged before each
  VoxelManip pass — a 150-node cube froze the server for 0.44 s. (A5)
- [x] Fix `use_call` yielding without dropping the mapblock memo, which could
  lose a write with no error. (B25)
- [x] Report duration with `get_us_time`, not `os.clock` — process CPU time on
  POSIX. (B26)
- [x] Match the documented-limit check by table shape, not name prefix; it had
  silently exempted `pace_ms`, `heap_mb` and `map_memory_mb`. (C14)
- Left to do: commit, push, bump the submodule, watch CI for `luacheck` and
  `gen_docs.lua --check`. Playtesting of pacing and the throttle is in progress.

### 7. Clear the way for features — not started (3/24)

Remove the duplication and dead weight that make every new feature cost more
than it should.

- Trim vendored `default`: 9,744 lines for 108 node definitions, and six
  always-on ABMs still run. Closes B19 and B24 for free. (A13)
- Split `lib/commands.lua`, now 971 lines of largely mechanical repetition. (A3)
- Give the drone record one owner and split `drone.lua` / `drone_entity.lua` by
  direction of dependency; move the two form builders to `formspecs.lua` and
  report completion from one place. Closes B10 and B11 with it. (A11)
- Flatten the entity prototype's two-level metatable chain. (A6)
- Drop `cc_day`'s duplicate of a block `codeblock` already runs, marked
  "TEMP fix". (A7)
- Stop `cc_security` clobbering two engine callbacks by direct assignment;
  capture and chain instead. (A8)
- De-duplicate the filesystem read path and its six near-identical getters. (A9)
- Fix the file-read error that prints a file handle instead of a filename. (B7)
- Fix `save_editor_state` passing nil to `set_string`, `write_file` /
  `remove_file` indexing an unpopulated cache, a number passed to `set_string`,
  and the dead branch that leaves cylinder coordinates nil. (B13, B14, B17, B18)
- Stop wiping the player's whole inventory on every join. (B16)
- Add error handling to example loading, which also leaks handles. (B15)
- Fix the malformed `.gitattributes` line. (C10)
- Fold `minetest.*` → `core.*` into other edits; style, not breakage. (C6)
- Clear the last 8 trailing-whitespace sites. (B21)

### 8. Show the budget — not started (0/1)

The last thing before v1.0.0, and a feature rather than a fix: a player should
see what a program is spending while it runs.

- Show each count beside its limit, live rather than only on completion, and the
  *binding* constraint as a percentage so a player learns which limit their
  program actually spends. `drone.budget` already pairs `caps` with `used`; peak
  heap is still not kept, and the charged-CPU figure dropped from the completion
  line belongs here as a share. The live half depends on A11.
  (`mods/codeblock/TODO.md`)

## What ships broken

- `default` supplies 108 node definitions out of ~9,700 lines and registers six
  always-on ABMs. (A13)
- `heap_mb` cannot stop one huge allocation, and a pathological Lua pattern can
  still burn CPU inside a single `find` or `match`. (S2's residue)
- The step budget is never checked *inside* one VoxelManip pass, so a single
  slab — around 65k nodes, under 10 ms — still overshoots it.
- The map footprint decays linearly over the unload window rather than tracking
  each block, so it estimates what is resident rather than measuring it.
- `place()` writes one node per call; the four bulk shapes do not. (A4)
- Pacing, slab progression and the footprint throttle have no in-world
  verification: the specs run before a map exists, so `place()` is unreachable
  from them. Untested, not known broken.
- Unknown whether mapgen can overwrite a node written into a never-generated
  area when a player later visits and it generates.

## Deliberately not doing

- **Batching `place()` into `core.bulk_set_node`.** 1.3x by the engine's own
  figure, against five flush sites whose omission is a silently wrong build.
  Contingent on the yield cadence, which milestone 6 changed, so the arithmetic
  under A4 in the audit wants redoing before the decision is quoted again.
- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias
  for `core`, with no deprecation warning and no removal date. (C6)
- **Chasing the last `.editorconfig` difference.** `align_call_args = true`
  fixes the wrapped-argument alignment but pushes a table constructor passed to
  a call out to the paren column, which is worse. Alignment stays off and the
  tree drifts to the hanging indent one file at a time. Accepted, not
  overlooked.
- **`settingtypes.txt` at the game root.** Every setting is codeblock's, and
  codeblock is its own ContentDB package; in the mod it works for a standalone
  install and appears under Mods. (C7)
- **Computing the codelevel limits instead of overriding literals.**
  `gen_docs.lua` reads `lib/config.lua` for a name assigned a table of numbers,
  so a computed value would silently disable the check that every limit is
  documented. (C7, C14)
- **Blockly web editor.** Wanted, out of scope for 1.0.0.
- **Duplicating `codeblock`'s lint in this repository.** It has its own repo,
  CI and `.luacheckrc`; this one checks that the game *assembles*.

---

2026-08-26 · codecube `e7ef684` (main) · codeblock `43e95a8` (master). Both at
`origin`, both green in CI. **Milestone 6 is written and uncommitted in
`mods/codeblock`** — neither sha above contains any of it, and no submodule bump
records it yet. Milestones 7 and 8 have no code.
