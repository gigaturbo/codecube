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

- **Milestones here are lettered `G1`–`G6`.** They are not the mod's phases. The
  mod numbers its work `Phase 0`–`Phase 8` and those numbers appear in commit
  messages, so this file never says "Phase N" for anything of its own. Where a
  milestone is the game's share of a mod phase, it says which.
- **Finding ids are shared** with the mod's audit — a `B`, `S`, `C` or `A` number
  is allocated once across both, so it never means two things and is never
  renumbered. The nineteen in `AUDIT.md` are the game's; the rest are the mod's,
  as is the `F` feature series.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

**`G6` is written and committed — 5/5 — and its checking is partial: 1 of 6
passes, 2 are partial and 3 are unchecked.** Those are two states, not one.
Shaped with the author on 2026-09-04 and built the same day, it is now `f5f2385`
on branch `g6-world-limits`, with `B48` split out ahead of it as `ec02760`;
**both gates were re-run after committing** and neither runs a line of the game's
Lua. The clamp's spawn repair is the part that has been proven: `W9` passes in
full at `f5f2385`, all three cases, **with spawn out of range for at least one of
them** — the variant that forces the `get_node_or_nil` / `ignore` branch and the
`load_area` before the write, and the false pass the check was written to
exclude.

**So the next thing this game needs is still not more code but the rest of
`W4`–`W8` run in a world.** `W4` and `W8` were seen on the *uncommitted* tree and
keep their missing sha rather than being backdated onto `f5f2385`, because
`repair_spawn()` landed on the path `W8` exercises in between — `R6` is the
precedent. `W5` is the one that matters most: route one of `B50`, walking off the
generated edge, rests entirely on the wall and **nobody has walked to it**, so
`B50` closes on `W5` and on nothing else. The six decisions behind the shape are
recorded under the milestone and under *deliberately not doing*, so they are not
re-argued. `G6` is the only item here that is a feature rather than a defect.

Beside it, still outstanding: **one session in a world, `W5` first, then `W4`,
`W6`–`W8` and `R8`**.
`B48` is committed at `ec02760` and unseen — the override pass now strips six
digging groups from every registered node — so `R8` says whether the crack
animation is gone, and it now has a sha to be run against, and `R1`, `R4` and `R6` are what would catch that pass having broken
something wider on the way. Fold in `P3` (a cold boot log, now expecting
nothing), `P4` (the menu shows name, artwork and icon), `P1`'s boot half, and
`R3`, the thirty seconds that closes `R5`.

After that the only thing left before `G5` is `A7`, and its edit is upstream:
`codeblock` removes the duplicate, `cc_day` is the copy that survives, and this
repository's half is adopting the release and running `L3`.

The game was played on 2026-09-01 in three rounds and again on 2026-09-02:
fourteen of the checks then written run, twelve pass, two partial, and **every
restriction the game claims is now evidence rather than reading**. Those two
hours produced `B47`, `B48` and `S8`, none visible from reading the three `cc_*`
files. The details are in `PLAYTEST.md` and the lessons in `AUDIT.md`; the short
one is that **a fix is not evidence, the check is**.

The game still has no test suite, nothing automated reaches its behaviour, and
nothing here will.

## Milestones

In work order, which is why `G6` sits before `G5`: the letters are allocated when
a milestone is opened and never reused, and `G5` is shipping, so it stays last
whatever is opened after it.

### G1. Ship an honest, installable package — done (6/6)

Mostly the game's share of the mod's Phase 1; C15 and C20 landed much later and
sit here as the same subject.

