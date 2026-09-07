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

- **Milestones here are lettered `G1`–`G7`.** They are not the mod's phases. The
  mod numbers its work `Phase 0`–`Phase 8` and those numbers appear in commit
  messages, so this file never says "Phase N" for anything of its own. Where a
  milestone is the game's share of a mod phase, it says which.
- **Finding ids are shared** with the mod's audit — a `B`, `S`, `C` or `A` number
  is allocated once across both, so it never means two things and is never
  renumbered. The twenty in `AUDIT.md` are the game's; the rest are the mod's,
  as is the `F` feature series.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

**`G6` is done: 5/5 written and committed, and now 6/6 checked.** Those are two
states and this is the first milestone in the project to satisfy both. It was
shaped with the author on 2026-09-07 and built the same day; it is `f5f2385` with
the rescue reversed at `60259dd`, on branch `g6-world-limits`, with `B48` split
out ahead of it as `ec02760`, and **both gates were re-run green after every
commit** — neither of which runs a line of the game's Lua, which is why the
checking is the half that mattered. `W4`, `W5`, `W6`, `W7`, `W8` and `W9` all
pass at `60259dd`, so **`B50` is resolved on both of its routes**. Five findings
are open: `A7`, `A8`, `A13`, `C21` and **`C22`**, new on 2026-09-07 — three
original menu images that ship to every player with no licence stated anywhere.

**`G7` is open beside it, and it now holds three uncommitted changes.** On
2026-09-07 the author asked for a world edge that is *visible*, then for the
bedrock to be *"more black like in minecraft"*, then for the floor to be at 128.
The wall is a translucent `cc_mapgen:barrier` over a `cc_mapgen:bedrock` floor;
both nodes now draw from **this mod's own two textures** rather than borrowing
from `default`; and the stone surface stands at `mgflat_ground_level = 128`
instead of 8. **All three are written, both gates green, and none is committed**
— so none is in any sha, and `W10`–`W14` are five checks in `PLAYTEST.md` with
nothing to be run against. **Neither gate runs a line of this game's Lua**, so
green means the game still assembles and says nothing about how any of it looks
or behaves. No finding is opened by any of the three: `G6`'s wall was already
correct and `W5` says so, and a defect the same change introduced and caught was
never committed.

**`G6` and `G7` are both built against a four-line brief the author gave when
`G6` opened, and it is now quoted verbatim under `G6`.** Two of its four
requirements are done and checked, and two are written and unchecked — that is
the whole scoreline for both milestones and it is the shortest way to read them.
**It was written down on 2026-09-07 and not before**, having lived until then
only in a conversation that has since been compacted; the search for it in this
repository correctly found nothing, and one decision was briefly mis-recorded as
unattributed on that basis. No finding id — `G6` decision 8 has the reasoning.

**The next thing is one session in a world, and it is `G4`'s.** `R8` at
`ec02760` is what says the crack animation is gone; `B48`'s fix rewrites `groups`
on every registered node, a far wider blast radius than the `diggable` field
beside it, so `R1`, `R4` and `R6` are re-run with it to catch that pass having
broken something else, and `P3` because the same pass is what re-triggered a
deprecation warning once already. Five checks, one sitting. Fold in `P4` (the menu
shows name, artwork and icon), `P1`'s boot half, `R3` — the thirty seconds that
closes `R5` — and `P2`, owed since `G6` added two tracked files and nothing in CI
reads `.gitattributes`.

After that the only thing left before `G5` is `A7`, and its edit is upstream:
`codeblock` removes the duplicate, `cc_day` is the copy that survives, and this
repository's half is adopting the release and running `L3`.

**Twenty of the thirty checks now have a live result and eighteen pass.**
The game was played on 2026-09-01 in three rounds, again on 2026-09-02, and three
times on 2026-09-07 — the last of those being the whole `W` group. Every
restriction the game claims and every limit it now imposes is evidence rather
than reading. Those sittings produced `B47`, `B48` and `S8`, none visible from
reading the three `cc_*` files. The details are in `PLAYTEST.md` and the lessons
in `AUDIT.md`; the short one is that **a fix is not evidence, the check is**.

The game still has no test suite, nothing automated reaches its behaviour, and
nothing here will.

## Milestones

In work order, which is why `G6` and `G7` sit before `G5`: the letters are
allocated when a milestone is opened and never reused, and `G5` is shipping, so
it stays last whatever is opened after it.

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

### G6. Bound the world — done: 5/5 written and committed at `60259dd`, 6/6 checked

**The first milestone here to be both.** Written, committed with both gates
green, and then run in a world: `W4`–`W9` all pass at `60259dd`, which resolves
`B50` on both routes. Keeping the two states apart is the point of this file, and
this is the entry where they finally meet.

Shaped with the author on 2026-09-07. The world is unbounded in every way a
player meets it: `mapgen_limit` stops generation at roughly ±4080 but **nothing
marks the edge and nothing stops anyone reaching it**, and with no `fly` privilege
and damage off a player who walks off falls into ungenerated space forever,
unhurt and unable to return (`B50`). The world becomes a finite tray you build
in, and both limits are things you can see.

