# Playtest — Codecube (the game)

The manual checks nothing else here can reach. **This game has no test suite at
all** — `scripts/check_game.sh` verifies that the game *assembles*, not that it
behaves, and luacheck reads three files without running them. So every claim
about what the game actually does in a world rests on reading three short Lua
files, and this document is where that gap is written down rather than
rediscovered from prose in `ROADMAP.md` and `AUDIT.md`.

The mod's own manual checks are separate and are the larger set:
`mods/codeblock/PLAYTEST.md`. Nothing here re-checks the drone, the editor, the
sandbox or the API. What is checked here is the world those run in, and what a
player gets when they install the package.

`PLAYTEST.md` carries its own `export-ignore` line in `.gitattributes`, so this
file never ships to a player.

## How to record a result

Each check carries a **Result** line. Leave it as `unchecked` until someone
actually does it in a running world, then replace it with:

```
Result: pass — <commit> · engine <version> · <YYYY-MM-DD> — <one line of detail>
```

`fail` and `partial` take the same shape. **Always keep the commit and the
date**: a pass recorded three milestones ago is not evidence about today's code,
and the point of the line is that a stale pass reads as stale rather than as
current. A `fail` is not a finding — report it and let `AUDIT.md` allocate or
widen an id.

Reference the finding id in brackets after the title where there is one; the
reasoning is in `AUDIT.md` under that id. A check with no id exists because
nothing has gone wrong there yet and nothing proves it right either.

Groups are lettered **W** (world), **L** (light), **R** (restrictions) and **P**
(packaging, boot and install). Those letters are deliberately none of `B`, `S`,
`C`, `A` or `F`, so a check id can never be read as a finding id, and none of
`G1`–`G6`, the milestone lettering in `ROADMAP.md`.

## Where it stands

**Six checks are new on 2026-09-04 — `W4`–`W9`, all `B50`.** They are the whole
of the in-world evidence for `G6`, the bounded world: the floor, the wall, that
the drone's bound followed the number, that an existing world is re-bounded, that
a player who falls through a hole a program made is put back, and that the place
they are put back into is one they can stand in. **The code for all six is
committed**, on branch `g6-world-limits`, tip `60259dd`, with both gates re-run
green after committing — and **neither gate runs a line of the game's Lua**.

**`W8` and `W9` were rewritten on 2026-09-07, and both passes were retired rather
than carried forward.** `60259dd` reverses where the rescue puts a player: no
longer the spawn point, but their own column, its floor made whole under them and
the first height in it they fit. That is a design reversal the author asked for
after playing — **`W8` and `W9` had both passed on the code it replaces, so
nothing was wrong; the behaviour was unwanted** — and it carries no finding id.
Its record is `ROADMAP.md`'s `G6` entry. But a destination that changed is a
destination two checks were written around: `W8`'s pass is now inverted, `W9`'s
case 2 no longer reaches the code it tested and its case 3 has become vacuous.
**Backdating a result onto a later commit is the rule this document wrote for
itself, and it applies to its own record first**, so both go back to `unchecked`
and the two passes are recorded here as history, not as evidence: `W8` passed at
`f5f2385` on 2026-09-04, near-miss half never run, and `W9` passed in full at
`f5f2385` on the same day, out-of-range spawn included.

**Two cases in `W9` are new with the rewrite**, because the new rescue reaches
behaviour nothing covered: a **blocked column** — clamped back in from outside the
wall over untouched terrain, which is the author's *"nearest free block above
him"* and the first check of the clamp arithmetic — and the **bound exhausted**, a
column solid past 64 nodes above `mgflat_ground_level`, which is now the only
route into `repair_spawn()` at all.

**`W4` stays partial, and its missing sha is deliberately kept.** The author
played the *uncommitted* tree on 2026-09-04. What it establishes anyway is that
the whole `G6` stack is live: there was a bedrock floor to cut through, so
`mapgen_env.lua` loaded and ran, the engine is 5.9 or later, and
`register_mapgen_script` did what it was chosen for. **Re-run at `60259dd`.**

**`W5`, `W6` and `W7` were not seen and are not implied.** The wall, the drone's
bound naming 1024, and an existing world being re-bounded remain `unchecked`; a
fall near spawn says nothing about any of the three. So `B50` now has **no live
in-world evidence on either route**: route two — a program carving a hole — was
verified by `W8` and `W9` and that evidence went with the rewrite, and route one,
walking off the generated edge, rests on the wall and therefore on `W5`.

**`W3`'s method went stale with the same change**, and its result line is left
alone: it passed by teleporting "several thousand nodes" out, which now lands
outside a world whose limit is 1024. The pass is still what was seen at
`7f649d8`; the instruction is what has to be re-read before it is re-run.

**`P2` is owed a re-run too.** `G6` adds two tracked files — the game-root
`settingtypes.txt` and `mods/cc_mapgen/mapgen_env.lua` — and `.gitattributes`
decides what reaches a player with nothing checking it (`C15`). Both are files a
player *should* get, so nothing is expected to be wrong; `P2` is what says so.

**The game's behaviour has been checked in a world on 2026-09-01 over three
rounds, again on 2026-09-02, and twice on 2026-09-04.** Fifteen of the
twenty-five have a live result and twelve pass: `W1`–`W3`, `L1`, `L2`, `R1`–`R4`,
`R6`, `R7` and `P2`. Three are partial: `P1`, its clone half only; `R5`, whose
drop half passed and whose `R3` re-run has not been done; and `W4`, from
2026-09-04 against an uncommitted tree. `L3` waits on `A7` landing upstream in
`codeblock`; `W5`–`W9`, `R8`, `P3`, `P4` and `P5` are unrun, and `P5` needs a
release first. **`W8` and `W9` are unrun because their results were retired on
2026-09-07, not because nobody has played them** — that is a state this document
had not had before, and the distinction is in the `W` group.

**`R8` is new on 2026-09-04, and four existing checks are marked for re-running
beside it.** Since `B48` is now committed on its own at `ec02760`, all five have
a sha to be run against. `B48`'s fix rewrites `groups` on *every* registered node in the
`cc_security` override pass, which is a far wider blast radius than the
`diggable` field it sits next to. `R8` is the only thing that can say the crack
animation is gone, and `R1`, `R4`, `R6` and `P3` are the ones that would catch
the pass having broken something else on the way. Each says so where it stands.
None of their existing results has been moved — a pass recorded at `7f649d8` or
`6f2409e` is still what was seen then, and it is the code that has moved.

