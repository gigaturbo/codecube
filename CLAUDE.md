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
`games/` directory, not `mods/`. What the game itself contributes is the setting
and the fit: a flat world, permanent day, build restrictions, the settings a
server owner wants, and a presentation that makes the mod pleasant to use.

**Three repositories, two of them submodules of this one.**

- `codecube` — this repo, branch `main`. The game.
- `codeblock` — `mods/codeblock`, branch `master`. The mod that is the
  programming engine: sandbox, drone, editor, API. **It is the main project**,
  with its own ContentDB package, CI, tests, documentation and release path.
  Read `mods/codeblock/CLAUDE.md` and `mods/codeblock/ROADMAP.md` for it; this
  file does not repeat their content.
- `vector3` — `mods/vector3`. A dependency of `codeblock`, by the same author.

`.gitmodules` declares both submodules and `scripts/check_game.sh` verifies both
are populated. Both working remotes are SSH; `.gitmodules` deliberately stays on
HTTPS so anyone can clone the game without keys.

**The submodule pointer follows releases, not commits.** `mods/codeblock` pins
the `codeblock` release this game has adopted, not the tip of `master`. So an
ordinary mod change is one commit, in `codeblock`, and nothing happens here. The
pointer moves only when the game adopts a new release — and that is the same
moment the game's own documentation is brought up to date with it.

At adoption time, and only then, the old hazard applies:

```bash
cd mods/codeblock && git push origin master        # push FIRST
cd ../.. && git add mods/codeblock && git commit   # then record the hash
```

Bumping before pushing records a hash nobody can fetch. It is invisible from a
working tree that already has the object; only a fresh
`git clone --recurse-submodules` catches it (`reference is not a tree`).

A commit message is concise and declarative, in either repository: what the
commit does, not an account of doing it. Name the features added and the bugs
fixed, one short line each, and cite the finding ID where there is one — `A5:
advance the drone for a time budget, not one resume per step`. No narration, no
restating the diff.

## What is in `mods/`

- `codeblock`, `vector3` — the two submodules. Not edited from here.
- `cc_day`, `cc_mapgen`, `cc_security` — the game's own mods, one Lua file each:
  permanent daylight, a flat clean mapgen, and the build restrictions. This is
  the game's code, and the only Lua this repository lints.
- `default`, `dye`, `wool` — vendored from Minetest Game for their nodes.
  Third-party, deliberately not linted and not ours to restyle.

## The project record

**Each project keeps its own record, audit included.** The `project-manager`
agent owns twelve documents in total — four per repository plus the `.claude/`
definitions — and edits to any of them by hand should be reserved for something
that agent cannot know.

The game's four, all in this directory:

- `ROADMAP.md` — the game's own mods, its packaging and presentation, and which
  `codeblock` release it has adopted.
- `TODO.md` — intentions that are not findings. One line per item and a finding
  id where there is one; the description of the work belongs in `ROADMAP.md`, and
  the reasoning in the audit.
- `CHANGELOG.md` — what shipped, for people who *play* the game. It names the
  `codeblock` release adopted and links to the mod's changelog rather than
  repeating it.
- `.audit/audit.html` — gitignored (see the last line of `.gitignore`). The
  game's findings, each with its severity, state and, once fixed, how. Its
  milestones are lettered **`G1`–`G5`**, deliberately not "Phase N".

The mod's four are the same shape, in `mods/codeblock/`, and
`mods/codeblock/ROADMAP.md` is **the one to read first** — the mod is the main
project. `mods/codeblock/CLAUDE.md` describes them; this file does not.

Two things about the split are worth knowing from here:

- **Finding ids are shared across both audits.** A `B`, `S`, `C` or `A` number is
  allocated once, so it never means two things, and it is never renumbered — old
  commit messages cite them. A gap in one audit's sequence is a finding that
  lives in the other.