**The author's brief, verbatim, and it is what both `G6` and `G7` are built
against.** Written here on 2026-09-07 and **recovered from the session rather
than written down at the time** — see the note below, which is the point of
quoting it at all:

> Start a new feature thinking : world limits.
> - They should stop the player to go further
> - They should be visible
> - They can be customized in the settings (map size)
> - World has a Floor no player can fall under, visible (blocks like "bedrock"?),
>   height of map configurable (mapgen?)

**Four requirements, and the scoreline is clean:**

1. **Stop the player going further** — `G6`, **done and checked**. The wall, the
   floor, and the `cc_security` clamp for the hole a program digs. `W5`, `W8`
   and `W9` pass at `60259dd` and `B50` is resolved on both routes.
2. **They should be visible** — `G7`, **written and unchecked**. The floor and
   the wall exist and `W5` proves the wall stands, but a solid opaque face is not
   what the author meant by visible: this line is what made the barrier
   translucent, and it is the line that **overrode an instruction not to spend
   effort on appearance** when `glasslike_framed` turned out to render the wall
   near-invisible. `W10` is its check and has no sha to be run against.
3. **Customized in the settings (map size)** — `G6`, **done and checked**. The
   game-root `settingtypes.txt` declares `mapgen_limit`, `minetest.conf` defaults
   it to 1024, `cc_mapgen` forces it onto existing worlds. `W6` and `W7` pass at
   `60259dd`.
4. **A floor no player can fall under, visible, height of map configurable** —
   split. The floor and the un-fall-under-able half are `G6`, done and checked
   (`W4`, `W8`, `W9`). The configurable height is `G7`, **written and
   unchecked** — `mgflat_ground_level` as a setting at 128, with `W12`, `W13` and
   `W14`. The *visible* half of this line went the way requirement 2 did not: the
   author answered it by burying the floor deeper, and it is under *deliberately
   not doing*.

**This brief existed nowhere durable until now, and that is a failure of this
record rather than of the work.** It was said in conversation when `G6` opened,
it drove two milestones and settled at least two design questions, and the
conversation that held it has since been compacted — so for a stretch of
2026-09-07 the only copy was in a transcript no checkout carries. It was searched
for in this repository, correctly not found, and the setting it justifies was
briefly recorded as **unattributed** on that basis. **The rule it broke is
already written down** and did not need inventing: the project's memory for an
agent is the tracked Markdown, and what the author asks for goes into it, in the
repository, so a fresh clone carries it. **No finding id** — see the note at the
end of this milestone.

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
  times a second catches a connected player below `y = 0` or outside the
  horizontal edges from `core.get_mapgen_edges()`. This is the second route into
  `B50` and the only thing the floor and the wall do not close — see decision 6.
  **Committed at `f5f2385`, and where it puts the player was reversed at
  `60259dd` — see decision 7.** Its ordinary case had been seen twice before that,
  against the tree of 2026-09-07 and again at `f5f2385`, and neither observation
  survived the reversal — both watched a rescue to spawn. `W8` and `W9` were
  rewritten around the new destination and **both pass at `60259dd`**, `W9` across
  all four of its cases. (B50)

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
  evidence. Its first full pass, at `f5f2385`, was retired on 2026-09-07 with the
  destination it was about; `repair_spawn()` itself is unchanged and is now the
  fallback path only, so **`W9` case 4 at `60259dd` is what exercises it** — and
  case 4 is also the only case left that puts a write into possibly non-resident
  map, which is what the `ignore` branch and the `load_area` are for.

  **The mirror case was closed by the same repair, and that reverses a decision.**
  Until 2026-09-07 this file listed *protecting the spawn column from the drone*
  under *deliberately not doing*: a program could build a solid node there and the
  clamp would put a rescued player inside it, and closing it looked like buying a
  rule the engine does not keep on its own respawns. **That entry is gone**, on
  `code-expert`'s reasoning, weighed and accepted: `cc_security`'s *"only ever
  denies"* property is about the player's hands and not the map, and it is already
  spent the moment the clamp writes bedrock — so once you accept one write to
  guarantee a standable destination, refusing the other half leaves a state the
  clamp cannot escape, and being sealed inside rock with damage off is strictly
  worse than the loop. The scope is two nodes, at the rescue destination, only on
  a rescue tick. **Since `60259dd` that clearing happens only on the spawn
  fallback**: the ordinary path answers the same case by moving the player *up*
  the column instead, so it destroys nothing a program placed. The
  *deliberately not doing* entry about protecting the spawn column stays removed.

  **The repair no longer goes one node under the destination, because the
  destination is no longer spawn — decision 7, 2026-09-07.** This entry recorded
  the opposite with grounds, and the grounds were not wrong; they were outweighed.
  The old reasoning was: *filling the bedrock plane would leave the player at the
  bottom of the shaft the program dug, unable to climb out and unable to dig — the
  same softlock by another route*, so the rescue deliberately did **not** restore
  the plane. **That outcome is now accepted, and the ground for accepting it is
  what makes the trade sound: from a shaft you can point the drone at its wall and
  program your way out; from an endless fall you cannot.** A player standing in a
  hole with their drone is inconvenienced; a player falling out of the bottom of
  the world has nothing at all. The shaft is therefore a cost worth paying to keep
  the player where they were building.

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

