# Roadmap

Where Codecube stands and what to do next. The reasoning behind every item lives
in the audit (`.audit/audit.html`, gitignored — generated locally); the ids below
are stable, so a finding can be looked up there. This file is the index.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

Commit and push milestone 5, then verify `place()` in a live world before
starting milestone 6. All of milestone 5 sits uncommitted in `mods/codeblock`,
so no CI run has seen it and neither `luacheck` nor `gen_docs.lua --check` has
run on the new `max_mapblocks` row. After that, the one untested path: the specs
run before a map exists, so `place()`'s mapblock memo and charge have no test at
all (S5). Fly a drone at codelevel 4, build a spread-out `place()` loop, and
watch `core.get_loaded_blocks()` and the server's RSS — that confirms no write is
lost and finally gives the memory claim a number.

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

### 5. Limits that track real load — done, uncommitted (4/4)

Every limit now bounds a resource the server actually spends. Written and green
on the in-engine suite (259 assertions), but living in `mods/codeblock`'s working
tree: no commit, no submodule bump, no CI, no lint.

- [x] Skip `load_area` when the target mapblock is the one the last write went
  to; memo dropped at every yield so it cannot outlive an unload. (S5)
- [x] Charge mapblock loads against a new per-codelevel `max_mapblocks`, shapes
  included via `shapes.build`'s return. (S5)
- [x] Yield on a `drone.deadline` inside `check_drone_yield`, so the budget
  bounds work rather than resumes. (S5, A5's recorded limitation)
- [x] Divide one `server_step_budget_us` pool among running drones instead of
  giving each its own. (S5, A5)
- [x] Default codelevel 4 in singleplayer, 2 on a server. New players only. (S6)
- [x] Add `settingtypes.txt` — in the mod, not the game root, so it works for a
  standalone install too. (C7)
- [x] Store `max_distance` in nodes as documented, squaring at the comparison.
  Effective limit unchanged. (C13)
- Left to do: commit, push, bump the submodule, then run the live-world `place()`
  check. (S5)

### 6. Clear the way for features — not started (3/24)

Remove the duplication and dead weight that make every new feature cost more
than it should.

- Trim vendored `default`: 9,744 lines for 108 node definitions, and six
  always-on ABMs still run. Closes B19 and B24 for free. (A13)
- Split `lib/commands.lua`, 933 lines of largely mechanical repetition. (A3)
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

### 7. Show the budget — not started (0/1)

The last thing before v1.0.0, and a feature rather than a fix: a player should
see what a program is spending while it runs. Depends on both milestones above —
it consumes the counters milestone 5 adds, and it is UI reading live drone state
across the seam A11 straightens.

- Show each count beside its limit, live rather than only on completion, and the
  *binding* constraint as a percentage so a player learns which limit their
  program actually spends. Milestone 5 added `drone.mapblocks` and
  `drone.deadline` to read; peak heap is still not kept.
  (`mods/codeblock/TODO.md`; audit S5's visible half)

## What ships broken

- `default` supplies 108 node definitions out of ~9,700 lines and registers six
  always-on ABMs. (A13)
- `max_memory_kb` cannot stop one huge allocation, and a pathological Lua
  pattern can still burn CPU. (S2's residue)
- `place()` writes one node per call; the four bulk shapes do not.
- The step budget is checked between drone commands, never inside one, so a
  single long call — a large shape — still overshoots it.
- `max_mapblocks` counts loads rather than distinct blocks, and bounds a whole
  run rather than what is resident at any instant. It only works together with
  the step budget, which bounds throughput.
- A shape is charged after its pass, so one shape can overshoot the mapblock
  ceiling by its own size (roughly a thousand blocks at codelevel 4).
- `place()`'s mapblock memo and charge have no test: the specs run before a map
  exists. Untested, not known broken.
- Unknown whether mapgen can overwrite a node written into a never-generated
  area when a player later visits and it generates.

## Deliberately not doing

- **Batching `place()` into `core.bulk_set_node`.** 1.3x by the engine's own
  figure, on runs of at most 40 nodes, against five flush sites whose omission
  is a silently wrong build. Contingent: change the yield cadence and the answer
  changes. Arithmetic under A4 in the audit.
- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias
  for `core`, with no deprecation warning and no removal date. (C6)
- **Chasing the last `.editorconfig` difference.** The formatter indents a
  wrapped argument list by `continuation_indent` where lua-format aligned it
  under the open paren. `align_call_args = true` fixes the alignment but
  pushes a table constructor passed to a call out to the paren column, which is
  worse, so alignment stays off and the tree drifts to the hanging indent one
  file at a time as files get saved. Accepted, not overlooked.
- **`settingtypes.txt` at the game root.** Every setting is codeblock's, and
  codeblock is its own ContentDB package; in the mod it works for a standalone
  install and appears under Mods. (C7)
- **Computing the codelevel limits instead of overriding literals.**
  `gen_docs.lua` greps `lib/config.lua` for `max_* = {`, so a computed value
  would silently disable the check that every limit is documented. (C7)
- **Blockly web editor.** Wanted, out of scope for 1.0.0.
- **Duplicating `codeblock`'s lint in this repository.** It has its own repo,
  CI and `.luacheckrc`; this one checks that the game *assembles*.

---

2026-08-25 · codecube `2e9098d` (main) · codeblock `3e143ea` (master). Both at
`origin`, both green in CI. **Milestone 5 is written and uncommitted in
`mods/codeblock` only** — neither sha above contains any of it. Milestones 6 and
7 have no code.