**`R2`'s drop half ran on 2026-09-02, for the first time in this project.** It
had been recorded as passing since the first playtest on the strength of the
inventory panel alone — nothing had ever been dug, because `diggable = false`
makes it impossible, and the check said only "with digging somehow permitted".
Commenting that line out for one run is what finally exercised
`handle_node_drops`, and it is the method the check now carries.

**Every restriction that was checked on 2026-09-01 is evidence rather than
reading.** Nothing is diggable, no item drops, there is no knockback, no
inventory is reachable, and the drone still builds through all of it.
`cc_mapgen` is proven the same way: flat and clean at spawn, far out into
unemerged map, and in a world created with other flags. `cc_day` holds the light
and the sky at every hour.

**`R7` is the one that earned the most.** The game also claims the world never
changes on its own, and the fix behind that claim rests on undocumented
behaviour — replacing an ABM's `action`, because Luanti cannot unregister one.
Nothing but `R7` could say whether it works, and on 2026-09-02 it did: nothing
moved in five minutes.

**Three findings came out of those rounds** — `B47`, `B48` and `S8` — none of
them visible from reading the three `cc_*` files, **which were 21 lines between
them at the time** — 397 now, since `G6` and the rescue rewrite. All three are now fixed; `B48` is the
one whose fix has not been seen in a world, which is what `R8` is for.

**`B49` came the other way, and is worth noting for that.** It was found by
reading `mods/default` while scoping `A13`, not by playing — three rounds in a
world walked past dirt spreading grass and a roofed grass floor reverting,
because nobody had thought to wait five minutes and look again. Playing finds
what reading misses; this one went the other way, and `R7` put it back in front
of a world.

