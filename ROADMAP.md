# Roadmap

Where Codecube stands and what to do next. The reasoning behind every item lives
in the audit (`.audit/audit.html`, gitignored — generated locally); the ids below
are stable, so a finding can be looked up there. This file is the index.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

Commit the working tree, then start counting mapblocks. `place()` calls
`core.load_area` on every single call and nothing anywhere counts how many
distinct mapblocks a run pins in server memory (S5). The first move is small:
skip the call when the target is the same mapblock as the last write, memoised
per drone. It removes nearly every call in a compact build, and it creates the
one place a distinct-mapblock count can live — which is what the per-codelevel
ceiling needs, and what the budget display in milestone 7 will read.

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

### 5. Limits that track real load — not started (0/3)

Every limit should bound a resource the server actually spends. Today the
ceilings count proxies (calls, commands, volume), the one real resource nobody
bounds is resident mapblocks, and each drone gets its own step allowance rather
than a share of one. Resource safety, not a feature.

- Skip `load_area` when the target mapblock is the one the last write went to —
  `floor(x/16)` per axis, memoised per drone. (S5)
- Count distinct mapblocks per run at that same point, and add a per-codelevel
  ceiling to `lib/config.lua`. New limit means a new row in `doc/api.md`'s
  codelevel table; `gen_docs.lua --check` enforces it. (S5)
- Check elapsed time inside `check_drone_yield`, so the step budget bounds work
  rather than resumes. One resume covers up to 40 commands at codelevel 4 and
  can overshoot 8 ms badly when those commands hit disk. (S5, A5's recorded
  limitation)
- Divide one server-wide step budget among active drones instead of giving each
  its own. N drones currently cost N budgets per step. (S5, A5)
- Split the default codelevel from the singleplayer default: level 4 is right
  for singleplayer and wrong for an unknown player joining a server. (S6)
- Add `settingtypes.txt` at the game root so an administrator can change any of
  this without patching `lib/config.lua`. (C7)

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
  program actually spends. Counts not kept today: elapsed step time, distinct
  mapblocks, peak heap. (`mods/codeblock/TODO.md`; audit S5's visible half)

## What ships broken

- `default` supplies 108 node definitions out of ~9,700 lines and registers six
  always-on ABMs. (A13)
- `max_memory_kb` cannot stop one huge allocation, and a pathological Lua
  pattern can still burn CPU. (S2's residue)
- `place()` writes one node per call; the four bulk shapes do not.
- The step budget is checked between coroutine resumes, so one long call
  overshoots it, and each drone has its own allowance.
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
- **Blockly web editor.** Wanted, out of scope for 1.0.0.
- **Duplicating `codeblock`'s lint in this repository.** It has its own repo,
  CI and `.luacheckrc`; this one checks that the game *assembles*.

---

2026-08-25 · codecube `2c4fedc` (main) · codeblock `f413758` (master), both at
`origin`. Both working trees hold uncommitted work; milestones 5 to 7 have no
code written for them.
