# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Responses

Keep replies short. Lead with the result, then only what the user could not see
for themselves — a decision made, an assumption, something that went wrong.
Don't restate the request, don't narrate the steps that worked, and don't add a
summary of what was just said. Tables and headings only when they carry
information a sentence would not.

Say plainly when something is unverified, skipped, or failed.

## What this is

Codecube is a Luanti (formerly Minetest) **game** in which the player programs a
drone in Lua to build structures. It is not a mod, so it belongs in Luanti's
`games/` directory, not `mods/`.

**Two repositories, one nested in the other.** `codecube` (this repo, branch
`main`) bundles the `codeblock` mod (`mods/codeblock`, branch `master`), which
holds essentially all the logic, as a submodule. A mod change is two commits, in
this order:

```bash
cd mods/codeblock && git commit && git push        # push FIRST
cd ../.. && git add mods/codeblock && git commit   # then record the hash
```

Bumping before pushing records a hash nobody can fetch. It is invisible from a
working tree that already has the object; only a fresh
`git clone --recurse-submodules` catches it (`reference is not a tree`).

Both working remotes are SSH. `.gitmodules` deliberately stays on HTTPS so
anyone can clone the game without keys.

A commit message is concise and declarative: what the commit does, not an
account of doing it. Name the features added and the bugs fixed, one short line
each, and cite the finding ID where there is one — `A5: advance the drone for a
time budget, not one resume per step`. No narration, no restating the diff.

## The project record

Five documents say where the project stands. The `project-manager` agent owns
all of them; edit one by hand only for something that agent cannot know.

- `ROADMAP.md` — tracked, and the one to read first. What is left to do, fix or
  change, in order, with milestones. The short version of the audit, meant for
  picking the work back up.
- `.audit/audit.html` — gitignored. Every finding with its ID, severity, state
  and, once fixed, how. The long version, and the reasoning `ROADMAP.md` leaves
  out.
- `CHANGELOG.md` and `mods/codeblock/CHANGELOG.md` — what shipped, per repo.
- `mods/codeblock/TODO.md` — intentions that are not findings. A quick overview
  of what is wanted, one line per item and a finding id where there is one; the
  description of the work belongs in `ROADMAP.md`, and the reasoning in the
  audit.

The same agent keeps this file, the agent definitions in `.claude/agents/` and
the skill descriptions in `.claude/skills/` current, because those go stale the
same way and nothing else checks them.

## Commands

The test suite runs **inside Luanti**. Use the `run-tests` skill — it owns the
procedure. The one thing to know without reading it: enabling the suite writes
`codeblock_run_tests = true` into the player's real config, and it must be
removed afterwards or every ordinary launch runs the tests.

Five specs also run standalone under a Lua 5.1 interpreter, which is how CI runs
them and the only way to catch behaviour differing between plain 5.1 and the
LuaJIT the game uses:

```bash
cd mods/codeblock
lua tests/api_spec.lua    # also preprocess_spec, env_spec, shapes_spec, strguard_spec
```

`forms_spec`, `stepper_spec` and `integration_spec` are in-engine only — they
need `codeblock.forms`, the real command budget and `codeblock.commands`. Faking
those would mean testing the fake. Running a single spec in-engine means editing
the `dofile` list in `mods/codeblock/init.lua`.

Other checks, all also run by CI:

```bash
bash scripts/check_game.sh                              # game assembles (repo root)
cd mods/codeblock && luacheck . --formatter plain --codes
cd mods/codeblock && lua scripts/gen_docs.lua --check    # doc/api.md matches the code
bash scripts/gen_cdb_json.sh                            # regenerate after a README edit
```

`LUACHECK_STRICT=1` reports what the baseline exemptions hide.

Reading a result: `failed` must be 0, and so must `xpass`. An `xfail` that now
passes either means a defect was fixed and the test should be promoted, or the
code path stopped running and the assertion passes vacuously. The second has
happened here.

## Architecture

### Running a player's program

The pipeline spans several files and is the thing worth understanding first.

1. **`lib/preprocess.lua`** instruments the source over a token stream, inserting
   `_G.use_call()` after every `do`, every `repeat`, every function parameter
   list, and before every `goto`. That is what makes loops and calls pay into a
   budget, so a runaway program stops instead of freezing the server. Free of any
   Luanti dependency so it can be tested standalone. It also reports forbidden
   identifiers — a message-quality feature, *not* the security boundary.