**Eight decisions, all taken on 2026-09-07 — the first six while `G6` was
shaped, the seventh after playing it, the eighth about this record rather than
about the world — each closing an argument:**

1. **A thin slab, not a solid block.** Bedrock plane at `y = 0`, air below,
   `mgflat`'s ordinary fill above. Keeping the current fill and only
   adding walls generates thousands of nodes nobody reaches and leaves the floor
   invisible.

   **That fill is stone, not dirt or grass.** `cc_mapgen` sets `mg_flags` with
   `nobiomes`, and without biomes `mgflat` has no top or filler node to place, so
   it fills stone up to and including `mgflat_ground_level`. The surface a player
   stands on is stone, and no `dirt` or `dirt_with_grass` exists in the world
   until a program places one.

   **`G6` shipped that at the engine's default of 8, and `G7` raises it to 128**,
   so the "8" this decision was written against is no longer the number. The slab
   is thicker; that it *is* a slab, with air below `y = 0` and nothing generated
   there, is unchanged.
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

   **Corrected 2026-09-07, the same day, on evidence: the decision was taken as
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
   not a program. **Ruled by the author on 2026-09-07:** one rule, in
   `cc_security` — a connected player outside the world box is put back at the
   spawn point. It is the only thing that keeps the promise *regardless of what a
   program does to the floor*, and `cc_security` is already the mod whose job is
   what a player may do. The rejected alternatives are under *deliberately not
   doing*.
7. **The rescue keeps the player where they were, and spawn is only the
   fallback.** Asked for by the author on 2026-09-07 after playing it, verbatim:
   *"instead of returning to spawn point I just want the player to be placed at
   the same place but on a new block avoiding it to fall. Also, if the player
   would be blocked on stone, I need him teleported on the nearest block free
   above him."* Being sent to the origin because you fell into a hole beside what
   you were building is a punishment, and the drone is what dug the hole. **This
   reverses decision 6's destination, not decision 6** — the clamp, its place in
   `cc_security` and its 250 ms tick are unchanged. Committed at `60259dd`.

   **One algorithm answers both halves of the request**: clamp the column inside
   the wall, make the floor whole under it with bedrock, then scan up for the
   first height where both nodes a player occupies are clear, and put them there.
   A player who fell through the floor lands at the bottom of their own shaft; a
   player clamped back in from outside the wall walks up through the terrain and
   lands on top of it. `repair_spawn()` is untouched and is now reached only when
   a column has no room in it at all.

   **What the scan bound trades.** It reaches 64 nodes above
   `mgflat_ground_level`, capped at the top of the world — 72 in a default world,
   five mapblocks for the `load_area` that has to precede it. A player whose own
   column is solid the whole way up goes to spawn instead. So the case given away
   is building a 72-node solid pillar and falling out of the world at exactly its
   footprint, and **what it costs there is the old behaviour, not a softlock**.
   `PLAYTEST.md` `W9` case 4 is the only check that reaches it.

   **Nothing is cleared on the ordinary path.** Moving up rather than carving out
   means the rescue destroys nothing a program placed, and the one node it writes
   is the floor tile under the rescued column. That is a stronger version of the
   property decision 6 had already spent.

8. **The unwritten brief gets no finding id, and the reasoning is the same one
   this project already uses for a wrong check.** Decided 2026-09-07. A
   requirement that drove two milestones and existed only in a conversation is a
   real failure and the exact one the record exists to prevent — but ids here are
   `B` bugs, `S` sandbox, `C` compliance and packaging, `A` architecture, and all
   four describe **the game**. This is a defect in the record. Giving it an `A`
   would put a process failure into the game's architecture counts and into *what
   ships broken*, where it ships nothing, and it would be the first id in either
   audit that names no code. The precedent is settled and points the other way:
   *a wrong check is a defect in the record and is fixed in `PLAYTEST.md`*, not
   given an id. So the fix is the quotation above, and the cost of getting this
   wrong is that it was nearly lost. **What would change it** is the same failure
   recurring after this, which would make it a pattern rather than an incident.

   **The guidance was already correct and was simply not followed**, which is
   why nothing was added to `CLAUDE.md` or to any agent definition for it. The
   `project-manager` definition already says the eight documents are the
   project's memory and that what the author asked for is written into them, in
   the repository, so a checkout on another machine carries it. Restating it
   would be saying it twice to the same reader.

**One open question, put to the author on 2026-09-07 — and answered the same day
in the opposite direction from what it assumed.** The question was whether to
*lower* `mgflat_ground_level` so the bedrock plane at `y = 0` sits on or near the
surface and the floor becomes as visible as the wall. The author instead asked
for the floor to be at **128**, and `G7` raises `mgflat_ground_level` from 8 to
that. So the plane is now a hundred and twenty-eight nodes down rather than
eight: **more out of sight than before, not less.** The question is closed — see
*deliberately not doing* — and it is closed by the number moving the other way,
not by anyone arguing the visibility case down. **What would change it is the
author saying the floor should be seen**, which they have not been asked again
since raising the number.