**`R6` is the case for re-running a check against its own fix.** The first `S8`
fix stopped items going into the bookshelf and left the real hazard standing: the
same panel is a way into the player's own inventory, and a drone tool dragged out
of the hotbar there lands in a row the player can no longer open. Marking `R6`
pass on the strength of that fix would have shipped it. The same applies to `R4`,
re-run beside `R6` because the second fix denies every player inventory action
and `R4` is what would catch that being too broad.

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` settles the world's flags and its size, and
`mapgen_env.lua` beside it writes the bounds into each chunk on the emerge
threads: nothing below `y = 0`, a bedrock plane at `y = 0`, and a bedrock wall at
the outermost generated column. `cc_security` holds the two that are about the
player rather than the map — the clamp (`W8`) and the place it puts them (`W9`).
`W4`–`W9` are all `B50`. **None of the six has a live result**: `W8` and `W9` were
rewritten on 2026-09-07, when `60259dd` reversed the rescue's destination, and
their passes were retired with the code they described; `W4` is partial from
2026-09-04 against an uncommitted tree; `W5`–`W7` have never been run.

**Three facts about the world these checks are run in, because each one changes a
method below.** First, `mg_flags` carries `nobiomes`, so `mgflat` has no top or filler
node and **the surface is stone** — there is no dirt and no grass anywhere until
a program places some. Second, `mgflat_ground_level` is **8**, so that surface is
at `y = 8` and the bedrock plane at `y = 0` is **eight nodes underground**: it is
never seen in ordinary play, and reaching it means having a program clear a shaft
down to it. Third, the clamp in `cc_security` is committed, and since `60259dd`
it rescues a player **into their own column** rather than to spawn, so
**`/teleport`ing to a negative `y` no longer leaves you there** — within 250 ms
you are stood on the first room in the column you were over. That is `W8`'s
subject and `W4`'s obstacle.

### W1 · A new world is flat and clean at spawn

Create a new world with default settings and enter it. Look around, and move a
few hundred nodes in one direction — `/teleport` rather than flight, since
`default_privs` dropped `fly` on 2026-09-02. The pass below was recorded before
that, by flying.

**Pass:** flat ground to the horizon at one level. No trees, grass, flowers or
any other decoration; no ore visible in the ground when a drone digs into it; no
cave mouths, no dungeon, no water, no biome transition — the ground node and its
colour never change.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — flat and clean at
spawn and for a few hundred nodes out.

### W2 · The mapgen flags survive a world that was created with others

Create a world, enter it once, leave. Edit that world's `map_meta.txt` to set
`mg_flags` to something with caves and decorations, then re-enter.

**Pass:** the world is still flat and clean. `override_meta = true` is the third
argument of the one call `cc_mapgen` makes, and this is the only thing that
argument is for. Without it a world remembers the flags it was created with and
the game's setting is read once and never again.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — a world re-entered
with caves and decorations written into its `map_meta.txt` is still flat and
clean. `override_meta = true` does what the one call needs it to.

### W3 · The world is flat far from spawn, and far from where anyone has been

Teleport several thousand nodes from spawn into unemerged map, and watch the
ground generate ahead.

**Pass:** the same flat clean ground, generated live. This distinguishes a
setting that applied at world creation from one that applies to every chunk the
engine emerges, and only the second is what the game promises.

**Use `/teleport`, not flight.** `default_privs` dropped `fly` and `noclip` on
2026-09-02, so the method this check passed by is no longer available to a
default player — grant the priv or teleport. The distance is also worth
re-reading against `mapgen_limit`, **now 1024** and no longer 4096: "several
thousand nodes" now lands *outside* the world, so this check must be re-run at a
distance inside 1024 — and past the wall there is nothing to teleport into.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — ground generated live
several thousand nodes out is the same flat clean ground. The setting applies to
every emerged chunk, not only to world creation. **Passed by flying**, before
`fly` left `default_privs`; the finding it establishes is unaffected, but a
re-run takes the route above.

### W4 · The floor is there and you cannot fall through it [B50]

**The method changed on 2026-09-04 and the old one no longer works.** It was
`/teleport` to `y = -5`; the clamp now puts you back at spawn within 250 ms, so
that only exercises `W8`. Go from above instead.

Have a program clear a shaft from the surface down to `y = 1` — the surface is at
`y = 8` and everything between is stone — then climb or teleport into it and
stand on the bottom.

**Pass:** the shaft bottoms out on a plane of bedrock at `y = 0` that the program
did not place and cannot remove by accident, and you are standing on it rather
than falling. Then have the program `remove` one node of that plane and look into
the hole from beside it: what is under the plane is **air, not stone** — nothing
is generated below `y = 0`. Do not walk in; that is `W8`.

**A near miss looks like this:** the shaft bottoms out on more *stone*, or the
hole shows stone under it. That means the mapgen environment script never loaded
and `mgflat`'s ordinary fill is still there, so neither the floor nor the wall
exists — check the boot log for a `register_mapgen_script` error, which is what
an engine below 5.9 gives.

Result: partial — **no commit, the uncommitted working tree of 2026-09-04** ·
engine 5.17.0 (the only install; not noted at the time, and what the session
itself proves is ≥ 5.9) · 2026-09-04 — **established as a by-product of `W8`, not
by the method above.** The author dug a hole away from spawn and fell through it,
so there was a bedrock floor at `y = 0` to cut through and air under it: the
mapgen environment script loaded and ran, and `mgflat`'s ordinary fill is not
still there. What was *not* done is the method: nobody has stood on the plane at
the bottom of a shaft, and nobody has looked into a removed tile from beside it.
**Re-run once there is a commit** — a result naming no sha is not evidence anyone
else can put in front of themselves. **Commits now exist and this result is
deliberately not backdated onto one**: `W9`'s repair landed on the same rescue
path between the sitting and `f5f2385`, and `60259dd` then replaced the
destination outright. Carrying a result across a change to the code it exercised
is the mistake `R6` taught this project. **Re-run at `60259dd`.**

### W5 · The wall stands, full height, all the way along [B50]

`/teleport` toward `+x` past 1000, then walk into the edge. Look up along the
face, and walk some way along `z` with the wall beside you.

**Pass:** an unbroken bedrock face, from the floor up out of sight, standing at
the same `x` all along `z`, with no gap where one mapchunk meets the next.

**A near miss looks like this:** a wall that is there at eye level and absent
thirty nodes up. That is the wall being written only into the chunk that
contains the ground, and it is exactly the case a check done from standing height
would pass.

Result: unchecked

### W6 · The drone's bound followed the number [B50]

Ask the drone to move past 1024 on any horizontal axis.

**Pass:** it refuses with *"The drone cannot leave the world (1024 nodes)"* —
naming **1024**, not 4096.

This is the only thing that proves the game's `minetest.conf` reached
`core.settings` and that the drone's bound and the wall are the same number.
CodeBlock reads `mapgen_limit` itself; nothing in this game writes it into the
mod, so a disagreement here would let a program build where a player cannot walk.

Result: unchecked

### W7 · An existing world is re-bounded [B50]

Open a world created before this change — one whose `map_meta.txt` still carries
the old `mapgen_limit = 4096` — and walk or teleport out to 1024.

**Pass:** the edge is at 1024, not 4096.

`mapgen_limit` is stored per world, so without `override_meta = true` on
`cc_mapgen`'s `set_mapgen_setting` call an old world keeps its old edge for ever.
This check is the only thing that argument buys and the only route to seeing it
fail.

Result: unchecked

### W8 · A player who falls through a program-made hole is put back [B50]

Implemented in `mods/cc_security/init.lua`, not `cc_mapgen`: the wall and the
floor do not close this, because a program may `remove` a floor tile and
`diggable = false` binds the player, not a program.

The floor is eight nodes underground, so this needs two steps, not one. Have a
program clear a shaft from the surface down to `y = 1` and then `remove` one
bedrock node at `y = 0` under it — `W4`'s shaft will do. Then walk into the hole.

**Pass:** you stop falling, and you are put back **in your own column** — at the
bottom of the shaft you just fell down, standing on a bedrock node the rescue
laid where the program removed one. Your `y` is about **0.5**, and you are **not**
at spawn. You will be standing in a shaft you cannot climb or dig out of: that is
the accepted trade, not a failure of this check, and the way out is to point the
drone at the shaft wall.

**The destination changed at `60259dd` on 2026-09-07 and this check's pass was
inverted with it.** Until then the rescue went to the spawn point and *"you end
up at spawn, standing on the surface"* was the pass. Arriving at spawn now means
the column scan found no room in 64 nodes and fell back, which this setup does
not produce — so **at spawn is a fail here**, and the check for the fallback is
`W9` case 4. The grounds for the reversal are in `ROADMAP.md` under `G6`.

**A near miss looks like this:** the clamp fires on the fall *and* on a player
standing legitimately at the very edge of the world — against the wall, or on the
floor plane itself — moving them every few seconds and making the
world unplayable at its own boundary. So walk the wall and stand on the exposed
floor plane for a while in the same session: neither must move you.

**Both halves of that near miss have been traced in the code and neither should
fire; this check is what says so in a world.** A player's position is their feet
and the plane's nodes span `y = -0.5` to `0.5`, so standing on an exposed floor
tile reads `0.5` — half a node under the `p.y < 0` test. The wall occupies the
outermost generated column, so the furthest column anyone can stand in is one
short of the horizontal bound. A third failure mode, the clamp firing on a player
mid-join before their position settles, was traced and **withdrawn**: the engine
sets a player's position before adding them, and a player with no `PlayerSAO`
does not appear in `core.get_connected_players()`. Someone who logged out
mid-fall *is* teleported on rejoining, and that is the clamp working, not a near
miss.

**Where you land is a separate check.** This one is *are you moved, and does the
falling stop*; `W9` is *is the place you land one you can stand in*, and it holds
the cases this setup does not reach — a column blocked by terrain, and a column
with no room in it at all.

Result: unchecked

**An earlier result was retired here on 2026-09-07 rather than carried forward.**
The author ran this check at `f5f2385` on 2026-09-04 and reported it a **pass**,
which cleared the missing sha the previous partial carried — and what they
watched was a rescue **to the spawn point**, the destination `60259dd` replaced.
A result cannot survive a change to the code it exercised, which is the rule this
project wrote for itself after `R6` and which applies to its own record first, so
the line is gone rather than moved. The near-miss half is untouched by `60259dd`
and has **still never been run**: nobody has walked the wall or stood on the
exposed floor plane to confirm the clamp does *not* fire there. Re-run both halves
at `60259dd`.

### W9 · The place the rescue puts you is a place you can stand [B50]

**Separate from `W8` and not a half of it.** `W8` is *are you moved, and does the
falling stop*; this is *is where you land somewhere you can be*. The split
survived `60259dd` even though its old framing did not: the two used to divide on
whether the **spawn column** was involved, and they now divide on **being moved**
versus **the column being made standable**. Kept as two checks for the reason the
split was made in the first place — a rescue that fires perfectly into a sealed
column passes `W8` and is still a softlock, and the two have different setups,
different tells and different ways of failing.

What this checks is `standing_pos()` in `mods/cc_security/init.lua`: it clamps
the player's column inside the wall, writes `cc_mapgen:bedrock` at `(x, 0, z)` if
that node will not hold them, and scans up for the first height at which both
nodes a player occupies are clear. `repair_spawn()` is unchanged and is now
reached **only** when that scan finds no room. Four cases.

**1 · The shaft you dug**, and the setup that produced the reported loop. From
spawn, have the drone remove the bedrock at `(0, 0, 0)` and the stone column
above it, so the spawn column is a shaft. Walk in.

**Pass:** you are moved back **once**, and you are standing on a solid node,
stationary, at the bottom of your own shaft — `y` about **0.5**, on a fresh
bedrock tile. **You will not be able to walk away**, and since `60259dd` that is
the specified behaviour rather than a fail: the way out is to point the drone at
the shaft wall. **Fail:** any second teleport, or moved back but still falling.
That is the defect exactly as it was reported on 2026-09-04, and it is what
making the floor whole under you prevents.

**2 · The blocked column** — the author's *"nearest free block above him"*, new on
2026-09-07 and the case nothing has ever covered. Have the drone remove a wall
column so there is a way out of the world, then walk out through the gap, over
ground the program has not touched.

**Pass:** you are put back **one node inside the wall, at the same `z`**, standing
on top of the stone surface — `y` about **8.5**. Not embedded in the stone, and
not down on the bedrock plane.
**Fail:** your view is inside a node, or you arrive at `y` about 0.5. This is also
the first check of the clamp arithmetic, which was never player-visible before:
the wall stands *on* the outermost generated column, so the innermost standable
column is one node in from it, and an off-by-one here puts you inside the wall.

**3 · The no-op case.** With the world otherwise untouched, fall out from a shaft
elsewhere.

**Pass:** after the rescue, **the only node anywhere that may have changed is
`(x, 0, z)`** — the floor tile under your own column, remade as bedrock. Nothing
near spawn may have changed at all: the rescue does not visit spawn on this path.
The old form of this case asserted that the surface at `(0, 8, 0)` was still
stone, and since `60259dd` that assertion is vacuous.

**4 · The bound exhausted.** The scan gives up 64 nodes above
`mgflat_ground_level` — 72 in a default world — and this is the **only surviving
route into `repair_spawn()`**. Reuse case 2's way out of the world: have the drone
fill the column one node inside the wall, at the `z` you will walk out at, with
stone from `y = 1` up past `y = 72`, then walk out through the removed wall
column at that same `z`.

**Pass:** you arrive at spawn, in open air, free to move.
**Fail:** you arrive embedded in a node, or the rescue does nothing at all.
Building a 72-node solid pillar and falling out of the world at exactly its
footprint is the case the bound trades away, and what it costs is the old
behaviour — spawn — rather than a softlock.

**Two false passes this check must be run against, because they are how the fix
looks fixed without being fixed:**

- **The `ignore` branch, and it is weaker than it was.** `minetest.get_node`
  reports `ignore` for an unloaded mapblock and that reads as an ordinary solid
  node, so a repair written on it would be skipped on exactly the tick that needs
  it — hence `get_node_or_nil` and the explicit test. But the column the rescue
  now works in is the one the player is standing in, so it is nearly always
  resident, and **the out-of-range variant no longer forces that branch.**
  `load_area` still matters, because the scan reaches 72 nodes above a player who
  is below `y = 0` and the top of that column need not be in memory. Of the four
  cases only **case 4** still puts a possibly non-resident area under a write, at
  spawn, which is a few hundred nodes from where it is run.
- **Landing on the bedrock plane at `y = 0` rather than on the surface, which was
  the tell for a bad fix and is now the fix.** Exactly reversed by `60259dd`, so
  read it per case: in case 1 about **0.5** is the pass and about 8.5 would mean
  the scan is not stopping at the lowest room in the column; in case 2 about
  **8.5** is the pass and about 0.5 would mean the column was carved out rather
  than scanned up.

Result: unchecked

**A pass was retired here on 2026-09-07 rather than carried forward.** All three
cases as they then stood passed at `f5f2385` on 2026-09-04, including the
out-of-range variant the author confirmed they ran, and it was the strongest
result this project had. It was a result about a rescue **to the spawn point**,
which `60259dd` replaced: case 2 no longer reaches the code it tested, case 3's
assertion is now vacuous, and case 1's pass condition is inverted. Carrying it
would be backdating a result across a change to the code it exercised — the thing
this document says not to do.

---

## L · Light

`mods/cc_day/init.lua` is one `on_joinplayer` calling five player methods.

### L1 · Permanent noon, no sky objects [A7]

Enter a world and look up. Wait, or advance time with `/time`, and look again.

**Pass:** full daylight regardless of the time of day; no sun, no moon, no stars,
no clouds. `override_day_night_ratio(1)` is what pins the light level, and the
other four calls remove the objects — they are separate effects and a partial
result should say which of the two failed.

Result: pass — `b9bf82b` · engine 5.17.0 · 2026-09-01 — full daylight at
every hour, and no sun, moon, stars or clouds at any time of day. No sunrise or
sunset glow either, which is what this re-run was for.

Previously partial at `7f649d8`: **part of the sun was visible at `/time 5000`**
— the sunrise texture, which `set_sun{visible = false}` leaves alone. `B47`.
Adding `sunrise_visible = false` to `cc_day` was enough on its own, which also
answered the open question in that finding: `codeblock`'s duplicate bare
`set_sun` does **not** put the field back, so `A7` was never a prerequisite.

### L2 · It survives a rejoin, and it applies to a second player

Leave the world and rejoin. On a server, have a second player join after the
first.

**Pass:** the same for both, every time. The callback is `on_joinplayer` and
these are per-player settings, not world settings — a rejoin is the path that
matters, and a second player is what would catch a setting applied to whoever
joined first.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — survives a rejoin.
The second-player half was not exercised: singleplayer only.

### L3 · Permanent noon still holds once the duplicate is removed [A7]

**Run this only once the game has adopted a `codeblock` release with the block
removed** — the edit is upstream, not here, so nothing in this repository will
show that it has landed. `codeblock` currently registers its own `on_joinplayer`
calling the same five methods, annotated `-- TODO: TEMP fix`. `A7` removes that
copy, leaving `cc_day` as the only thing setting the sky.

**Pass:** L1 and L2 both still pass with the mod's copy gone. This is the check
that says which of the two was doing the work, and until it runs, `cc_day` being
sufficient on its own is an assumption.

**Look at dawn and dusk in particular.** The two copies were never identical:
`codeblock`'s is a bare `set_sun{visible = false}` and `cc_day`'s adds
`sunrise_visible = false`. `L1` already passes with both in place, so this is not
expected to regress — it is the one field that distinguishes them, and the one
worth confirming by eye.

Result: unchecked

---

## R · Restrictions

`mods/cc_security/init.lua`, and it is the whole of what a player may and may not
do: a blank inventory formspec per player, a guard denying every player-initiated
inventory action (`S8`), a pass over every registered node setting
`diggable = false`, stripping the six digging groups so the client stops
predicting a dig (`B48`), denying its three inventory callbacks and stopping its
timer (`S8`, `B49`), every ABM action replaced with a no-op (`B49`), and two engine
globals replaced — drops chained with an empty list, knockback returning 0, with
`last_mod = cc_security` in `game.conf` keeping this mod the one that replaces
them (`A8`). It also holds the world-box clamp added for `B50` — a player found
outside the world is put back into their own column, on the first place in it
they fit, with the floor made whole under them, and to spawn only when that
column has no room at all — but those two read with the rest of the world's
bounds and are `W8` and `W9`, not here.

**That rescue is the one place in this mod that writes to the map**; every other
rule in it denies. Worth knowing here, because "`cc_security` only ever denies"
is otherwise the natural summary of this group and it is no longer true. Since
`60259dd` it writes **one node**, the floor tile under the rescued column, on the
ordinary path; only the spawn fallback clears anything.

### R1 · Nothing is diggable

Punch and hold on the ground, on a wall the drone built, and on several different
block types including one from `wool` and one from `default`.

**Pass:** nothing breaks, anywhere, on any node. The pass runs at
`on_mods_loaded` over `minetest.registered_nodes`, so a node registered later —
by another mod, or by a future `default` trim — would not be covered; try a block
type the drone can place but you have not seen before.

**Re-run this against `B48`, and it is the one most at risk.** That change adds
an inner `pairs` over every node's `groups` inside the same loop. If it errors on
any single node, `register_on_mods_loaded` aborts and **every node after that
point keeps `diggable = true`** — and table iteration order is not stable, so a
partial failure hits a different set of nodes on every boot. One punch on one
wall would miss that. Try several block types, from `default` and from `wool`,
and try them in a fresh world rather than the one already open.

Result: pass, with two things it turned up — `7f649d8` · engine 5.17.0 ·
2026-09-01 — nothing breaks, anywhere, on any node tried. The rule holds. But:

- **Wool plays the breakage animation and then the block stays.** The world's own
  ground does not. Cosmetic, and filed as `B48`: `diggable = false` is enforced
  by the server, and the client predicts a dig from the node's groups, so a node
  the client thinks a hand can break cracks before the server refuses. Wool is
  `oddly_breakable_by_hand = 3` and the ground is `cracky`, never hand-diggable,
  which is exactly why only one of them shows it.
- **A bookshelf opens.** `default:bookshelf` carries a node formspec, and it
  contains `list[current_player;main;…]`, so it reaches around the blanked
  inventory formspec that `R2` checks. Filed as `S8` — the palette exposes
  `bookshelf`, so this is reachable in ordinary play.

### R2 · The inventory is empty and no item ever drops

Two halves, and only the first can be checked by playing normally. Open the
inventory: it should be blank.

**The drop half is not reachable from inside a running game, and that is the
point of it.** Checked against the 5.17.0 reference on 2026-09-02:

- No built-in chat command digs a node. `/give` and `/giveme` put an item in an
  inventory, which is a different path; nothing exposes `core.dig_node` to chat.
- **Privileges do not help.** `diggable = false` is a node property, not a
  permission — the reference says *"if false, can never be dug"* — so `node_dig`
  refuses before drops are ever computed, however privileged the player.
- **The drone does not reach it either.** `codeblock` writes the map with
  `set_node` and `VoxelManip` (`lib/commands.lua`, `lib/shapes.lua`), neither of
  which computes drops. So `R4` does not exercise this.

So `handle_node_drops` is unreachable while `diggable = false` holds on every
node — it is the fallback for the one gap `R1` names: **the override pass runs at
`on_mods_loaded` over `registered_nodes`, so a node registered later is not
covered**, and then the drop guard is all that is left.

**To check it, reproduce that gap.** Comment out **both** the `diggable = false`
line and the `groups = groups` line in `mods/cc_security/init.lua`'s
`override_item` call, restart the server, and dig a node by hand. Revert both
lines afterwards. This is not cheating the check: an uncovered node is exactly
the situation the guard exists for, and it is the only way to put the real
`handle_node_drops` on a real dig.

**The `groups` line is why this method changed on 2026-09-04.** `B48` strips six
digging groups from every node, and the hand digs by groupcap — so with the
groups gone, `diggable = true` on its own may leave nothing the hand can break,
and the check would silently do nothing instead of failing. The pass below was
recorded before that change, by commenting out one line, and stands: it is
evidence about `handle_node_drops`, which `B48` did not touch.

**Pass:** the inventory formspec is blank; digging with the line commented out
removes the node and **no item appears** — none on the ground, none in the
inventory. `handle_node_drops` passes an empty list to whatever it captured, so
nothing is ever handed out. (`A8`)

Result: pass, both halves — `7dc764f` · engine 5.17.0 · 2026-09-02 — the
inventory formspec is blank, and **the drop half ran for the first time**: with
`diggable = false` commented out and the server restarted, a node dug by hand
disappeared and no item appeared, on the ground or in the inventory. The line was
reverted afterwards. So `previous_drops` is not `nil`, the chain fires, and the
empty list reaches the captured handler — the one thing `A8` changed that could
have failed silently. What this still does not establish is that no inventory is
*reachable*: `R1` found a bookshelf's own formspec shows the player's `main` list
(`S8`).

Previously pass on the inventory half only — `7f649d8` · engine 5.17.0 ·
2026-09-01 — nothing was dug, because nothing could be.

### R3 · No knockback

Take a hit — from another player, or anything that would push you.

**Pass:** you are not moved. `calculate_knockback` returns 0.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — no knockback.

### R4 · The drone can still build [R1 must not have broken it]

Run `stairs.lua`. Then run a program that places, and one that removes, blocks.

**Pass:** the drone places and removes normally. `diggable = false` is a property
of the node for a *player's* tool; the drone writes the map directly and must be
unaffected. This is the check that a restriction has not been made so broad it
disables the point of the game.

**Re-run this against `B48`.** It is the widening control for that loop: six
groups have just vanished from under whatever might have been reading them, and
this is what says the drone still builds through the same override pass. Run it
in the same session as `R8`.

Result: pass — `6f2409e` · engine 5.17.0 · 2026-09-02 — re-run after `A8` changed
`cc_security`. The drone still places and removes normally, so chaining the drop
handler and declaring `last_mod` have not narrowed the game.

Result: pass — `c042364` · engine 5.17.0 · 2026-09-01 — the drone places and
removes normally with every node undiggable, and still does with the `S8` guard
denying every player-initiated inventory action. That second run was the point:
the guard is deliberately total, and this is what would have caught the editor or
a tool depending on an inventory move. Also passed at `7f649d8`, before the
guard.

### R6 · A bookshelf opens nothing you can use [S8]

Have a program place a `bookshelf`, then right-click it. Try to drag one of the
two drone tools from the inventory panel into the bookshelf's own slots, and try
to drag it back out. Then leave the world, rejoin, and open the same bookshelf.

**Pass:** the formspec still opens — that part is in node metadata and
`cc_security` cannot reach it — but no item moves in either direction, and the
bookshelf is empty after the rejoin. The three `allow_metadata_inventory_*`
callbacks are overridden to return 0 on every registered node, so the denial is
not specific to bookshelf; a chest or furnace would behave the same if one
existed.

**Also confirm the drone still builds** — the same override pass touches every
node, and `R4` is what says the restriction has not been widened into the game.

**And confirm you cannot rearrange your own hotbar from inside that panel.** The
bookshelf's formspec shows `list[current_player;main]`, so it is a way into the
player's own inventory even when nothing can be moved into the bookshelf itself.
Drag a drone tool from the hotbar into one of the rows below it. Nothing should
move. That is the half the first fix missed.

**Re-run this against `B48` too — cheap to fold in.** It does not test groups,
but its three `allow_metadata_inventory_*` callbacks are set by the same
`override_item` call in the same loop, so a mid-loop error takes them out
alongside `diggable`.

Result: pass — `6f2409e` · engine 5.17.0 · 2026-09-02 — re-run after `A8` changed
`cc_security`. Both halves still hold: the bookshelf takes nothing and no drone
tool leaves the hotbar through the panel.

Result: pass — `c042364` · engine 5.17.0 · 2026-09-01 — both halves. The
bookshelf takes nothing, and a drone tool can no longer be dragged out of the
hotbar through the panel. `S8` is closed.

Previously partial at `b9bf82b`: the bookshelf half passed and **the player half
failed** — opening the bookshelf gave access to the player's own inventory, and a
drone tool could be dragged out of the hotbar into a row the player then could
not reach, because their inventory is deactivated. That reopened `S8` and
`register_allow_player_inventory_action` was the second half of the fix. **This
is the check that earned its re-run**: the first fix would have been recorded as
complete on the strength of the half that worked.

### R7 · The world does not change on its own [B49]

**This is the check the fix depends on, not a formality.** Neutralising an ABM by
replacing its `action` is not documented behaviour — Luanti has no API to
unregister one — so nothing but this says whether it works.

Have a program build three things, then leave them alone for **at least five
minutes** of running server and look again. The ABMs run on 6- and 8-second
intervals with a 1-in-50 chance, so a glance after thirty seconds proves nothing;
if you want it faster, build many of each.

1. A patch of `dirt` with `dirt_with_grass` next to it, and another `dirt` with a
   `grass_3` on top.
2. A floor of `dirt_with_grass` with an opaque roof — `stone` will do — one node
   above part of it.
3. A `sapling`, in the open.

**Pass:** nothing has changed. The `dirt` is still `dirt`, the roofed
`dirt_with_grass` is still grass, and the sapling is still a sapling.

**On the code before `B49`, all three change**, which is what makes this a real
check rather than an assertion: 1 turns to grass, 2 reverts to plain `dirt` —
destroying what the program placed — and 3 becomes a tree that may overwrite
blocks above it. If any of the three still changes, the `action` replacement does
not take effect and the fallback is deleting the two ABMs from
`mods/default/functions.lua` directly.

**Also confirm a sapling has not simply frozen the server**: the timer stopper
returns `false`, and **`0` is truthy in Lua 5.1** — had it returned `0`, every
node timer in the world would restart forever instead of stopping.

Result: pass — `d16f9bb` · engine 5.17.0 · 2026-09-02 — nothing changed after
five minutes: the `dirt` stayed `dirt`, the roofed `dirt_with_grass` stayed
grass, the sapling stayed a sapling, and the server kept running. The `action`
replacement takes effect, so the fallback of deleting the two ABMs from
`mods/default/functions.lua` is not needed.

### R5 · The chained drop handler still hands out nothing [A8]

**A regression check, not a composition one.** `A8` replaced
`function minetest.handle_node_drops() end` with a call to the handler it
captured, given an empty drop list. **Nothing else in this game assigns either
global** — `grep -rn "handle_node_drops\|calculate_knockback" mods/` finds only
`cc_security` — so the captured value is the engine default and the new code
should behave exactly like the old. What is worth confirming is that it does:
`previous_drops` being non-nil is read from the 5.17.0 reference and has never
been run, and a `nil` there would error on the one path that is meant to be
silent.

Re-run `R3`, and run `R2` **by its drop method**, which is written out under
`R2` and now needs two lines commented out rather than one. That is the only way to put a real dig through the chain; no second mod, nothing
to install. Without it R5 proves nothing that `R3` does not already prove.

**Pass:** both still pass. No item entity ever appears, and nothing pushes you.

**What this deliberately does not check, and why.** `A8`'s other half — that
`last_mod = cc_security` makes this mod's assignment the one that survives —
needs a second mod installed that assigns the same globals, and none ships here.
Building one for the occasion would be testing a composition this game does not
have. The scenario it defends is a server owner adding a worldmod to a Codecube
server from ContentDB, and even then the game's promise is held by
`diggable = false`: the drop handler matters only once something has already
re-enabled digging, at which point the owner has deliberately changed the game.
**Untested by choice, recorded so it does not read as an omission.** Decided by
the author on 2026-09-02.

Result: partial — `7dc764f` · engine 5.17.0 · 2026-09-02 — **the half that could
have broken is done.** `R2`'s drop method passed: the chain fires, hands an empty
list to the captured handler, and nothing drops. `R3` was not re-run on current
code, so the knockback half is still resting on its 2026-09-01 pass. The risk
there is small — `A8` left `calculate_knockback` byte-identical and nothing
competes for it — but small is not none, and thirty seconds closes it.

### R8 · No node ever plays a dig animation [B48]

**The outcome and the animation are different claims, and only the animation is
new.** Every node was already undiggable at `R1`; what `B48` changes is that the
client no longer *predicts* a dig it is about to be refused. So a node staying
put proves nothing here — the observation is what the screen and the speakers do
during the punch.

Punch and **hold** on each of three nodes, for a full two seconds each, close
enough to see the face clearly and with sound on:

1. `wool`, any colour. Was `oddly_breakable_by_hand = 3`, and is the node that
   produced the finding: it cracked through all five stages and then stayed.
2. `default:leaves`. Was `dig_immediate = 3`, so before the fix it cracked
   *instantly*, in a single frame. It is the fastest case and the one where a
   partial strip would still show.
3. `default:stone`. `cracky`, never hand-diggable, so it never cracked and must
   still not. This is the control that says the fix removed a prediction rather
   than breaking the display: a stone that now behaves differently means
   something other than the digging groups was touched.

**Pass:** on all three, **no cracking texture appears at any stage** — not stage
one, not a single frame — and **no dig sound plays**. The node is also still
there afterwards, on all three, which is `R1`'s claim and not this one.

**A near miss looks like this:** the block does not break, so it reads as a pass,
while the first crack stage still flashes on `leaves`. That is the whole defect
`B48` describes, and only holding the punch and watching the face catches it.
Equally, a `wool` that stops cracking while `leaves` still flashes means the
group list is incomplete, not that the fix works.

**Then confirm the strip did not cost anything else.** Wool must still show its
colour and `leaves` must still look like leaves — the fix keeps every non-dig
group deliberately, and colour, flammability, attachment and decay all ride on
them. Run `R4` in the same session: it is the check that says the drone can still
build through the same override pass, and this change edits the loop `R4` guards.

**`B48`'s fix is now committed on its own, at `ec02760`** — split out of `G6` so
the `G4` fix stands separately — so this check finally has a sha to be run
against, and so do the `R1`, `R4`, `R6` and `P3` re-runs beside it. `f5f2385`
carries it too and is the tip; either names the same `cc_security` override pass.

Result: unchecked

---

## P · Packaging, boot and install

### P1 · A fresh recursive clone boots

`git clone --recurse-submodules` into an empty directory, put it in Luanti's
`games/`, create a world, enter it.

**Pass:** it boots and is playable. This is the check that catches a submodule
pointer naming a commit nobody can fetch — `reference is not a tree` — which is
invisible from a working tree that already has the object. It is also the gate
the `release-codecube` skill runs before a tag.

Result: partial — `8b27f2f` · 2026-09-01 — the clone half only. A fresh
`git clone --recurse-submodules` populated both submodules from the HTTPS remotes
in `.gitmodules`: `codeblock` `2647228` (`v0.4.0-98-g2647228`) and `vector3`
`16621648` (`v1.5`), so neither pointer names a commit nobody can fetch, and
`check_game.sh` passes inside the clone. **Not booted in Luanti** — the half that
says it is playable is still unchecked.

### P2 · The release archive holds only what a player needs [C15]

`git archive --format=zip HEAD -o /tmp/codecube.zip` and list it.

**Pass:** no `.claude/`, `.reports/`, `.github/`, `scripts/`, no art sources, and
none of `CLAUDE.md`, `ROADMAP.md`, `TODO.md`, `AUDIT.md`, `PLAYTEST.md` or
`CONTENTDB.md`. `menu/*.png` **is** present — the main menu reads it. Note the
total size; the last measurement was 2.75 MB, down from 4.94 MB.

**This is the half of `C15` that reading cannot settle**, and the reason it stays
worth running: `.gitattributes` decides what reaches a player and **nothing in
either CI checks it**, so a file added to the repository ships unless a rule
excludes it, and nothing fails locally when one does. Run this whenever a tracked
file is added, not only at a release.

Result: pass — `8b27f2f` · 2026-09-01 — 488 entries, **1.93 MB zipped**
(2.26 MB uncompressed). Nothing hidden, no art source, no `scripts/`, and none of
the six record documents; `menu/background.png`, `menu/header.png` and
`menu/icon.png` are all present. Root holds only `CHANGELOG.md`, `LICENSE`,
`README.md`, `THIRD-PARTY-LICENSES.md`, `game.conf` and `minetest.conf`.
`mods/codeblock` and `mods/vector3` are **empty directory entries** — `git
archive` does not descend into submodules, and ContentDB resolves both as
dependencies rather than reading them from here. **The 2.75 MB above does not
reproduce by this method.** Measured both ends with `git archive --format=zip`:
`8d18e8b^` gives 3.29 MB zipped / 4.32 MB in 523 files, `8b27f2f` gives 1.93 MB /
2.26 MB in 488. The reduction is real and slightly larger than recorded; the
absolute pair in `C15` was measured some other way. **Quote the method with the
number** so the next run is comparable.

### P3 · The boot log is clean [B19, B24]

Watch the log while a world loads, from a cold start.

**Pass: nothing.** No `NodeResolver` errors, no deprecation warnings, nothing red
or yellow at all. This became a real check on 2026-09-02, when `B19` and `B24`
were fixed directly rather than left to `A13`; before that it could only ask you
to count seven known messages and hope no eighth was hiding among them.

**The seven that should now be gone**, so a re-appearance is recognisable: five
`NodeResolver` errors from four `default` log schematics embedding
`flowers:mushroom_brown` and `flowers:mushroom_red` (`B19`, now aliased to `air`
in `cc_mapgen`), and two `TileDef.image` deprecation warnings from `default`'s
furnace and from `cc_security`'s `override_item` pass re-processing it (`B24`,
now `name =`). **If either is back, `default` has been re-vendored** and took the
fix with it — `B24`'s especially, since it is one word inside a third-party file.

**Luanti deduplicates deprecation warnings by message**, so a count here is a
count of distinct messages, not of occurrences — that is what hid the two
`TileDef.image` warnings behind the `formspecs` warnings until `B20` removed
them. A single occurrence of anything new is therefore worth a finding.

**`B48` makes this more worth doing than it was.** One of the two
`TileDef.image` warnings came from `override_item` re-processing a definition,
and that change alters what is handed to `override_item` on every node — a
rebuilt `groups` table rather than the one already there. Whatever the pass
re-triggers, it now re-triggers against something different.

Result: unchecked

### P4 · The main menu presents the game

Open Luanti's main menu with the game installed and select it.

**Pass:** the game's name, its menu artwork and its icon all appear. `menu/*.png`
is what the menu reads, and it is the one thing `.gitattributes` deliberately
keeps in the archive; a `P2` rule written too broadly would break this and
nothing else would notice.

Result: unchecked

### P5 · The ContentDB page reads as a page [C20]

After a release, open the package page on ContentDB and read the long
description as someone who has just arrived there.

**Pass:** it says what the game contains, what distinguishes it and how to play
it once installed. No heading repeating the title, no badges, no screenshots, no
licence line, no link to the repository or back to the page itself. Every
instruction is complete as words — **images are not visible inside Luanti**, so
an instruction that depended on an icon has lost its object for exactly the
readers it was written for.

Also check the page from **inside Luanti**, in the content browser, not only in a
web browser. That is the reader the rule exists for and the one a web preview
does not show you.

Result: unchecked

---

Written 2026-08-30 at `54a2b7e`. Revised 2026-09-01 across three rounds: `P2` and
half of `P1` at `8b27f2f`; the `W`, `L` and `R` groups at `7f649d8`; then `L1`
and `R6` at `b9bf82b` against the fixes those produced, and `R6` and `R4` again
at `c042364`. All played by the author in a world on Luanti 5.17.0 — recovered
from the engine's own debug log afterwards, not noted at the time.

Revised 2026-09-04 a second time, at `578b364` plus the uncommitted `G6` work:
`W4`–`W8` added for `B50` — the floor, the wall, the drone's bound, an existing
world re-bounded, and the clamp that puts a player back at spawn after they fall
through a hole a program made. All five `unchecked`; nothing of `G6` has been run
in a world. No existing result line was changed.

Revised 2026-09-04 at `578b364` plus an uncommitted `cc_security` change: `R8`
added for `B48`, `R1`, `R4`, `R6` and `P3` marked for re-running beside it, and
`R2`'s drop method corrected to comment out `groups = groups` as well as
`diggable = false` — with the groups stripped, the first line on its own may
leave the hand nothing it can break, and the check would do nothing rather than
fail. No result line was changed.

Revised again on 2026-09-04, after the clamp landed in the working tree and the
world it is run in was read properly. **`W4`'s method was stale and could not
have been run as written**: it teleported to `y = -5`, which the clamp now
answers by putting the player back at spawn, so it tested `W8` and not the floor.
It goes down a program-cleared shaft instead. **`W8`'s method was stale for a
second reason**: `mgflat_ground_level` is 8, so the floor is eight nodes
underground and "delete one bedrock node and walk into the hole" needs the shaft
first. `W8`'s near miss is now confirmed against the code, a third failure mode
about join timing is recorded as withdrawn rather than left implied, and the
`W` group carries the two facts that changed both methods — the surface is stone,
and it is at `y = 8`. **No result line was changed and none may be:** every one
of `W4`–`W8` is still `unchecked`.

Revised a fourth time on 2026-09-04, and this one records evidence. The author
played the **uncommitted working tree** and reported two things in one sentence,
recorded here as two results: `W8`'s ordinary case passes — a hole away from
spawn, jumped into, put back on the ground — and the spawn column loops, which is
the new `W9`. `W4` goes to partial as a by-product of the first, since there was
a bedrock floor to cut through and air under it. **`W4` and `W8` are the only
results in this document that name no commit**, because the tree they were seen
on is uncommitted; both say so and both must be re-run once there is one. `W5`,
`W6` and `W7` were *not* observed and stay `unchecked` — a fall near spawn says
nothing about the wall, the drone's bound or an existing world. `W9` is a new
check rather than a half of `W8` because the two ask different questions — *are
you moved* and *where to* — and a rescue that fires perfectly into a shaft passes
one while failing the other. The `R` group intro now says that `cc_security`
writes to the map in exactly one place, since "it only ever denies" was the
natural reading of that group and is no longer true.

Revised 2026-09-07 at `60259dd`, and this is the first revision that **removes
results**. The author asked, after playing, for the rescue to keep the player
where they were rather than return them to spawn, and to lift them to the nearest
free space above when their column is solid; `60259dd` does that, and it is a
design reversal rather than a defect — `W8` and `W9` had both **passed** on the
code it replaces. `W8` had also been re-run at `f5f2385` on 2026-09-04 and
reported a pass, clearing the missing sha its earlier partial carried. Neither
pass survives, because both describe a destination this code no longer produces:
`W8`'s pass condition is inverted (you end at the bottom of your own shaft, `y`
about 0.5, and arriving at spawn is now a fail), `W9` case 2 no longer reaches
`repair_spawn()` at all, and case 3's assertion about the surface at `(0, 8, 0)`
is vacuous because the rescue never visits spawn. Both are back to `unchecked`
with their history recorded above rather than backdated — the rule about carrying
a result across a change to its code, applied to this document's own record.
`W9` is rewritten around four cases, two of them new: the **blocked column**,
which is the author's *"nearest free block above him"* and the first check of the
clamp arithmetic, and the **bound exhausted**, which is the only surviving route
into `repair_spawn()`. `W9`'s first false pass is recorded as **weakened** — the
rescue column is the player's own and so nearly always resident, so only case 4
still forces a write into possibly non-resident map — and its second is recorded
as **reversed**: landing on the bedrock plane was the tell for a bad fix and is
now the fix. `W4`'s re-run target moves from `f5f2385` to `60259dd`; no other
result line was touched.