2. **`lib/env.lua`** builds the environment. `snapshot` gives each run its own
   copy of the API's tables — copies, not read-only proxies, because Lua 5.1 has
   no `__pairs` or `__len` and a proxy would break `pairs(blocks)` for player
   code. `new_env` makes API names unassignable, which is what stops a program
   reaching the injected counter.
3. **`lib/sandbox.lua`** pairs every name with an implementation, calls
   `api.build`, `setfenv`s the chunk, returns a coroutine.
4. **`lib/stepper.lua`** resumes that coroutine repeatedly each server step until
   a time budget is spent, so throughput follows spare headroom rather than the
   tick rate. That budget is the smaller of the codelevel cap and an equal share
   of one server-wide pool, so N drones do not cost N budgets. It is published as
   `drone.deadline` and checked at every drone command as well as between
   resumes, so what overshoots it is a single *call* — one large shape.
5. **`lib/strguard.lua`** bounds `rep` and `gsub` on the shared string metatable
   for the span in which player code runs. Leaving `string` out of the
   environment is not enough: every Lua 5.1 string shares one metatable, so
   `("x"):rep(1e9)` is reachable from any literal.

The security boundary is the environment table plus the read-only API surface,
not the forbidden-name list.

### The API has one source

`lib/api.lua` is pure data and the single description of everything a program can
call. Three things derive from it: the sandbox environment, the in-game help
panel (`api.to_hypertext`), and `doc/api.md` (`api.to_markdown`). `api.build`
raises if description and implementations disagree **in either direction**, so
the mod refuses to load rather than ship a reference that lies, and
`gen_docs.lua --check` fails CI if the committed Markdown has drifted.

Changing a player-facing name means editing `lib/api.lua`, the `impls` table in
`lib/sandbox.lua`, and regenerating `doc/api.md`. Such a change breaks saved
player programs, which are data the game cannot migrate — that is a major version
bump.

### Per-codelevel limits

Almost every limit in `lib/config.lua` is a four-element array indexed by the
player's codelevel (1–4): call and command ceilings, volume, distance, dimension,
yield frequency, `step_budget_us`, `max_memory_kb`, `max_string_bytes`,
`max_mapblocks`. Codelevel bounds resource use, so it is privileged — never let
players set their own. Adding a limit means adding a row to the codelevel table
in `doc/api.md`; `gen_docs.lua` enforces that, because a limit once shipped
undocumented.

Every one of those tables is overridable from `mods/codeblock/settingtypes.txt`,
as four comma-separated numbers, plus the two scalars `default_auth_level` and
`server_step_budget_us`. Two constraints in `config.lua` exist for reasons that
are not local to it, so check before changing either. The tables stay **plain
literals** with the overrides applied in one loop afterwards, because
`gen_docs.lua` greps this source for `max_%w+%s*=%s*{` — a computed value turns
that documentation check off without failing. And every settings read is guarded
with `rawget(_G, 'minetest')`, because `gen_docs.lua` dofiles `config.lua` under
a bare interpreter with no engine global.

`max_distance` is stored in nodes and squared at its one comparison in
`check_distance`, not stored squared.

### Writing to the world

`lib/shapes.lua` owns the four bulk shapes (cube, sphere, dome, cylinder), one
VoxelManip pass each, through `shapes.build(spec)`. Single-node `place()` lives in
`lib/commands.lua` and must call `core.load_area` first: `set_node` into a
mapblock that is not in memory silently does nothing, which used to leave holes
in builds far from spawn. Bulk shapes need no such call — `read_from_map` emerges
the region itself.

`place_block` makes that call only when the drone crosses into a new mapblock,
comparing `floor(x/16)` on three axes against the last write, and charges each
load against `max_mapblocks`. Two things about that memo are load-bearing.
`load_area` does not trigger mapgen, so what a load costs is a resident MapBlock
plus a disk read — and `max_memory_kb` cannot see it (`collectgarbage('count')`
is the Lua heap; a MapBlock is C++ side), which is why the count exists.
And the memo is **per-resume, not per-run**: `check_drone_yield` clears
`drone.bx/by/bz` before every yield, because the engine may unload a block while
the drone is not running (`server_unload_unused_data_timeout`, 29s). Widening its
lifetime brings back the silent lost write the `load_area` call was added to fix.

Bulk shapes are charged too: `shapes.build` returns how many mapblocks its pass
emerged, and every shape command wraps the call in `use_mapblocks`. Without that,
`cube(1,1,1)` in a loop bypasses the ceiling exactly.

