# Roadmap — Codecube

Where the game stands and what to do next. Codecube is a *game*: it bundles the
CodeBlock mod, gives it a world worth building in, and presents it to players.
CodeBlock is the main project — read
[its roadmap](https://github.com/gigaturbo/codeblock/blob/master/ROADMAP.md), or
`mods/codeblock/ROADMAP.md` in this checkout, first. This file covers only what
the game itself owns: its own mods, its settings and presentation, its
packaging, and which CodeBlock release it has adopted.

The reasoning behind every item lives in **this game's own audit**, `AUDIT.md`,
and the manual checks are in `PLAYTEST.md`; `.reports/*.html` are gitignored
renderings of both and of this file. The mod's audit is separate and is the main
one: `mods/codeblock/AUDIT.md`.

Two numbering conventions, so a commit message always resolves:

- **Milestones here are lettered `G1`–`G5`.** They are not the mod's phases. The
  mod numbers its work `Phase 0`–`Phase 8` and those numbers appear in commit
  messages, so this file never says "Phase N" for anything of its own. Where a
  milestone is the game's share of a mod phase, it says which.
- **Finding ids are shared** with the mod's audit — a `B`, `S`, `C` or `A` number
  is allocated once across both, so it never means two things and is never
  renumbered. The seventeen below are the game's; the rest are the mod's, as is
  the `F` feature series.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

Nothing here is blocking. The game is current with CodeBlock `2647228`, both CI
workflows are green on that pair of commits, and **the next step for the project
as a whole is on the mod side** — Phase 7, the drone seam (A11). This file does
not compete with that.

The game's own next step is **one check in a world**: `R7`, against the `B49` fix
just committed. The fix stops the world changing on its own, and the half of it
that neutralises `default`'s ABMs rests on undocumented behaviour — so `R7` is
not a formality, it is what says whether the fix works at all.

**G3 turned out smaller than it looked.** Scoping the trim produced `B49` and
then deferred `A13` itself: `codeblock` is expected to take the blocks it needs,
at which point the vendored `default` is deleted rather than trimmed. The
grounds are under *deliberately not doing*.

**The game was played against `PLAYTEST.md` for the first time on 2026-09-01**,
in three rounds. Eleven of the eighteen checks pass and one is partial. **Every
restriction checked that day is evidence rather than reading**: nothing diggable,
no drops, no knockback, no inventory reachable, and the drone building through
all of it. `cc_mapgen` and `cc_day` are proven the same way. `R7`, added since,
is the one claim still resting on reading.

**Two hours produced three findings** — B47, B48 and S8 — none of which was
visible from reading the three `cc_*` files, 21 lines between them. Two are
closed and re-checked; B48 is cosmetic and open.

**And re-running a check against its own fix is what the day actually taught.**
Re-running `L1` cleared a blocker the audit had predicted for B47 that turned out
not to exist. Re-running `R6` found the first S8 fix had closed the wrong half —
items could no longer be put *into* a bookshelf, but a player could still drag a
drone tool *out* of the hotbar through the same panel, into a row they cannot
reopen. Marking R6 pass on the strength of that fix would have shipped it. A fix
is not evidence; the check is, and it costs minutes.

What is still unproven: `R7` above all, then `L3` and `R5` gated on A7 and A8,
`P3`–`P5` and the boot half of `P1`. The game still has no test suite, nothing
automated reaches its behaviour, and nothing here will.

## Milestones

### G1. Ship an honest, installable package — done (6/6)

No version ceiling, licensing settled across everything the game bundles, a
release archive containing only what a player needs, and a ContentDB page written
for its own reader. Mostly the game's share of the mod's Phase 1; C15 and C20
landed much later and sit here as the same subject.

- [x] Removed `max_minetest_version` from `game.conf`; `check_game.sh` now fails
  on a reinstated one. (C1 is the mod's counterpart)
- [x] Repointed image URLs from `master` to `main`. (C2)
- [x] Catalogued every bundled mod's licence in `THIRD-PARTY-LICENSES.md`,
  unified on AGPL-3.0-only, and gave `cc_day`, `cc_mapgen` and `cc_security`
  their own. (C3, C4, C5)
- [x] Stopped the release archive shipping `.claude/` (993 kB), the audit,
  `.github/`, `scripts/` and the art sources to players: **3.29 MB down to
  1.93 MB zipped**, by `git archive --format=zip`, verified by `P2`.
  `menu/*.png` is kept, since that is what the main menu reads. (C15)
- [x] Stopped the ContentDB long description being `README.md` verbatim, which
  broke six of ContentDB's own page rules at once — including nine images, five
  of them tool icons used *inline in the instructions*, invisible to anyone
  browsing in-game. `CONTENTDB.md` is now the source and the generator's header
  carries the rules. (C20; the mod's counterpart is C19)

### G2. Check the game, not the mod — done (2/2)

A CI that checks what this repository alone can check. The game's share of the
mod's Phase 3, which also deleted the two vendored dependencies from here.

- [x] Added `scripts/check_game.sh` and this repository's CI; the mod took its
  own lint, specs and badge. (A14)
- [x] Deleted the vendored WorldEdit fork, with its arbitrary-code-execution
  module removed first, and the vendored `formspecs` submodule — which removed
  every deprecation warning the boot had. (B20; A15, S4, A1 are the mod's)
- [x] Fixed `gen_cdb_json.sh` producing different output by line ending. (B22 is
  the mod's; this repository's copy is diffed by `check_game.sh`)
- [x] Added `cc_mapgen` (flat clean world) and `cc_day` (permanent noon).

### G3. Trim what the game vendors — deferred, and one part done instead (1/2)

Scoped on 2026-09-02 and the scoping is what changed it. Reading `default`
against the palette turned up a behaviour defect nobody had looked for, and made
the case for the trim itself weaker rather than stronger.

- [x] Stop the world changing on its own. Two of `default`'s six ABMs act on
  palette nodes: `dirt` beside any `dirt_with_*` becomes that node, and any
  `spreading_dirt_type` reverts to plain `dirt` under an opaque roof — so roofing
  a grass floor destroys the grass. Ten saplings grow trees over what a program
  built. Fixed in `cc_security`, which is where the game's rules live, and
  **unverified**: the ABM half rests on undocumented behaviour, so `R7` decides
  it. (B49)
- **Deferred: trimming vendored `default` itself.** (A13) The reasoning is under
  *deliberately not doing*, below. Nothing a player meets is waiting on it — the
  saving is size and boot noise, and `B19`'s five boot errors and `B24`'s two
  warnings stay until it happens or `default` goes.

The counting was corrected while scoping: the palette is **122 nodes — 106 from
`default`, 15 from `wool`, plus `air`** — not the 124 and 108 the audit recorded.
All 106 are in `nodes.lua`, so the removable set is whole files, not a curation
within one.

### G4. Make the game's own mods behave — started (2/5)

The first playtest, on 2026-09-01, added three of these five, and two are fixed
and checked. Between them they are what stands between the game's restrictions as
written and the restrictions as played. Nothing left here is large, and none of
it is blocking.

- [x] `cc_day`: hide the sunrise texture too — `set_sun{visible = false}` leaves
  it drawn, and part of the sun shows at dawn. `L1` passes on it. (B47)
- [x] Closed the bookshelf, twice: a node formspec reaches around the blanked
  player inventory, and the palette exposes `bookshelf`. The first fix stopped
  items reaching the bookshelf; `R6` then found the real hazard was the other
  way, a tool dragged out of the hotbar into a row the player cannot reopen. The
  player may now move nothing at all, and `R6` and `R4` both pass on it. (S8)
- Drop `cc_day`'s duplicate of a block `codeblock` already runs, marked
  "TEMP fix". Purely untidiness after all: `L1` passes with the duplicate still
  in place, so it was never blocking B47. (A7)
- Stop `cc_security` clobbering two engine callbacks by direct assignment;
  capture and chain instead. (A8)
- Stop wool cracking under a punch it will not break — the client predicts the
  dig from the node's groups and the server then refuses. Cosmetic. (B48)

### G5. Adopt CodeBlock 1.0.0 and ship — not started

The game's own last step, and it comes after the mod has a 1.0.0 to adopt. No
findings: nothing here is defective, it has not happened yet.

- Move `mods/codeblock` to the tagged CodeBlock release, not to the tip of
  `master`.
- Update this game's documentation in the same commit: `README.md`, the
  changelog, and anything in them that names a mod behaviour that changed.
- Regenerate `.cdb.json` after any `CONTENTDB.md` edit — `check_game.sh` diffs
  it, and a stale one turns this repository's CI red. Editing `README.md` no
  longer affects it (C20).
- Run `check_game.sh`, verify a fresh `git clone --recurse-submodules` (`P1`),
  list the release archive (`P2`), tag on `main`, upload to ContentDB, then read
  the page in-game (`P5`). The `release-codecube` skill owns the procedure.

## What ships broken

- `default` supplies 106 node definitions out of ~9,700 lines, and registers six
  ABMs, 3 LBMs and 101 craft recipes that nothing can reach. Deferred, not
  pending. (A13)
- `.gitattributes` decides what reaches a player and **no CI checks it**, here or
  in the mod. A file added to this repository ships in the ContentDB archive
  unless a rule excludes it, and nothing local fails when one does. `PLAYTEST.md`
  `P2` is the only thing that would catch it; it passed at `8b27f2f` and has to
  be re-run every time a tracked file is added. (C15)
- **A bookshelf still opens and shows the player their own inventory**, around
  the blanked inventory formspec. Nothing can be moved at all and `R6` confirms
  it, but the panel is there: the formspec is metadata on the placed node, not a
  field `cc_security` can override away. (S8)
- Wool cracks under a punch that will not break it. (B48)
- **Unverified: that the world no longer changes on its own.** The fix for B49 is
  committed, and the half that neutralises `default`'s ABMs works by undocumented
  means — until `R7` runs, whether it takes effect is unknown. If it does not,
  dirt still spreads grass and a roofed grass floor still reverts to plain dirt,
  destroying what a program placed.
- The game still has no test suite, and nothing automated reaches its behaviour.
  What is proven is what `PLAYTEST.md` records as run — twelve of eighteen checks
  in three rounds on 2026-09-01, eleven of them passing — and no more.
- Everything in the mod's "what ships broken" list ships in the game too, since
  the game is how most players meet it.

## Deliberately not doing

- **Trimming vendored `default` down to the palette.** Decided 2026-09-02 by the
  author, and the ground is the one that settles it: **CodeBlock is expected to
  integrate the blocks it needs**, and at that point the game's `default` is not
  trimmed but deleted. Doing the trim first means hand-curating 9,744 lines of
  third-party code against a contract owned by the other repository, and then
  mirroring every palette change the mod makes — exactly the coupling this
  project refuses everywhere else, and for a saving that is size and boot noise
  rather than behaviour. `A13` stays open as a description of what is carried,
  not as work waiting to be done.

  **What would change it:** CodeBlock deciding *not* to take the blocks, or a
  release approaching with the boot log still opening on five red `NodeResolver`
  errors. `mapgen.lua` is the one piece that is safe to cut regardless — 2,492
  lines, the sole source of `B19`, and dead whoever owns the palette, since
  `cc_mapgen` disables every decoration, ore and biome it registers.

- **`settingtypes.txt` at the game root.** Every drone setting is CodeBlock's,
  and CodeBlock is its own ContentDB package; in the mod it works for a
  standalone install and appears under Mods. (C7)
- **Duplicating CodeBlock's lint and tests in this repository.** It has its own
  repo, CI and `.luacheckrc`; this one checks that the game *assembles*. The two
  therefore go red independently — check the repository you changed.
- **Restyling or linting `default`, `dye` and `wool`.** Vendored from Minetest
  Game; the CI lints only `cc_day`, `cc_mapgen` and `cc_security`.
- **Bumping the submodule on every mod commit.** The pointer names the CodeBlock
  release this game has adopted. Moving it is a decision, taken with the
  documentation update that goes with it.
- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias
  for `core`, with no deprecation warning and no removal date. Eight call sites
  are in the game's own mods. (C6 is the mod's finding, 54 sites)
- **Reusing the mod's phase numbers.** They are quoted in commit messages;
  lettered milestones here cannot be mistaken for them.
- **Keeping any agent guidance outside the repository.** Decided 2026-09-01, with
  the three-agent split — `project-manager` for the record, `code-expert` for the
  game's own code, `test-agent` for the gates and the evidence, each reading a
  skill in `.claude/skills/`. The `references` documentation is copied into the
  repository for the same reason, so a fresh clone carries it. Nothing an agent
  needs to know lives in a machine-local store.

---

2026-09-02 · codecube `c042364` (main) plus the `B49` fix · codeblock `2647228`
(master), the commit this game has adopted. `check_game.sh` and luacheck pass.
The game was played for the first time on 2026-09-01, over three rounds — that is
where `B47`, `B48` and `S8` came from, and what closed two of them. `B49` came
the day after, from reading `default` while scoping G3, and is the one fix here
that no world has confirmed. Everything through `35fa2a1` is at `origin/main`;
CI has not been read from here.