- **Phase numbers belong to the mod** (`Phase 0`–`Phase 8`) and are quoted in
  commit messages. The game letters its milestones instead so the two schemes
  cannot be confused.

The same agent keeps this file, `mods/codeblock/CLAUDE.md`, the agent definitions
in `.claude/agents/` and the skill descriptions in `.claude/skills/` current,
because those go stale the same way and nothing else checks them. There is one
`.claude/` directory, and it stays here: it is the tree that gets opened, and
`run-tests` needs the game to boot at all.

Two of the skills there will never surface on their own — they carry
`disable-model-invocation: true`, deliberately, because a release is not
something to start by accident. Ask for them by name:
**`release-codeblock`** (bump the mod, regenerate `doc/api.md` and its
`.cdb.json`, tag on `master`, upload) and **`release-codecube`** (adopt a
CodeBlock release, move the pointer, update this game's documentation, run
`check_game.sh`, tag on `main`, upload). The `release-check` agent gates both and
must be told which project it is gating.

## Commands

These are the game's own checks, and they are what **this repository's** CI runs
— `game assembles` and `luacheck (game mods)`:

```bash
bash scripts/check_game.sh    # the game assembles: metadata, submodules, deps, .cdb.json
luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes
bash scripts/gen_cdb_json.sh  # regenerate after a README edit; check_game.sh diffs it
```

Linting and testing the mod belongs to `codeblock`'s own CI, and neither
workflow duplicates the other — both say so in their headers. The consequence to
keep in mind: **the two go red independently.** A mod change turns `codeblock`'s
CI red and leaves this repository green, because nothing here re-runs the mod's
checks; a broken submodule pointer or a stale `.cdb.json` turns this one red and
leaves the mod's green. Check the repository you changed.

The mod's commands — the test suite, `luacheck`, `gen_docs.lua --check` — are in
`mods/codeblock/CLAUDE.md`. The one thing to know from here: the test suite runs
**inside Luanti** and boots *this game*, so testing the mod needs the game
present. Use the `run-tests` skill; it owns the procedure.

## Architecture

The game is thin on purpose. `cc_mapgen` makes the world flat and clean,
`cc_day` holds it at noon, `cc_security` restricts what a player may break or
place; each is a single Lua file. Everything else a player does — the sandbox,
the drone, the editor, the API and its limits — is `codeblock`, and its
architecture is documented in `mods/codeblock/CLAUDE.md`. Read that before
touching anything under `mods/codeblock`.

## Environment notes

The Luanti and Lua 5.1 notes are in `mods/codeblock/CLAUDE.md` and hold for the
game's own mods too. What follows is about this tree.

- `min_minetest_version` / `max_minetest_version` are read by ContentDB, not
  enforced by the engine. Never set a `max_` — it hides a working package.
  `check_game.sh` fails `game.conf` for having one.
- **`.gitattributes` decides what reaches a player, and no CI checks it** — in
  either repository. ContentDB builds a release with `git archive`, so a file
  added to the tree ships unless an `export-ignore` rule excludes it, and nothing
  local fails when one does. Both files were rewritten to say what the archive is
  *for*; add to them when adding anything a player has no use for. `.cdb.json`
  and the `.conf` files are read from the repository rather than the archive, so
  excluding them costs nothing.
- Files are a mix of LF and CRLF. Edit with tools that preserve line endings; a
  whole-file rewrite produces a diff of every line.
- `.editorconfig` in this repository and in `codeblock` describes that tree's
  existing Lua style (`[*.lua]` only) so the installed formatter — EmmyLuaCodeStyle, inside the
  `sumneko.lua` extension — stops reformatting whole files on save. It is not
  lua-format, which is what the style originally came from, and its defaults
  differ. If a diff turns out to be whitespace-only, that is the cause.
- The Bash tool mangles backslashes in heredocs, which has silently corrupted Lua
  patterns twice. Use the edit tools, or a Python script, for anything containing
  a backslash.

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