**The in-world evidence is `W4`–`W9` in `PLAYTEST.md`, and all six pass at
`60259dd`** — recorded 2026-09-07: the floor at `y = 0` with air below; the wall
unbroken and full height with no gap at a chunk seam; the drone's own error
naming 1024 rather than 4096, which is the only thing proving `minetest.conf`
reached `core.settings`; an existing world re-bounded, which is the only thing
`override_meta` buys; the clamp firing on a fall and **not** on someone standing
legitimately at the world's edge; and `W9`, where the rescue puts them, across
four cases. **`B50` is resolved.**

**Three of the six had never been run at all before that sitting.** `W5` is route
one of `B50` — nobody had ever walked to the edge, and the finding closed on it.
`W6` and `W7` were the drone's bound and an old world re-bounded, each the only
route to seeing its half of decision 2 fail. `W8` and `W9` had passed at
`f5f2385` and **their results were retired on 2026-09-07 with the destination they
described** — decision 7 — rather than backdated; they were re-run instead, `W9`
including the two cases the rewrite added, a column blocked by terrain and one
solid past the scan bound. `W4`'s partial against an uncommitted tree was likewise
re-run rather than given a sha it had not been seen at. **The rule cost two
re-runs and bought six results that name the code in the tree.**

### G7. Make the world something to be in — written, uncommitted, unchecked (0/3)

Opened 2026-09-07, after `G6` closed. **Not a defect in `G6` and no finding is
allocated for it**: the wall `G6` built is a correct barrier, `W5` proves it
stands unbroken and full height, and nothing about it is wrong. What the author
wants changed is what it *looks* like — *the world edge should be visible, and a
solid opaque wall is not what they wanted to look at.* That is a new goal, so it
gets its own letter rather than reopening a milestone that is 5/5 written and
6/6 checked; letters are allocated when a milestone opens and are never reused,
and `G5` stays last because it is shipping.

**Widened on 2026-09-07, the same day it opened, and its title with it.** It was
*"make the world's edge something to look at"* and one item. Two more changes
arrived in the same working tree before anything was committed: the game's own
textures for both bound nodes, and a world 128 nodes deep instead of 8. The
textures are plainly this milestone's. The depth is not about the *edge* at all —
it is about what the world is like to stand in and dig into — so the milestone
was widened rather than a new letter opened, on the grounds that all three are
appearance-and-feel changes, none is a defect, none opens a finding, and they are
one uncommitted tree that has to be checked together. **What would have justified
a new letter is the depth arriving on its own**, and it did not.

**`G6`'s one open question is answered here, in the direction nobody proposed.**
It asked whether to *lower* `mgflat_ground_level` so the bedrock floor becomes as
visible as the wall. The author raised it instead. The floor is now buried
deeper, and the question is recorded under *deliberately not doing* rather than
left open.

- [ ] Split the bounds into two nodes: `cc_mapgen:bedrock` stays the **floor** at
  `y = 0` — including the outermost column at that layer, so the wall stands on a
  one-node opaque skirt — and stays what `cc_security`'s rescue writes under a
  player; a new `cc_mapgen:barrier` becomes the **wall** above it, plain
  `glasslike`. `mapgen_env.lua` resolves a second content id and the two wall
  loops write it. **Written by `code-expert`, both gates green — and it is none
  of committed, released or seen.** `W10` is its check, and it was the first
  entry in `PLAYTEST.md` with no sha at all to be run against.

  **This line said *"no new media: both textures were already vendored in
  `default`"*, and the next item reverses that.** Recorded rather than edited
  away, because the borrowed-texture constraint it created was written into
  `A13` and into *deliberately not doing* and had to be taken back out of both.

- [ ] Ship the game's own textures for both bound nodes, 16×16, in a new
  `mods/cc_mapgen/textures/`. Asked for by the author on 2026-09-07: the bedrock
  should be *"more black like in minecraft"*, and the obsidian it borrowed is
  blue-tinted. `cc_mapgen_bedrock.png` is a mottle of six neutral greys in the
  range 8–51, blurred with a **wrapping** kernel so that a large floor shows no
  tiling grid; `cc_mapgen_barrier.png` keeps the 1px-border, transparent-centre
  geometry that makes plain `glasslike` outline every node face.
  `use_texture_alpha = "clip"` stays correct and `code-expert` confirmed it by
  decoding both files back. **Written, both gates green, not committed, and never
  rendered by anybody.** `W11` is the check, and the tiling grid is the thing
  most likely to look wrong.

  **The same request came with a second one — remove `default`, `wool` and
  `dye` — and the author declined it after seeing the cost.** CodeBlock's palette
  is 106 `default:*` names plus 15 `wool:*`, and `mods/cc_mapgen/mod.conf` hard-
  depends on all three; the answer was *"leave it for now"*. So `A13` keeps
  exactly the scope it had. What this change buys `A13` is smaller and real: the
  trim no longer has to keep two `default` textures alive for the game's own
  bounds.