- [x] Removed `max_minetest_version` from `game.conf`; `check_game.sh` now fails
  on a reinstated one. (C1 is the mod's counterpart)
- [x] Repointed image URLs from `master` to `main`. (C2)
- [x] Catalogued every bundled mod's licence in `THIRD-PARTY-LICENSES.md`,
  unified on AGPL-3.0-only, and gave the three `cc_*` mods their own. (C3, C4, C5)
- [x] Kept the release archive to what a player needs: **3.29 MB down to 1.93 MB
  zipped**, verified by `P2`. `menu/*.png` is kept — it is what the menu
  reads. (C15)
- [x] Wrote `CONTENTDB.md` for its own reader instead of shipping `README.md`
  verbatim, which broke six of ContentDB's own page rules at once. (C20)

### G2. Check the game, not the mod — done (2/2)

A CI that checks what this repository alone can check. The game's share of the
mod's Phase 3.

- [x] Added `scripts/check_game.sh` and this repository's CI; the mod took its
  own lint, specs and badge. (A14)
- [x] Deleted the vendored WorldEdit fork, with its arbitrary-code-execution
  module removed first, and the vendored `formspecs` submodule — which removed
  every deprecation warning the boot had. (B20)
- [x] Fixed `gen_cdb_json.sh` producing different output by line ending.
- [x] Added `cc_mapgen` (flat clean world) and `cc_day` (permanent noon).

### G3. Trim what the game vendors — deferred, and one part done instead (1/2)

Scoped on 2026-09-02 and the scoping is what changed it: reading `default`
against the palette turned up a behaviour defect nobody had looked for, and made
the case for the trim weaker rather than stronger.

- [x] Stop the world changing on its own. Two of `default`'s six ABMs rewrite
  palette nodes — roofing a grass floor destroys the grass — and ten saplings
  grow trees over what a program built. Fixed in `cc_security`, and confirmed by
  `R7`: the fix rests on undocumented behaviour, so a world was the only thing
  that could say it takes effect. (B49)
- **Deferred: trimming vendored `default` itself.** (A13) Grounds under
  *deliberately not doing*. Nothing a player meets waits on it, and it carries
  nothing either: `B19` and `B24` were closed directly on 2026-09-02 rather than
  left waiting behind it.

The counting was corrected while scoping: the palette is **122 nodes — 106 from
`default`, 15 from `wool`, plus `air`** — not the 124 and 108 first recorded. All
106 are in `nodes.lua`, so the removable set is whole files.

### G4. Make the game's own mods behave — done here (4/5), the fifth is G5's

The first playtest added three of these five, and all three are fixed. **Nothing
left here can be acted on**: the one open item is `A7`, whose edit is upstream and
whose game-side half is `G5`'s. What is outstanding is *checking* — `B48`'s fix is
written and `R8` has not been run.

- [x] `cc_day`: hide the sunrise texture too. `L1` passes on it. (B47)
- [x] Closed the bookshelf, twice. The first fix stopped items reaching the
  bookshelf; `R6` then found the real hazard was the other way, a tool dragged out
  of the hotbar into a row the player cannot reopen. The player may now move
  nothing at all, and `R6` and `R4` both pass. (S8)
- Drop `cc_day`'s duplicate of a block `codeblock` already runs. **The edit is
  upstream** and nothing in this repository changes; the game's half is adopting
  the release and running `L3`. Untidiness only — `L1` passes with the duplicate
  in place. (A7)
- [x] Stop `cc_security` clobbering two engine callbacks by direct assignment.
  Drops chain to the captured handler with an **empty list**; knockback stays a
  plain `return 0`. `last_mod = cc_security` is what stops a later mod taking
  either away. The chain is confirmed in a world by `R2`; the load-order half is
  untested by choice. The finding stays open for the every-node table walk. (A8)
- [x] Stop wool cracking under a punch it will not break: the override pass
  strips six digging groups from every node's `groups`, so the client has nothing
  to predict a dig from. **Written, both gates green, unverified in a world** —
  `R8` closes it. (B48)

### G6. Bound the world — committed at `f5f2385`: 5/5 written, checking partial (1 of 6 passes, 2 partial, 3 unchecked)

Shaped with the author on 2026-09-04. The world is unbounded in every way a
player meets it: `mapgen_limit` stops generation at roughly ±4080 but **nothing
marks the edge and nothing stops anyone reaching it**, and with no `fly` privilege
and damage off a player who walks off falls into ungenerated space forever,
unhurt and unable to return (`B50`). The world becomes a finite tray you build
in, and both limits are things you can see.

- [x] Ship the bounded slab: `minetest.conf` carries `mapgen_limit`, which is what
  CodeBlock already reads for the drone's bound, so **no mod load-order
  dependency exists** — the game's `minetest.conf` populates `core.settings`
  before any mod runs. `cc_mapgen` additionally forces it onto the world with
  `core.set_mapgen_setting('mapgen_limit', n, true)`, because `mapgen_limit` is
  stored **per-world** in `map_meta.txt` and an existing world would otherwise
  keep its old edge. A registered mapgen script clears everything below `y = 0`,
  lays the bedrock plane at `y = 0`, and fills the outermost generated columns
  from `core.get_mapgen_edges()` to full height. (B50)
- [x] Default the world to **1024**, a 2048×2048 field, down from 4096.
- [x] Add a game-root `settingtypes.txt` declaring `mapgen_limit` under Codecube's
  own heading. This extends `C7` rather than reversing it — see below.
- [x] Raise `min_minetest_version` from 5.4 to **5.9**, which is what the mapgen
  environment costs. **Recorded as 5.7 when the decision was taken, and wrong** —
  see decision 4.
- [x] Clamp the player into the world box, in `cc_security`: a globalstep run four
  times a second puts a connected player below `y = 0` or outside the horizontal
  edges from `core.get_mapgen_edges()` back at the spawn point. This is the second
  route into `B50` and the only thing the floor and the wall do not close — see
  decision 6. **Committed at `f5f2385`. Its ordinary case has been seen**: the
  author played the tree on 2026-09-04, dug a hole away from spawn, jumped in,
  and was put back on the ground — `W8`'s first half, recorded against that tree
  and to be re-run at `f5f2385`. (B50)

  **The same sitting found the second thing this fix nearly got wrong.** Standing
  at spawn after that rescue, the author cut the floor out from under themselves,
  so the hole was now exactly where the rescue lands: they were put back at
  `(0, 9, 0)` in mid-air, fell about 1.35 s through it, crossed `y = 0`, and were
  moved back — **airborne throughout, so they could never walk out**. It is the
  same shape as the `y = 1` fallback below: *the rescue destination was never
  checked for being a place you can stand.* `repair_spawn()` in
  `mods/cc_security/init.lua` now repairs it before anyone is moved — the node
  under the destination is made bedrock if it is not walkable, and the two nodes
  the player's body occupies are cleared if they are. It is called from the
  globalstep immediately before `player:set_pos(spawn)`. **No finding id**: the
  clamp had never been committed when this was found, so it was the change being
  wrong and caught before it shipped, and its record is this line. `W9` is its
  evidence and **`W9` passes at `f5f2385`** — all three cases, with spawn out of
  range for at least one of them, so the `ignore` branch and the `load_area`
  before the write were both exercised rather than skipped.

  **The mirror case is closed by the same repair, and that reverses a decision.**
  Until 2026-09-04 this file listed *protecting the spawn column from the drone*
  under *deliberately not doing*: a program could build a solid node there and the
  clamp would put a rescued player inside it, and closing it looked like buying a
  rule the engine does not keep on its own respawns. **That entry is gone**, on
  `code-expert`'s reasoning, weighed and accepted: `cc_security`'s *"only ever
  denies"* property is about the player's hands and not the map, and it is already
  spent the moment the clamp writes bedrock — so once you accept one write to
  guarantee a standable destination, refusing the other half leaves a state the
  clamp cannot escape, and being sealed inside rock with damage off is strictly
  worse than the loop. The scope is two nodes, at the rescue destination, only on
  a rescue tick.

  **The repair goes one node under the destination, not on the bedrock plane at
  `y = 0`.** Filling the plane would leave the player at the bottom of the shaft
  the program dug, unable to climb out and unable to dig — the same softlock by
  another route.

  **Two engine traps, either of which would have shipped a silent half-fix.**
  `minetest.get_node` reports `ignore` for an unloaded mapblock, which reads as an
  ordinary solid node, so the repair would have been skipped on exactly the tick
  that needs it — hence `get_node_or_nil` and an explicit `ignore` test. And
  `load_area` as well as the read, because `set_node` into a non-resident mapblock
  **silently does nothing**: checking without loading would have produced a repair
  that reads correctly and writes nothing. `emerge_area` was rejected as
  asynchronous — the player would arrive before the ground. Separately,
  **`walkable` defaults to true and node definitions leave it out**, so
  `registered_nodes["default:stone"].walkable` is `nil` and not `true`; a
  truthiness test would have read every ordinary solid node as walk-through and
  left the mirror case unfixed, which is why the tests are against `false`.

  **The spawn it falls back to is derived, and that is not tidiness.** With no
  `static_spawnpoint` — and this game sets none, so this is the normal path, not
  an edge case — the fallback is one node above `mgflat_ground_level`, read from
  `core.get_mapgen_setting`. The first version of the clamp wrote
  `{x = 0, y = 1, z = 0}` and called it *"one node above the bedrock plane at
  y = 0"*. That is wrong: `mgflat_ground_level` defaults to **8**, so the bedrock
  plane sits eight nodes under the surface and `y = 1` is inside solid stone. With
  damage off a rescued player would not have died — they would have been left
  embedded, which is worse than the fall being rescued from. Caught before it
  shipped, so it has **no finding id**; the record of a change that was wrong
  before it landed is this line, not `AUDIT.md`.

  **`core.get_spawn_level` was not used, though it is the API that looks right.**
  It needs the emerge manager, and mapgens initialise after every mod has loaded,
  so at mod load time it returns 1 — the same wrong number — and writes a line to
  `errorstream` on every boot.

**The six decisions taken, 2026-09-04, each closing an argument:**

1. **A thin slab, not a solid block.** Bedrock plane at `y = 0`, air below,
   `mgflat`'s ordinary fill above. Keeping the current fill and only
   adding walls generates thousands of nodes nobody reaches and leaves the floor
   invisible.

   **That fill is stone, not dirt or grass.** `cc_mapgen` sets `mg_flags` with
   `nobiomes`, and without biomes `mgflat` has no top or filler node to place, so
   it fills stone up to and including `mgflat_ground_level` — 8 by default and
   unchanged here. The surface a player stands on at `y = 8` is stone, and no
   `dirt` or `dirt_with_grass` exists in the world until a program places one.
2. **One number, not two.** The world is ±N on every axis and N is
   `mapgen_limit`, because **CodeBlock already reads `mapgen_limit`** as the
   drone's bound (`mods/codeblock/lib/commands.lua:49`, *"the engine's own edge of
   the world"*). A second game-side number would let the drone build where the
   player cannot walk, and keeping the two in step would be a change in the other
   repository. Accepted cost: the world cannot be wide and shallow — the floor is
   pinned by the game at `y = 0` rather than being configurable.
3. **A game-root `settingtypes.txt`**, for `mapgen_limit` only. A world size is
   the game's own subject, exactly like the light and the restrictions.
4. **The mapgen environment**, not the main thread, and therefore
   `min_minetest_version` 5.4 → **5.9**. `core.register_mapgen_script` and the
   mapgen-env `on_generated` run on the emerge threads, off the main thread,
   which is the whole point of choosing them.

   **Corrected 2026-09-04, the same day, on evidence: the decision was taken as
   5.7 and 5.7 was wrong.** The version came from the author's instruction and
   was not checked at the time. It was then read out of the shipped `lua_api` at
   each tag: `register_mapgen_script` is **absent** from 5.7.0's
   `doc/lua_api.txt`, which has no "Mapgen environment" section at all, absent
   from 5.8.0's `doc/lua_api.md`, and **present in 5.9.0** at line 6784. On 5.7
   or 5.8 the call is `nil`, `cc_mapgen` fails to load and the game does not
   start. `game.conf` reads `min_minetest_version = 5.9`. Recorded rather than
   overwritten, because a number silently changed is a number the next reader
   re-derives.

   The consequence for `C21` sharpens with it: `vector3`'s stated ceiling is 5.5,
   so the gap is **four minor versions, not three**.
5. **Default 1024.** 256 would put the walls inside `viewing_range = 300` so they
   were always in sight, too cramped for a large fractal; 4096's walls are about
   seven minutes' walk away and therefore theoretical. Shrinking the number
   shrinks the drone's bound with it, which is the point of decision 2.
6. **Clamp the player, in `cc_security`.** Found while building: the drone's
   bound is `mapgen_limit` and `cc_mapgen:bedrock` is an ordinary node to a
   program, so `remove` deletes a floor tile or a wall column. A player who walks
   into a program-made hole falls into unlit air below `y = 0` and then out of
   the bottom of the world — `B50` by a second route, which neither the wall nor
   `diggable = false` touches, because `diggable = false` binds the player and
   not a program. **Ruled by the author on 2026-09-04:** one rule, in
   `cc_security` — a connected player outside the world box is put back at the
   spawn point. It is the only thing that keeps the promise *regardless of what a
   program does to the floor*, and `cc_security` is already the mod whose job is
   what a player may do. The rejected alternatives are under *deliberately not
   doing*.

**One open question, put to the author on 2026-09-04 and unanswered.** The author
asked for limits *"they should be visible"*. The wall satisfies that; **the floor
does not.** `mgflat_ground_level` is 8, so the bedrock plane at `y = 0` is buried
eight nodes under the surface and is never seen in ordinary play — the only way
to it is a program clearing a shaft. Lowering `mgflat_ground_level` so the
surface sits on or near the plane is a one-line change in `cc_mapgen`. **Nothing
has been decided and nothing has been changed**; this is recorded as a question,
not as an omission.

**The in-world evidence this needs is `W4`–`W9` in `PLAYTEST.md`**, written on
2026-09-04: the floor at `y = 0` with air below; the wall unbroken and full height
with no gap at a chunk seam; the drone's own error naming 1024 rather than 4096,
which is the only thing proving `minetest.conf` reached `core.settings`; an
existing world re-bounded, which is the only thing `override_meta` buys; the clamp
putting a player back at spawn without also firing on someone standing
legitimately at the world's edge; and `W9`, the spawn repair.

**One passes, two are partial and three are `unchecked`.** `W9` passes at
`f5f2385`. `W8`'s ordinary case and, on the strength of it, `W4`'s floor were
observed on 2026-09-04 **against the uncommitted working tree, so neither result
names a commit**; that weakness is **kept rather than backdated**, because
`repair_spawn()` landed on the same rescue path between the sitting and the
commit and `R6` is what taught this project not to carry a result across a change
to the code it tested. Both are to be re-run at `f5f2385`. `W5`, `W6` and `W7`
have not been seen at all: **the wall, the drone's bound naming 1024, and an
existing world being re-bounded were not observed in that sitting** and are not
implied by it. Route one of `B50` is exactly `W5`, so it is the check that closes
the finding.

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

- **Route one is still unchecked: nobody has walked to the generated edge.** The
  wall closes it and `W5` is the only thing that could say so, so `G6` ships this
  unproven. Route two — falling through a hole a program made in the floor — is
  the one the clamp is for, and it is **verified where it was weakest**: `W9`
  passes at `f5f2385`, spawn out of range included. `W4` and `W8` are partial
  against an uncommitted tree and are to be re-run; `W5`–`W7` are
  `unchecked`. (B50)
- **The wall exists only in chunks generated after this change.** It is written
  by the mapgen callback, so terrain already emerged near the old edge of a
  pre-existing world keeps no wall and nothing regenerates it. A world made
  before `G6` is bounded only where it has not yet been visited.
- **`mapgen_limit` appears twice in the advanced settings menu** — under Mapgen
  from builtin, and under Content: Games → Codecube. Both write the same key so
  they cannot disagree, but the builtin entry shows the engine's default of 4096
  while ours shows 1024. Inherent to declaring an engine setting in a game's
  `settingtypes.txt`, which is decision 3; the alternative was not declaring it
  at all.
- **`mods/vector3/mod.conf` declares `max_minetest_version = 5.5`**, four minor
  versions below the 5.9 `G6` requires. The engine does not read it, so
  it blocks nothing at load; it is ContentDB metadata on a package this game
  depends on, and `vector3` is a pinned submodule this repository does not
  edit. (C21)
- `default` supplies 106 node definitions out of ~9,700 lines, and registers six
  ABMs, 3 LBMs and 101 craft recipes that nothing can reach. Deferred, not
  pending. (A13)
- `.gitattributes` decides what reaches a player and **no CI checks it**. A file
  added to this repository ships in the ContentDB archive unless a rule excludes
  it, and nothing local fails when one does. `P2` is the only thing that would
  catch it; it passed at `8b27f2f` and has to be re-run every time a tracked file
  is added — **`G6` adds two**, the root `settingtypes.txt` and
  `mods/cc_mapgen/mapgen_env.lua`, both of which a player should get. (C15)
- **A bookshelf still opens and shows the player their own inventory.** Nothing
  can be moved at all and `R6` confirms it, but the panel is there: the formspec
  is metadata on the placed node, not a field `cc_security` can override away. (S8)
- **Fixed but unseen: the wool crack.** Committed at `ec02760`; both gates are
  green and **neither runs a line of the game's Lua**, so nobody has watched a
  punch since the change. `R8` now has a sha to be run against. (B48)
- **Untested by choice: that `last_mod` is honoured at all.** Confirming it needs
  a second mod assigning the same globals, and none ships — so the author decided
  on 2026-09-02 not to build one. Recorded so it does not read as an
  oversight. (A8)
- The game has no test suite, and nothing automated reaches its behaviour. What
  is proven is what `PLAYTEST.md` records as run, and no more.
- Everything in the mod's "what ships broken" list ships in the game too.

## Deliberately not doing

- **Trimming vendored `default` down to the palette.** Decided 2026-09-02 by the
  author: **CodeBlock is expected to integrate the blocks it needs**, at which
  point the game's `default` is deleted rather than trimmed. Trimming first means
  hand-curating 9,744 lines against a contract owned by the other repository and
  then mirroring every palette change it makes, for a saving that is size and
  boot noise rather than behaviour. **What would change it:** CodeBlock deciding
  *not* to take the blocks. `mapgen.lua` is safe to cut regardless — 2,492 lines,
  dead whoever owns the palette. **New constraint from `G6`:** the trim must keep
  `mods/default/textures/default_obsidian.png`, which `cc_mapgen:bedrock` reuses
  so the wall ships no media of its own. Cut it and the world's edge renders as
  the unknown-node texture. Nothing checks this. (A13)

- **A `settingtypes.txt` entry for anything the drone does.** Every drone setting
  is CodeBlock's, and CodeBlock is its own ContentDB package; in the mod it works
  for a standalone install and appears under Mods. That ground is untouched. What
  changed on 2026-09-04 is the scope of the file, not the rule: `G6` adds a
  game-root `settingtypes.txt` declaring **`mapgen_limit` only**, because a world
  size is the game's own subject, exactly like the light and the restrictions.
  This extends C7's reasoning rather than reversing it, and a request to expose a
  drone limit here is still refused. (C7)

- **A ceiling on the world.** Rejected on 2026-09-04 with the rest of `G6`'s
  shape: the player has no `fly` privilege and cannot reach one, so it would be
  scenery rather than a limit anyone meets.

- **Separate width and depth for the world.** Rejected 2026-09-04 — see `G6`
  decision 2. One number, and it is `mapgen_limit`, because the drone already
  reads that setting.

- **Shipping `G6`'s `on_generated` on the main thread and moving it later.** The
  ordinary-environment `core.register_on_generated` is documented as *"Not
  recommended; as with other callbacks this blocks the main thread and is prone to
  introduce noticeable latency/lag"* — unacceptable in a game whose drone writes
  millions of nodes. Shipping it there first would write the callback twice and
  ship the stutter in between. The consequence is accepted honestly:
  `mods/codeblock/mod.conf` still declares `min_minetest_version = 5.4`, so the
  game and the mod it bundles now disagree — by five minor versions, since the
  game's floor is 5.9 and not the 5.7 first recorded. **The game's is binding for
  the game package; whether the mod follows is upstream's call.**

- **Guarding the mapgen call so the game still installs below 5.9.** Put to the
  author on 2026-09-04 and declined: `if minetest.register_mapgen_script then`
  would let the game install from 5.4 upward, but on anything below 5.9 it would
  **silently ship an unbounded world** — no floor, no wall, `B50`'s endless fall
  still present, and nothing telling the player why. Refusing to start was judged
  better than working wrongly. A third option, keeping the 5.9 requirement but
  raising a clear error naming the version, was declined too: the engine's own
  refusal to start already names it.

- **Clamping the player's `y` back to the floor plane instead of to spawn.**
  Rejected 2026-09-04 with `G6` decision 6: it puts the player straight back into
  the hole they fell through and oscillates. Teleporting to spawn loses your
  position, and that is the lesser cost against an endless fall.

- **Recording the program-made hole as a known limit instead of fixing it.**
  Declined 2026-09-04: the game's stated requirement is a world you cannot fall
  out of, and the failure is silent and unrecoverable — no damage, no `fly`, no
  way back.

- **Asking CodeBlock to refuse writes to `cc_mapgen:bedrock`.** Declined *for
  now*, 2026-09-04, on timing rather than on principle: nothing would land here
  until a release is adopted, and `G6` would ship with the hole. **It remains the
  cleaner boundary** — the game owns the world, the mod owns what a program may
  write — so it is a deferred option, not a novelty to re-propose.

- **Backdating a playtest result onto a later commit.** Decided 2026-09-04, when
  `G6` was committed and `W4` and `W8` still named an uncommitted tree: their
  code is byte-identical in `f5f2385` *except* on the rescue path, which is what
  `W8` exercises, so the sha is not written on and both are re-run instead. The
  general rule this settles: **a result carried across any change to the code it
  exercised is not evidence**, which is what `R6` cost this project once already.

- **Waiting for a release before the changelog records `G6`.** Decided
  2026-09-04: the entry is written now, in the same branch as the code, so it
  lands exactly when the code lands and cannot outlive it if the branch is
  dropped. `v1.0.0` is already an unreleased heading that accumulates.

- **Duplicating CodeBlock's lint and tests in this repository.** It has its own
  repo, CI and `.luacheckrc`; this one checks that the game *assembles*. The two
  go red independently — check the repository you changed.
- **Restyling or linting `default`, `dye` and `wool`.** Vendored from Minetest
  Game; the CI lints only `cc_day`, `cc_mapgen` and `cc_security`.
- **Bumping the submodule on every mod commit.** The pointer names the CodeBlock
  release this game has adopted. Moving it is a decision, taken with the
  documentation update that goes with it.
- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias
  for `core`, with no deprecation warning and no removal date.
- **Reusing the mod's phase numbers.** They are quoted in commit messages;
  lettered milestones here cannot be mistaken for them.
- **Keeping any agent guidance outside the repository.** Decided 2026-09-01, with
  the three-agent split — `project-manager` for the record, `code-expert` for the
  game's own code, `test-agent` for the gates and the evidence, each reading a
  skill in `.claude/skills/`. The reference documentation is copied into the
  repository for the same reason, so a fresh clone carries it.

---

2026-09-04 · codecube `f5f2385` on branch **`g6-world-limits`**, off `main` at
`578b364` — three commits: `5ca577f` moving the bundled Luanti reference into its
own skill, `ec02760` for `B48`, and `f5f2385` for the whole of `G6`
(`minetest.conf`, `game.conf`, a new root `settingtypes.txt`,
`cc_mapgen/init.lua`, a new `cc_mapgen/mapgen_env.lua` and
`cc_security/init.lua`) · codeblock `2647228` (master), the commit this game has
adopted; `mods/codeblock` is deliberately left unstaged, which is its normal
resting state. **Both gates were re-run on `f5f2385` after committing**:
`check_game.sh` ended `all game integration checks passed` with `.cdb.json
matches CONTENTDB.md`, and luacheck on the three `cc_*` mods printed nothing.
Neither runs a line of the game's Lua. CI has no run on this branch — the latest
is `578b364`. `origin/main` is at `35fa2a1` and thirteen commits after it are not
pushed. The record documents are not in any of the three commits; they are in the
working tree, to be committed naming `f5f2385`.

**`G6` is 5/5 written and committed, and its checking is partial**: `W9` passes
at `f5f2385`, `W4` and `W8` are partial against the uncommitted tree that
preceded it, and `W5`–`W7` are `unchecked`. Twenty-five playtest checks,
seventeen run: thirteen pass, `P1`, `R5`, `W4` and `W8` partial, and `W5`, `W6`,
`W7`, `L3`, `R8`, `P3`, `P4` and `P5` unrun. **`W4` and `W8` remain the only
results in this project recorded against no commit**, kept that way rather than
backdated; both are to be re-run at `f5f2385`.

This file is **528 lines against its own "under roughly 150"**, up from 499
before this pass, 440 before that, and 307 before `G6` was built. The question of
splitting the decision log into a `DECISIONS.md` is with the author and **still
unanswered**; nothing has been restructured. So is the question of lowering
`mgflat_ground_level` so the bedrock floor is visible.