Untested, as of audit S5's resolution: the specs run at mod load, before a map
exists, so nothing exercises `place()` itself.

### Formspecs

`lib/forms.lua` is a per-player form session on `core.show_formspec`: state that
survives a redraw, field routing, cleanup on leave, one form per player.
`lib/formspecs.lua` builds the editor itself. Handlers are
`handler(meta, player, fields)`, where `meta` is the same table across redraws.

### `drone.lua` vs `drone_entity.lua`

These do not divide by responsibility, and the drone record has no single owner
(audit A11, tracked in `mods/codeblock/TODO.md`). Expect to re-derive the
invariant when touching either.

## Environment notes

- `minetest` is a permanent alias for `core` and is **not** deprecated.
- Lua 5.1 / LuaJIT: `loadstring`, `setfenv`, `math.pow`, `math.atan2` all exist;
  `0` is truthy; you cannot yield across `pcall`.
- `min_minetest_version` / `max_minetest_version` are read by ContentDB, not
  enforced by the engine. Never set a `max_` — it hides a working package.
- Files are a mix of LF and CRLF. Edit with tools that preserve line endings; a
  whole-file rewrite produces a diff of every line.
- `.editorconfig` in both repositories describes the tree's existing Lua style
  (`[*.lua]` only) so the installed formatter — EmmyLuaCodeStyle, inside the
  `sumneko.lua` extension — stops reformatting whole files on save. It is not
  lua-format, which is what the style originally came from, and its defaults
  differ. If a diff turns out to be whitespace-only, that is the cause.
- The Bash tool mangles backslashes in heredocs, which has silently corrupted Lua
  patterns twice. Use the edit tools, or a Python script, for anything containing
  a backslash.
- Mod security blocks writes into a mod's own directory, so
  `codeblock_gen_docs=true` writes `api.md` into the world directory to be copied
  over by hand.

## Editing style

- Prefer editing existing code over adding a new abstraction layer.
- Prefer fewer symbols and fewer cross-file entry points. Keep as much as
  possible local to a file; export the minimum.
- Inline a helper that has become a one-liner, or that only checks for `nil`.
- Don't add a helper used in one place.
- Reuse and extend what exists rather than adding a parallel path. Avoid
  duplication — except where the helper policy below prefers it.
- Write the least code that does the job, and create the fewest tables to do it.

### Comments

A few lines saying what a module, function or section does and how to use it,
plus anything genuinely non-obvious — a constraint that would be re-broken if
forgotten, an argument order, a contract.

Never the history of what the code replaced. That belongs in git and the
CHANGELOG, and in a comment it goes stale: `config.lua` claimed for months that
nothing in Lua 5.1 could stop a huge string allocation, after `strguard.lua`
started doing exactly that. Audit finding IDs are fine as a short reference, not
as a retelling.

## Coding style

- A function taking many arguments should take a table instead. Lua's `f{...}`
  call syntax makes this cheap, and it names the fields at the call site —
  `shapes.build{kind = 'cube', w = w, h = h, ...}`.
- Prefer linear branching to deeply nested cumulative conditions. Aim for at most
  four or five `if`s in a function.
- Never nest conditionals more than three deep. Refactor instead: an early
  `return`, or a table of functions keyed by the thing being switched on — Lua has
  no `switch`, and a dispatch table is usually clearer than an `elseif` chain
  (see `bounds` and `fillers` in `lib/shapes.lua`).
- Split a file when it starts covering more than one topic. Nothing here measures
  cyclomatic complexity, so that is the practical signal; `lib/commands.lua` at
  ~970 lines is the current outlier, not the model.
- Modules are self-enclosed: they take a minimal set of inputs, produce their
  output, and know nothing about each other. Orchestration belongs to the caller.
  `lib/shapes.lua` knows nothing about drones; `lib/stepper.lua` takes its clock
  and guards as injected dependencies.

## Helper policy

Do not introduce or keep a helper whose main effect is to hide:

- fallback selection,
- ownership transfer,
- buffer or source selection,
- cleanup ordering,
- early returns or failure routing.

Prefer local duplication in those cases. Never wrap an engine call in a function
that contains nothing else.

Helpers are worth it for:

- reusable math or geometry,
- format conversion,
- data structure utilities,
- self-contained algorithms with no hidden resource lifetime,
- a block genuinely reused in several places,
- branching complex enough that inlining it would obscure the control flow.