- [ ] Raise `mgflat_ground_level` from the engine's 8 to **128**, and make it a
  setting rather than a constant, mirroring `mapgen_limit`: a `settingtypes.txt`
  entry (`int 128 1 512`), a default in `minetest.conf`, and a forced
  `core.set_mapgen_setting('mgflat_ground_level', n, true)` in `cc_mapgen`. The
  bedrock floor stays at `y = 0`, so the number is also how much stone there is
  to dig into. **Written, both gates green, not committed.** `W12` and `W13` are
  its checks and `W14` is the rescue under it.

  **Both halves are the author's.** The number came from *"change height of floor
  to 128"* — three readings were possible and 128 is the one they chose. Making
  it a setting implements the fourth line of the feature brief they opened `G6`
  with: *"height of map configurable (mapgen?)"*, quoted in full under `G6`
  below. So this is the last of that brief's four requirements to be built, and
  it is not a decision anyone took on the author's behalf.

  **This entry said the opposite for part of 2026-09-07, and the correction is
  worth keeping.** It read *"the ground given for it does not check out"* and
  marked the setting **unattributed**, because the requirement was searched for
  in this repository and is not in it — `git log -S` across every ref finds no
  commit that added or removed the string. The search was sound and the
  conclusion from it was wrong, because **the requirement never lived in the
  repository at all**. It was said in conversation, and nobody wrote it down. See
  `G6`.

  **The map-meta trap is the reason this is not a one-liner, and it was verified
  rather than assumed.** `MapgenFlatParams::writeParams` at 5.9.0 writes every
  `mgflat_*` key into a world's `map_meta.txt`, a real `map_meta.txt` on this
  machine confirms it, and `MapSettingsManager::setMapSetting`'s `override_meta`
  branch is generic rather than restricted to `MapgenParams` fields. So without
  the force an existing world keeps the surface it was created with for ever.
  That is the same mechanism `W7` proved for `mapgen_limit`, and `W13` is the
  check that it holds for this key too — **`code-expert` calls it the thing most
  likely to be wrong and the whole point of the change.**

  **One real defect was introduced and caught inside this change, and it gets no
  finding id.** `cc_security` derived both its spawn fallback and its `scan_top`
  from `(ground or 8)`. With the game's default now 128 that constant had become
  the wrong fallback — a rescued player would have been put at `y = 9`, inside a
  hundred and twenty nodes of solid stone, which is the same shape as the `y = 1`
  fallback `G6` caught before it shipped. Collapsed to a single `or 128` at the
  definition. **Ruled 2026-09-07: no id.** What gets an id is a defect in
  committed code, and this one was never committed; the record of a change that
  was wrong before it landed is this line. `W14` is the check that would have
  caught it in a world.

  **A cost note, weighed and deliberately not acted on.** The rescue's
  `load_area` column grows from 5 mapblocks (~80 kB) to 13 (~210 kB), because it
  now spans `y = 0` to 193, and the scan reads up to ~128 more nodes before it
  finds the surface. Bounded, and at most four times a second per out-of-box
  player. `code-expert` left the behaviour alone and suggests the scan could
  start at the surface and fall back to a full-column scan. That is a `TODO.md`
  line, not a finding: nothing is wrong, it is merely larger than it needs to be.

  **A cost that was claimed and does not exist, corrected here so it is not
  re-raised.** Sixteen times the solid volume was flagged in conversation as
  something to watch. **That was wrong.** `MapgenFlat::generateTerrain` writes
  every node of a mapchunk whatever the ground level is, so emerge time is
  identical; the blocks between `y = 0` and 128 were already generated and stored,
  as uniform air rather than uniform stone, and both compress to tens of bytes.
  There is **no volume cost and no reason to lower 128**. Nothing in this file or
  in `TODO.md` had picked the concern up, so nothing had to be removed.

**Two things about the barrier that a later change would re-break, recorded here
because they are the reason this milestone is not a one-liner.** The drawtype is
plain `glasslike` and must stay so: `glasslike_framed` draws its faces from a
second tile and would leave the wall all but invisible, and
`glasslike_framed_optional` follows a client-side "Connected Glass" setting this
game cannot decide. And `paramtype = "light"` with `sunlight_propagates` come as
a pair — the engine derives `light_propagates` from `paramtype`, which defaults
to `"none"`, so a see-through wall without them casts a shadow band with no
visible cause. `W10` is written to catch both by sight.

**The two new textures are licensed AGPL-3.0-only, and that is a decision the
author may want to reverse.** Taken by `code-expert` on 2026-09-07 and recorded
in `mods/cc_mapgen/license.txt` under *License of media*. The convention for game
art is **CC BY-SA 4.0**, which would let other games reuse the textures; AGPL was
chosen to keep Codecube single-licence, so that `THIRD-PARTY-LICENSES.md`'s row
for the three `cc_*` mods stays true without qualification and no
`media_license` question is raised on ContentDB. **The cost is that the artwork
is not reusable outside an AGPL work**, which is a stronger restriction than the
game needs and than most Luanti art carries. **Reversible**: two lines in one
`license.txt`, plus a `media_license` field if ContentDB is to state it. Flagged
here rather than settled, because the choice is the author's — it is about what
other people may do with the game's media.

### G5. Adopt CodeBlock 1.0.0 and ship — not started

**The submodule pointer is currently off the release track, not merely behind
it.** `CLAUDE.md` says the pointer names the CodeBlock release this game has
**adopted**, so a pointer that lags a release is correct and expected. This one
is a different thing: `git ls-tree HEAD mods/codeblock` gives **`2647228`**,
which is **not a tagged release at all** — it is a commit off `master`, pinned
before this project settled on following releases. Upstream has published tags
since, the newest being **`v0.7.3`**.

So the game has adopted *a commit*, and the policy says it should have adopted
*a release*. **Nothing is broken by it** — the game assembles, `P1`'s clone half
passed on this pointer, and moving it is a decision taken with the documentation
update that goes with it. But *"the pointer lags upstream, which is correct"* is
not an accurate description of where it stands, and `G5` is where it is put back
on the track: move to a tag, not to the tip of `master`. Read both numbers from
`git ls-tree HEAD mods/codeblock` and `git tag` inside the submodule, never from
upstream's `HEAD`.

**The working tree's `mods/codeblock` is at `7dbe18f`, ahead of the committed
pointer, and is deliberately left unstaged.** `git status` shows it modified;
that is the normal resting state and nothing to fix.

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

- **A rescued player is left standing in the shaft they fell down**, and that is
  the design, not a defect — decision 7. Getting out means pointing the drone at
  the shaft wall, so it needs a working program and it is not a way out a player
  has without one.
- **A player whose own column is solid for 72 nodes is still sent to spawn.** The
  rescue's scan gives up 64 nodes above `mgflat_ground_level`, so a solid pillar
  that tall, fallen out of at exactly its footprint, gets the old behaviour rather
  than a place nearby. Accepted with decision 7; `W9` case 4 is its check.
- **The wall exists only in chunks generated after this change.** It is written
  by the mapgen callback, so terrain already emerged near the old edge of a
  pre-existing world keeps no wall and nothing regenerates it. A world made
  before `G6` is bounded only where it has not yet been visited. `W7` confirms
  the *limit* moves on such a world; the missing wall in already-visited chunks is
  what it does not cover, and nothing does.
- **An existing world's surface moves only where it has not been generated.**
  `G7` forces `mgflat_ground_level = 128` onto every world, so an old world's
  edge setting and its surface setting both change on opening — but chunks
  already emerged keep the terrain they have. A world played at ground level 8
  gets a step where the old ground meets the new. Same mechanism as the missing
  wall above, same absence of any check for it beyond `W13`.
- **Three original images ship with no licence stated anywhere.**
  `menu/background.png`, `menu/header.png` and `menu/icon.png` reach every player
  — `P2` confirms all three are in the archive — and neither
  `THIRD-PARTY-LICENSES.md` nor any `license.txt` names a licence for them, while
  `.cdb.json` carries `license` and no `media_license`. (C22)
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
  dead whoever owns the palette. **The texture constraint `G6` added here is
  gone, on 2026-09-07.** For one day the trim had to keep
  `default_obsidian.png` and `default_obsidian_glass.png` alive, because the
  world's bounds borrowed them. `G7` gives `cc_mapgen` its own two textures, so
  **nothing in this game names either file any more** and the trim's scope is
  what it was before `G6`. Recorded rather than deleted, because a constraint
  that appears and vanishes inside a week is one a future reader would otherwise
  re-derive from nothing. (A13)

  **Re-scoped and re-declined on 2026-09-07.** The author asked, while the
  textures were being made, to remove `default`, `wool` and `dye` outright. Shown
  that CodeBlock's palette is 106 `default:*` names plus 15 `wool:*`, and that
  `mods/codeblock/mod.conf` hard-depends on `default` and `wool` — `dye` is there
  because `wool` requires it — they answered **"leave it for now"**. **The
  dependency named in the exchange was `cc_mapgen`'s and that was wrong**: none
  of the three `cc_*` mods declares a `depends` line at all, and the hard
  dependency is the submodule's. The conclusion is unchanged and if anything
  firmer: removing `default` or `wool` stops the bundled mod loading. So the
  deferral above is now the author's second decision on the
  same subject, five days after the first, and on fuller information.

- **A `settingtypes.txt` entry for anything the drone does.** Every drone setting
  is CodeBlock's, and CodeBlock is its own ContentDB package; in the mod it works
  for a standalone install and appears under Mods. That ground is untouched. What
  changed on 2026-09-07 is the scope of the file, not the rule: `G6` adds a
  game-root `settingtypes.txt` declaring **`mapgen_limit` only**, because a world
  size is the game's own subject, exactly like the light and the restrictions.
  This extends C7's reasoning rather than reversing it, and a request to expose a
  drone limit here is still refused. (C7)

- **Lowering `mgflat_ground_level` so the bedrock floor is visible.** Put to the
  author on 2026-09-07 as `G6`'s one open question, on the grounds that they had
  asked for limits *"they should be visible"* and the wall satisfied that while
  the floor did not. **Answered the same day by the number moving the other
  way**: the author asked for the floor at 128, so the surface rose from 8 and the
  plane at `y = 0` is now a hundred and twenty-eight nodes down instead of eight.
  Whatever else 128 buys, it settles this — the floor is emphatically not going
  to be seen in ordinary play, and a world you dig deep into was wanted more than
  a floor you can look at. **What would change it:** the author saying the floor
  should be visible after all. They have not been asked again since choosing 128,
  so this is a decision inferred from an instruction rather than one stated, and
  it is the weaker kind.

- **Making the bedrock floor's `y` configurable.** Not proposed and not built.
  The floor stays pinned at `y = 0` by `G6` decision 2; what `G7` makes
  configurable is the **surface** above it, which is the same freedom by the
  other end and costs no second number.

- **A ceiling on the world.** Rejected on 2026-09-07 with the rest of `G6`'s
  shape: the player has no `fly` privilege and cannot reach one, so it would be
  scenery rather than a limit anyone meets.

- **Separate width and depth for the world.** Rejected 2026-09-07 — see `G6`
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
  author on 2026-09-07 and declined: `if minetest.register_mapgen_script then`
  would let the game install from 5.4 upward, but on anything below 5.9 it would
  **silently ship an unbounded world** — no floor, no wall, `B50`'s endless fall
  still present, and nothing telling the player why. Refusing to start was judged
  better than working wrongly. A third option, keeping the 5.9 requirement but
  raising a clear error naming the version, was declined too: the engine's own
  refusal to start already names it.

- **Clamping the player's `y` back to the floor plane instead of to spawn.**
  Rejected 2026-09-07 with `G6` decision 6, because a bare `y` clamp puts the
  player straight back into the hole they fell through and oscillates. **Still
  rejected, and decision 7 is not it**: `60259dd` keeps the player's column but
  makes the floor whole under them and scans *up* for room, so there is no hole
  left to fall through and nothing to oscillate against. What changed on
  2026-09-07 is that losing your position was judged the greater cost after all —
  the reasoning is under `G6` decision 7, not here.

- **Recording the program-made hole as a known limit instead of fixing it.**
  Declined 2026-09-07: the game's stated requirement is a world you cannot fall
  out of, and the failure is silent and unrecoverable — no damage, no `fly`, no
  way back.

- **Asking CodeBlock to refuse writes to `cc_mapgen:bedrock`.** Declined *for
  now*, 2026-09-07, on timing rather than on principle: nothing would land here
  until a release is adopted, and `G6` would ship with the hole. **It remains the
  cleaner boundary** — the game owns the world, the mod owns what a program may
  write — so it is a deferred option, not a novelty to re-propose.

- **Backdating a playtest result onto a later commit.** Decided 2026-09-07, when
  `G6` was committed and `W4` and `W8` still named an uncommitted tree: their
  code is byte-identical in `f5f2385` *except* on the rescue path, which is what
  `W8` exercises, so the sha is not written on and both are re-run instead. The
  general rule this settles: **a result carried across any change to the code it
  exercised is not evidence**, which is what `R6` cost this project once already.
  **Applied against this project's own record on 2026-09-07**: `W8` and `W9` had
  *passed* at `f5f2385`, and decision 7 changed the code both were about, so both
  passes were removed rather than kept. The rule costs something only when it is
  applied to a result you would rather keep.

- **Splitting this file's decision log out into a `DECISIONS.md`.** Put to the
  author three times and never answered, so on 2026-09-07 it is **treated as
  declined by silence** and is not to be proposed again. The consequence is
  accepted rather than argued away: this file runs well over its own *"under
  roughly 150 lines"*, and the decision log is why. Nothing has been
  restructured. What would change it is the author saying so.

- **Waiting for a release before the changelog records `G6`.** Decided
  2026-09-07: the entry is written now, in the same branch as the code, so it
  lands exactly when the code lands and cannot outlive it if the branch is
  dropped. `v1.0.0` is already an unreleased heading that accumulates.

- **Allocating a `B`/`S`/`C`/`A` id here for a defect in CodeBlock.** Decided
  2026-09-07, when reading the mod turned up two: `check_inside_world` is applied
  to the drone's *position* and never to a shape's extent, and the bound it
  checks is the raw `mapgen_limit` rather than `get_mapgen_edges()`, which is at
  least a mapchunk further out than the wall. Both are real and both let a
  program build past the world's edge. **They are still not this audit's**: ids
  are shared across the two records and allocating one here would put the mod's
  work in the game's counts and its "what ships broken". They are carried as
  `TODO.md` lines to raise upstream instead. What would change it is a defect in
  the *game* caused by the mod's behaviour, which neither of these is.

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

2026-09-07 · codecube `93b8ea1` on branch **`g6-world-limits`**, off `main` at
`578b364` — eight commits: `5ca577f` moving the bundled Luanti reference into its
own skill, `ec02760` for `B48`, `f5f2385` for the whole of `G6`
(`minetest.conf`, `game.conf`, a new root `settingtypes.txt`,
`cc_mapgen/init.lua`, a new `cc_mapgen/mapgen_env.lua` and
`cc_security/init.lua`), `3090b8a` recording them, `60259dd` for decision 7 —
the rescue that keeps the player in their own column (`cc_security/init.lua`
only, +98 −39) — `22fe840` recording that reversal and retiring the two results
it invalidated, and `93b8ea1`, the tip, closing `B50` on the whole `W` group ·
codeblock `2647228` (master), the commit this game has adopted;
`mods/codeblock` is deliberately left unstaged, which is its normal resting
state.

**The working tree is not `93b8ea1`, and that is the important part of this
footer.** It carries the whole of `G7`, uncommitted, across seven files:
`mods/cc_mapgen/init.lua`, `mods/cc_mapgen/mapgen_env.lua` and
`mods/cc_mapgen/license.txt`; two **new, untracked** files in a new directory,
`mods/cc_mapgen/textures/cc_mapgen_bedrock.png` and `cc_mapgen_barrier.png`;
`settingtypes.txt` and `minetest.conf` for the surface height; and
`mods/cc_security/init.lua` for the fallback that moved with it.
`.claude/skills/code-standards/SKILL.md` carries what `code-expert` wrote beside
them. **Both gates were run by `code-expert` on that tree after its final
edit**: `check_game.sh` ended `all game integration checks passed` and luacheck
on the three `cc_*` mods printed nothing at all. **Neither runs a line of this
game's Lua**, so green here means the game still assembles and says nothing
whatever about how the world now looks, how deep it is, or where a rescue puts
anybody. The record documents for this pass are in the working tree beside them,
to be committed together — so `W10`–`W14` get their sha from that commit and not
before.

**`G6` is done on both counts: 5/5 written and committed, 6/6 checked.** The
author ran the whole `W` group at `60259dd` and reported `W4`, `W5`, `W6`, `W7`,
`W8` and `W9` all pass, which resolves `B50` on both routes and leaves `A7`, `A8`,
`A13`, `C21` and now `C22` as the open findings — **and none of `G7`'s three
changes adds one**, because an appearance the author wants changed is not a
defect in the wall that was built, and the one real defect the pass introduced
was caught before it was committed. `C22` is unrelated to `G7` and pre-existing:
the menu artwork has shipped unlicensed since the beginning. Thirty playtest
checks, **twenty with a live result: eighteen pass**, `P1` and `R5` partial, and
`L3`, `R8`, `W10`, `W11`, `W12`, `W13`, `W14`, `P3`, `P4` and `P5` unrun. **No result in this project is recorded against a tree
instead of a commit any more** — `W4` was the last, and it was re-run rather than
backdated. Nothing was re-run for the playtest and nothing was owed: no code
changed, and both gates were last green on `60259dd`.

**`G7` is open and holds three uncommitted changes: the barrier, the game's own
textures, and a world 128 deep.** All three were written by `code-expert` on
2026-09-07, and after the last of them `check_game.sh` ended *all game
integration checks passed* and luacheck on the three `cc_*` mods printed nothing.
**Neither gate runs a line of this game's Lua, and none of the three is
committed**, so each is *written and gated* and nothing more: not released, not
seen, not in any sha. `W10`–`W14` are their checks and are five entries in
`PLAYTEST.md` with no commit to be run against. **`W12`, `W13` and `W14` matter
more than the appearance ones**: they are the world's depth reaching a new world,
an existing world, and the rescue that has to know where the surface is.

**One real defect was introduced and caught inside this pass and carries no id.**
`cc_security`'s `(ground or 8)` fallback became wrong the moment the game's
default was 128 — a rescue on that path would have put a player at `y = 9`, inside
solid stone. It was never committed, so it is the change being wrong rather than
a defect in the game; the record is the `G7` entry above, and `W14` is what would
have caught it in a world. Two prior defects in `G6` were ruled the same way, so
this is the third application of the same rule and not a new one.

The game's own Lua is **177 lines** across four files — `cc_day` 7,
`cc_mapgen` 32 + 37, `cc_security` **101** — counting neither blanks nor
comments, and **464 lines in all**. It was 173 and 439 before this pass, and 160
and 397 before the barrier node. The tree also gains **a new directory and two
new tracked files**, `mods/cc_mapgen/textures/`, which is what makes the owed
`P2` re-run owed harder: `code-expert` confirmed by hand with `git check-attr`
that neither texture is `export-ignore`d, so both ship — but that rests on one
manual run and on no gate at all (`C15`).

This file is **924 lines against its own "under roughly 150"**, up from 683
before this pass, 603 before that, 597 before that, 528 before that and 307
before `G6` was built. It grew by two hundred and forty because `G7` went from one
item to three, because **the author's four-line world-limits brief was finally
written down** — it had driven `G6` and `G7` from a conversation that has since
been compacted — and because two questions closed inside it: `A13`'s borrowed-texture
constraint, which appeared with `G6` and vanished with `G7`, and **the question
of lowering `mgflat_ground_level`, which is now answered** — the author raised the
number instead, so the floor is buried deeper than ever and the question sits
under *deliberately not doing* rather than open. The `DECISIONS.md` split stays
closed, declined by silence, and nothing has been restructured.
