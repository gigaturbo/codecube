# Playtest — Codecube (the game)

The manual checks nothing else here can reach. **This game has no test suite at
all** — `scripts/check_game.sh` verifies that the game *assembles*, not that it
behaves, and luacheck reads four files without running them. So this document is
the game's only route to evidence about its own behaviour.

The mod's own manual checks are separate and are the larger set:
`mods/codeblock/PLAYTEST.md`. Nothing here re-checks the drone, the editor, the
sandbox or the API — what is checked here is the world those run in, and what a
player gets when they install the package.

`PLAYTEST.md` carries its own `export-ignore` line in `.gitattributes`, so this
file never ships to a player.

Groups are lettered **W** (world and mapgen), **L** (light), **R**
(restrictions) and **P** (packaging, boot and install) — deliberately none of
`B`, `S`, `C`, `A` or `F`, so a check id can never be read as a finding id, and
none of `G1`–`G7`, the milestone lettering in `ROADMAP.md`.

## How a check is written

Three parts, in this order, and nothing else. **No story, no background section,
no account of how the thing came to be** — that belongs in `AUDIT.md` under a
finding id, or in `ROADMAP.md` as a decision.

```
### <id> · <what a pass means, as a sentence> [<finding ids>]

**Why** — one or two sentences on what the check is really about, especially
where a wrong result would look like a right one.

**How** — the steps, in a running world, with the actual commands or programs
to paste.

**Pass** — what distinguishes a pass from something that merely did not crash,
with any near miss as one line rather than a paragraph.

Result: unchecked
```

Two rules about the steps, and both were bought with a wasted session.

- **Hand the runner an actual program or command, not a description of one.** A
  step that says "have the drone build a large cube" is a step the runner has to
  design before they can run it, and two runners will design it differently.
- **A recipe names the shell it is for.** A `cmd.exe` line pasted into PowerShell
  can run something else entirely and report a plausible-sounding error that
  names nothing about the cause. Write which shell, and quote arguments so the
  expansion is explicit.

A check with no finding id in brackets exists because nothing has gone wrong
there yet and nothing proves it right either. Where there is an id, the reasoning
is in `AUDIT.md` under it.

## How to record a result

Each check carries a **Result** line. Leave it as `unchecked` until someone
actually does it in a running world, then replace it with:

```
Result: pass — <commit> · engine <version> · <YYYY-MM-DD> — <one line of detail>
```

`fail` and `partial` take the same shape. **Always keep the commit and the
date**: a pass recorded three milestones ago is not evidence about today's code.
A `fail` is not a finding — report it and let `AUDIT.md` allocate or widen an id.

- **Name both commits when the checkout was at a record-only commit** — a
  documentation commit sitting on top of the code being checked is written
  `` `2feadb1`, record-only over `24842d3` ``, so the reader can see which commit
  the behaviour came from.
- **Results are listed newest first within an entry.**
- **A result is never carried across a change to the code it exercised.**
  Backdating a pass onto a later commit produces something that looks like
  evidence and is not. Retire it and re-run instead; that rule cost two re-runs
  on 2026-09-07 and is what makes every remaining result checkable.
- **Never move a result off `unchecked` on reading.** Only a person running it in
  a world can do that.

## Where it stands

| | |
|---|---|
| Entries | **30** |
| Live checks | 30 |
| Most recent result a `pass` | **23** |
| `partial` | 2 — `R5`, `P1` |
| `fail` | 0 |
| Unrun (`unchecked`) | **5** — `L3`, `R8`, `P3`, `P4`, `P5` |
| Results retired | 2 — `W8` and `W9`, both at `f5f2385`, on 2026-09-07 |
| Findings closed by a check | `B47`, `B49`, `B50`, `S8` |

**What needs action**, and it is the list — `TODO.md` points here rather than
keeping a second copy.

| Check | State | Why it needs action |
|---|---|---|
| `W3` | pass, **method stale** | it passed by teleporting "several thousand nodes" out, which now lands outside a world whose limit is 1024. The pass is still what was seen at `7f649d8`; the instruction has to be re-read before it is re-run |
| `W4` | pass, **re-run owed** | passes at `60259dd`, where `mgflat_ground_level` was 8; `d6e4a12` moved it to 128. **`W14` does not discharge it**: `W4`'s subject is **air, not stone**, under a removed floor tile, and a program being unable to take the plane by accident — which `W14` never reaches |
| `W8` | pass, **re-run owed** | same depth change. **`W14` case 1 shares the setup and not the check**: `W8`'s pass includes walking the wall and standing on the exposed floor plane **unmoved**, which `W14` does not ask for |
| `W9` | pass, **re-run owed** | same depth change. **`W14` covers neither case 1** — the spawn-column shaft, rescued **once**, with no second teleport — **nor case 3**, the no-op where only `(x, 0, z)` may have changed |
| `L3` | unrun | gated on `A7`'s removal landing upstream in `codeblock` and being adopted here |
| `R1` | pass, **re-run owed** | `B48`'s fix rewrites `groups` on every registered node, a far wider blast radius than the `diggable` field beside it |
| `R3` | pass, **re-run owed** | thirty seconds, and it is the whole of what keeps `R5` partial |
| `R4` | pass, **re-run owed** | same blast radius as `R1` |
| `R5` | **partial** | its drop half passed at `7dc764f`; the knockback half rests on `R3` not having been re-run |
| `R6` | pass, **re-run owed** | same blast radius as `R1` |
| `R8` | unrun | the whole of `B48`'s evidence, at `ec02760` |
| `P1` | **partial** | the clone half passed at `8b27f2f`; the boot half has never been run, and a working checkout booting does not discharge it |
| `P2` | pass at `48cc63e`, **standing obligation** | re-run on 2026-09-08 and it stays here permanently: the entry says to run it **whenever a tracked file is added**, and nothing in either CI reads `.gitattributes` (`C15`, `C22`). Needed twice in two milestones — `G6`'s two files, then `G7`'s new directory, two textures and `menu/license.txt` |
| `P3` | unrun | the boot log, and the whole of `B19` and `B24`'s evidence |
| `P4` | unrun | the main menu shows the game's name, artwork and icon |
| `P5` | unrun | needs a release first — it is the ContentDB page as published |

**One sitting covers nearly all of it, and `P2` is in neither** — it touches no
engine and needs no world, so it is run from a shell whenever a tracked file is
added. The sitting is `G4`'s: `R8` at `ec02760`, with `R1`, `R4`, `R6` and `P3`
re-run beside it, plus `P4`, `P1`'s boot half, and the thirty seconds of `R3`
that closes `R5`. The `W4`, `W8` and `W9` re-runs at the current depth fold into
it or into a world of their own.

**The boot gap is real and narrower than it was.** `W10`–`W14` pass at
`3479e25`, record-only over `48cc63e`, and none of those observations is possible
without the game booting and a world being entered — so **the author's own
checkout boots**. What is still unrun is `P1`'s boot half, which is a **fresh
recursive clone** whose submodule objects nobody has locally, and that is the case
that catches a pointer nobody can fetch; and `P3`, the boot log. **No entry here
has criteria that the working-checkout boot alone satisfies**, and `P1` is
deliberately not widened to cover it: a clone that already holds the objects does
not test what `P1` exists for.

**The five 2026-09-08 results name no engine version.** It was not given, and
every other result in this document carries one.

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` settles the world's flags and its size, and
`mapgen_env.lua` writes the bounds into each chunk on the emerge threads: nothing
below `y = 0`, a bedrock plane at `y = 0`, and a barrier wall at the outermost
generated column. `cc_security` holds the two that are about the player rather
than the map — the clamp (`W8`) and the place it puts them (`W9`). `W4`–`W9` and
`W14` are `B50`.

Three facts about the world these checks run in, because each one changes a
method below.

- `mg_flags` carries `nobiomes`, so `mgflat` has no top or filler node and **the
  surface is stone** — there is no dirt and no grass anywhere until a program
  places some.
- The surface stands at `mgflat_ground_level` and the plane stays at `y = 0`, so
  the plane is always underground: reaching it means having a program clear a
  shaft. **`mgflat_ground_level` was 8 at `60259dd` and is 128 since `d6e4a12`**;
  wherever a number is unavoidable below, both are given.
- Since `60259dd` the clamp rescues a player **into their own column** rather than
  to spawn, so **`/teleport`ing to a negative `y` no longer leaves you there** —
  within 250 ms you are stood on the first room in the column you were over.

### W1 · A new world is flat and clean at spawn

**Why** — `mgflat` with `nobiomes` should give one flat clean level everywhere,
and only a world says whether it does.

**How** — create a new world with default settings and enter it. Look around,
then `/teleport` a few hundred nodes in one direction. Use `/teleport`, not
flight: `default_privs` dropped `fly` on 2026-09-02, and the pass below was
recorded before that, by flying.

**Pass** — flat ground to the horizon at one level. No trees, grass, flowers or
other decoration; no ore visible when a drone digs in; no cave mouths, no
dungeon, no water, no biome transition — the ground node and its colour never
change.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — flat and clean at
spawn and for a few hundred nodes out.

### W2 · The mapgen flags survive a world that was created with others

**Why** — without `override_meta = true` a world remembers the flags it was
created with and the game's setting is read once and never again. That third
argument to `cc_mapgen`'s one call is all this check covers.

**How** — create a world, enter it once, leave. Edit that world's `map_meta.txt`
to set `mg_flags` to something with caves and decorations, then re-enter.

**Pass** — the world is still flat and clean.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — a world re-entered
with caves and decorations written into its `map_meta.txt` is still flat and
clean. `override_meta = true` does what the one call needs it to.

### W3 · The world is flat far from spawn, and far from where anyone has been

**Why** — this distinguishes a setting that applied at world creation from one
that applies to every chunk the engine emerges, and only the second is what the
game promises.

**How** — `/teleport` into unemerged map and watch the ground generate ahead.
Use `/teleport`, not flight: `default_privs` dropped `fly` and `noclip` on
2026-09-02. **The distance in the old instruction is stale** — `mapgen_limit` is
1024, not 4096, so "several thousand nodes" now lands *outside* the world and past
the wall there is nothing to teleport into. Pick a distance inside 1024.

**Pass** — the same flat clean ground, generated live.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — ground generated live
several thousand nodes out is the same flat clean ground. The setting applies to
every emerged chunk, not only to world creation. **Passed by flying**, before
`fly` left `default_privs`; the finding it establishes is unaffected, but a
re-run takes the route above.

### W4 · The floor is there and you cannot fall through it [B50]

**Why** — the plane at `y = 0` is what stops a fall out of the world, and a
program must not be able to take it by accident. Its real subject is what is
**under** a removed tile: air, not stone.

**How** — have a program clear a shaft from the surface down to `y = 1`;
everything between is stone, which is **8 nodes at `60259dd` and 128 at
`d6e4a12`**, so a loop written for the old depth stops short. Climb or teleport
into the shaft and stand on the bottom. Then have the program `remove` one node
of the plane and look into the hole from beside it. Do not walk in — that is
`W8`. (The old method, `/teleport` to `y = -5`, no longer works: the clamp
answers it within 250 ms, so it tests `W8` and not the floor.)

**Pass** — the shaft bottoms out on a plane of bedrock at `y = 0` that the
program did not place and cannot remove by accident, you are standing on it
rather than falling, and what the hole shows under the plane is **air**. A shaft
that bottoms out on more *stone*, or a hole with stone under it, means
`mapgen_env.lua` never loaded and `mgflat`'s ordinary fill is still there — so
neither the floor nor the wall exists. Check the boot log for a
`register_mapgen_script` error, which is what an engine below 5.9 gives.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — re-run by the method
above, so the shaft was cleared, stood in, and the plane under it removed and
looked into from beside. The floor is at `y = 0`, the program cannot take it by
accident, and what is under it is air. `mapgen_env.lua` loads and runs on the
emerge threads, which also puts the engine at 5.9 or later.

Previously partial — **no commit, the uncommitted working tree of 2026-09-07** ·
engine 5.17.0 · 2026-09-07 — **established as a by-product of `W8`, not by the
method above.** The author dug a hole away from spawn and fell through it, so
there was a bedrock floor to cut through and air under it, but nobody had stood on
the plane at the bottom of a shaft or looked into a removed tile from beside it.
It was deliberately **not** backdated onto `f5f2385` or `60259dd`, both of which
landed on the rescue path in between; it is superseded here by a run against a
sha, which is the outcome that rule was holding out for.

### W5 · The wall stands, full height, all the way along [B50]

**Why** — the wall is written per chunk on the emerge threads, so its failure
mode is height and seams rather than presence, and no amount of reading
`mapgen_env.lua` settles that.

**How** — `/teleport` toward `+x` past 1000, then walk into the edge. Look up
along the face, and walk some way along `z` with the wall beside you.

**Pass** — an unbroken face, from the floor up out of sight, standing at the same
`x` all along `z`, with no gap where one mapchunk meets the next. Not a wall that
is there at eye level and absent thirty nodes up: that is the wall being written
only into the chunk containing the ground, and it is exactly the case a check done
from standing height would pass.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — an unbroken bedrock face
from the floor up out of sight, at the same `x` all along `z`, with no gap at a
mapchunk seam. **This is route one of `B50` and the check the finding was waiting
on**: walking off the generated edge is closed by something someone has walked to,
rather than by reading `mapgen_env.lua`.

### W6 · The drone's bound followed the number [B50]

**Why** — the only thing that proves the game's `minetest.conf` reached
`core.settings`, and that the drone's bound and the wall are one number rather
than two that happen to agree. CodeBlock reads `mapgen_limit` itself and nothing
here writes it into the mod, so a disagreement would let a program build where a
player cannot walk.

**How** — ask the drone to move past 1024 on any horizontal axis.

**Pass** — it refuses with *"The drone cannot leave the world (1024 nodes)"*,
naming **1024** and not 4096.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — the drone refuses and its
message names **1024**. So the game's `minetest.conf` reached `core.settings`, and
the drone's bound and the wall are the same number rather than two numbers that
happen to agree. **This was the last inferred part of `G6` decision 2**, which
until now rested on reading `mods/codeblock/lib/commands.lua:49`; nothing in this
repository writes the setting into the mod, and it did not need to.

### W7 · An existing world is re-bounded [B50]

**Why** — `mapgen_limit` is stored per world, so without `override_meta = true`
on `cc_mapgen`'s `set_mapgen_setting` call an old world keeps its old edge for
ever. This is the only thing that argument buys and the only route to seeing it
fail.

**How** — open a world created before this change, one whose `map_meta.txt` still
carries `mapgen_limit = 4096`, and walk or teleport out to 1024.

**Pass** — the edge is at 1024, not 4096. What this does **not** cover is under
*what ships broken* in `ROADMAP.md`: terrain already emerged beyond 1024 keeps no
wall, because the wall is written by the mapgen callback and nothing regenerates a
visited chunk.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — a world carrying the old
`mapgen_limit = 4096` in its `map_meta.txt` has its edge at 1024 when reopened.
That is the whole of what `override_meta = true` on `cc_mapgen`'s
`set_mapgen_setting` call buys, and it is the only route to seeing it fail.

### W8 · A player who falls through a program-made hole is put back [B50]

**Why** — a program may `remove` a floor tile, and `diggable = false` binds the
player rather than a program, so neither the wall nor the floor closes this;
`cc_security`'s clamp does. This check is *are you moved, and does the falling
stop*. `W9` is *is where you land a place you can be*.

**How** — `W4`'s shaft, then have the program `remove` one bedrock node at
`y = 0` under it — eight nodes down at `60259dd`, 128 at `d6e4a12` — then walk
into the hole. **In the same session, walk the wall and stand on the exposed
floor plane for a while**; that is the second pass condition below, and it is part
of running this check.

**Pass** — you stop falling and are put back **in your own column**: at the bottom
of the shaft you fell down, standing on a bedrock node the rescue laid where the
program removed one, `y` about **0.5**. You will be standing in a shaft you cannot
climb or dig out of, and the way out is to point the drone at the shaft wall —
the accepted trade, `ROADMAP.md` decision 7, not a failure here.

- **At spawn is a fail.** The destination was reversed at `60259dd`; arriving at
  spawn now means the column scan found no room in 64 nodes and fell back, which
  this setup does not produce. The check for the fallback is `W9` case 4.
- **The clamp must fire on neither the wall walk nor the exposed floor plane.** A
  clamp that moves a player standing legitimately at the boundary every few
  seconds makes the world unplayable at its own edge. The margins, traced in the
  code: a player's position is their feet and the plane's nodes span `y = -0.5` to
  `0.5`, so an exposed floor tile reads `0.5`, half a node above the `p.y < 0`
  test; and the wall occupies the outermost generated column, so the furthest
  standable column is one short of the horizontal bound.
- **A third failure mode is withdrawn, not owed** — the clamp firing on a player
  mid-join, before their position settles. The engine sets a player's position
  before adding them, and a player with no `PlayerSAO` does not appear in
  `core.get_connected_players()`. Someone who logged out mid-fall *is* teleported
  on rejoining, and that is the clamp working.

Result: pass, both halves — `60259dd` · engine 5.17.0 · 2026-09-07 — the fall
stops and the player is put back **in their own column**, at the bottom of the
shaft, on a bedrock node the rescue laid where the program removed one. Not at
spawn, which under this destination would have been a fail. **The near-miss half
is covered because the check's own instructions carry it**: walking the wall and
standing on the exposed floor plane are part of running `W8` as written since the
2026-09-07 rewrite, and the clamp fires on neither. That is what clears the
ambiguity the earlier passes carried — an unrun half reads as `partial` here, and
this one is no longer unrun. The margins traced in the code hold in a world: a
player on an exposed floor tile reads `y = 0.5`, half a node above the `p.y < 0`
test, and the furthest standable column is one short of the horizontal bound.

**An earlier result was retired here on 2026-09-07 rather than carried forward,
and this is what replaced it.** The author ran the check at `f5f2385` on
2026-09-07 and reported a pass — of a rescue **to the spawn point**, the
destination `60259dd` replaced — so the line was removed rather than moved, under
the rule that a result cannot survive a change to the code it exercised. The
retirement cost one re-run, and it bought a pass that names the code in the tree
rather than code that had since changed.

### W9 · The place the rescue puts you is a place you can stand [B50]

**Why** — a rescue that fires perfectly into a sealed column passes `W8` and is
still a softlock. This checks `standing_pos()` in `mods/cc_security/init.lua`: it
clamps the player's column inside the wall, writes `cc_mapgen:bedrock` at
`(x, 0, z)` if that node will not hold them, and scans up for the first height at
which both nodes a player occupies are clear. `repair_spawn()` is reached **only**
when that scan finds no room.

**How** — four cases, reading your `y` in each.

1. **The shaft you dug.** From spawn, have the drone remove the bedrock at
   `(0, 0, 0)` and the stone column above it, so the spawn column is a shaft.
   Walk in.
2. **The blocked column.** Have the drone remove a wall column so there is a way
   out of the world, then walk out through the gap, over ground the program has
   not touched.
3. **The no-op.** With the world otherwise untouched, fall out from a shaft
   elsewhere.
4. **The bound exhausted.** The scan gives up 64 nodes above
   `mgflat_ground_level` — 72 at `60259dd`, 192 at `d6e4a12` — and this is the
   **only surviving route into `repair_spawn()`**. Reuse case 2's way out: have
   the drone fill the column one node inside the wall, at the `z` you will walk
   out at, with stone from `y = 1` up past that height, then walk out at that same
   `z`. At 128 the pillar costs sixteen times what it did.

**Pass**, per case.

1. Moved back **once**, standing on a solid node, stationary, at the bottom of
   your own shaft — `y` about **0.5**, on a fresh bedrock tile. You will not be
   able to walk away, and since `60259dd` that is specified behaviour rather than
   a fail. **Fail:** any second teleport, or moved back but still falling. That is
   the defect exactly as reported on 2026-09-07, and making the floor whole under
   you is what prevents it.
2. Put back **one node inside the wall, at the same `z`**, standing on top of the
   stone surface — `y` about `mgflat_ground_level` + 0.5, so 8.5 at `60259dd` and
   128.5 at `d6e4a12`. **Fail:** your view is inside a node, or you arrive at `y`
   about 0.5. This is the only check of the clamp arithmetic: the wall stands *on*
   the outermost generated column, so the innermost standable column is one node
   in from it, and an off-by-one here puts you inside the wall.
3. **The only node anywhere that may have changed is `(x, 0, z)`** — the floor
   tile under your own column, remade as bedrock. Nothing near spawn may have
   changed at all; the rescue does not visit spawn on this path.
4. You arrive at spawn, in open air, free to move — `y` about
   `mgflat_ground_level` + 1, so 9 at `60259dd` and **129** at `d6e4a12`.
   **Fail:** you arrive embedded in a node, or the rescue does nothing at all.
   Building a solid pillar the full height of the scan and falling out at exactly
   its footprint is the case the bound trades away, and what it costs is the old
   behaviour — spawn — rather than a softlock.

Two false passes, because they are how the fix looks fixed without being fixed.

- **The `ignore` branch, and it is weaker than it was.** `minetest.get_node`
  reports `ignore` for an unloaded mapblock and that reads as an ordinary solid
  node, so a repair written on it would be skipped on exactly the tick that needs
  it — hence `get_node_or_nil` and the explicit test. But the rescue now works in
  the column the player is standing in, so it is nearly always resident.
  `load_area` still matters, because the scan reaches the whole depth of the world
  plus 64 above a player below `y = 0` and the top of that column need not be in
  memory. Of the four cases only **case 4** still puts a possibly non-resident
  area under a write.
- **Landing on the bedrock plane rather than the surface was the tell for a bad
  fix and is now the fix.** Exactly reversed by `60259dd`, so read it per case: in
  case 1 about 0.5 is the pass and landing up at the surface means the scan is not
  stopping at the lowest room in the column; in case 2 the surface is the pass and
  about 0.5 means the column was carved out rather than scanned up.

Result: pass, all four cases — `60259dd` · engine 5.17.0 · 2026-09-07 — the
shaft (case 1) rescues **once** and leaves the player stationary on a fresh
bedrock tile at the bottom of it, with no second teleport and no continued fall,
which is the defect reported on 2026-09-07 fixed. The **blocked column** (case 2)
puts them one node inside the wall at the same `z`, standing on top of the stone
surface and not embedded in it — so the clamp arithmetic is right, and the
off-by-one that would put a player inside the wall is not there. The **no-op**
(case 3) changes only `(x, 0, z)`. The **bound exhausted** (case 4) reaches
`repair_spawn()` and arrives at spawn in open air, free to move, which is the only
surviving route into that function and the only one that still puts a write into
possibly non-resident map.

**A pass was retired here on 2026-09-07 rather than carried forward, and this
replaces it.** All three cases as they then stood passed at `f5f2385` on
2026-09-07, out-of-range variant included; it was a result about a rescue **to the
spawn point**, which `60259dd` replaced, so case 2 no longer reached the code it
tested, case 3's assertion had gone vacuous and case 1's pass condition was
inverted. Carrying it would have been backdating a result across a change to the
code it exercised. Two of the four cases above are new with that rewrite and have
now been run for the first time.

### W10 · The wall is a barrier you can see through, and still a wall

**Why** — no finding id, and nothing was defective: the wall already stood, full
height and unbroken, and `W5` proves it. What changed is what it *looks* like, and
only a running world says whether the new appearance reads as an edge.

**How** — walk or `/teleport` to the world edge on any axis and face the wall.
Look at it from a few nodes back and from up against it, **in the middle of a
straight run** rather than at a corner. Then try to walk through it, try to place
a node on its far side, and punch it.

**Pass**, and all four parts are required.

- **A dark outline around every node face** — a regular grid across the whole
  wall, one cell per node, with sky visible through the middle of each cell. Not
  an outline only along the top and at the world's corners with clear glass
  between: that is the framed drawtype having come back, the engine drawing the
  wall as one connected pane, and from far enough back it passes for a clean edge.
- **No shadow band along the edge.** The ground and anything built near the wall
  is lit the same as ground in the middle of the world. That pair is
  `paramtype = "light"` and `sunlight_propagates` doing their job.
- **Still solid.** You are stopped at the column, and you cannot place a node
  through it onto its far side. **Sky past the edge proves nothing on its own** —
  a wall that failed to generate would also show sky, and better; seeing through
  it and being stopped by it have to be observed in the same place, in the same
  sitting.
- **Still nothing you can take.** It does not crack under a punch, drops nothing,
  and is in no inventory — the same properties bedrock has.

The floor is not part of this check: `W4` is that it is there, `W11` is what it
looks like.

Result: pass — `3479e25`, record-only over `48cc63e` · **engine version not
stated** · 2026-09-08 — reported by the author from a sitting in a world, against
the check as written, so the pass covers all four required parts and both near
misses: the wall shows a dark outline per node face with sky through the middle
in a straight run, no shadow band along the edge, you are stopped at the column
and cannot place through it, and it neither cracks nor drops. The last commit to
touch any of this game's Lua is `d6e4a12`, so this is a run against that code.
**Two limits of the evidence.** The engine version was not given and this line is
short that field. And the report was one word per check rather than a part-by-part
account, so which parts were observed separately is not recorded — both near
misses are observable to a runner following the steps, but only the steps say
they were looked for.

### W11 · The floor and the wall are the game's own artwork, and the floor does not tile

**Why** — no finding id, nothing defective: the author asked for bedrock *"more
black like in minecraft"*, and `cc_mapgen` now ships its own two 16×16 textures
instead of borrowing `default_obsidian.png` and `default_obsidian_glass.png`.
Before this ran, neither file had ever been rendered — both had only been decoded
back as bytes, which says nothing about what a wall or a floor of them looks like
from three nodes away.

**How** — have a program clear a shaft to the bedrock plane at `y = 0` and then
clear a **wide** expanse of it, twenty nodes on a side at least and more is
better. Stand on it, look straight down, then look **across it to its far edge at
a shallow angle** — tiling artefacts are far more visible there than from
directly above, so looking down at your feet and calling it clean is how this is
missed. Then go to the world's edge and look at the wall beside the floor where
the two meet.

**Pass**, and the second part is the one worth the trip.

- **The floor reads as black mottled rock**, distinctly darker and less blue than
  the obsidian it replaced. Anyone who remembers the old floor should be able to
  say which is which.
- **No tiling grid across the expanse, at any angle** — no repeating shape, no
  seam every sixteenth node, no line where one texture meets the next. This is
  what the wrapping blur exists for and the thing most likely to look wrong: a
  non-wrapping blur darkens or lightens the four edges of the tile, and a large
  floor turns into visible graph paper.
- **The floor and the wall read as one material**, dark and of a piece, rather
  than two nodes that happen to be adjacent.

A regular grid on the *wall* is `W10`'s pass; a regular grid on the *floor* is a
fail here. The two are next to each other and easy to conflate.

Result: pass — `3479e25`, record-only over `48cc63e` · **engine version not
stated** · 2026-09-08 — reported by the author from a sitting in a world, against
the check as written: the floor reads as black mottled rock, there is no tiling
grid across a wide expanse of it at a shallow angle, and the floor and the wall
read as one material. **The first rendering of either texture** — both had only
ever been decoded back as bytes. The last commit to touch this game's media or
Lua is `d6e4a12`. **Limit of the evidence:** one word per check was reported, not
a part-by-part account, so the shallow-angle look that this entry says is worth
the trip is covered by the steps having been followed rather than by a separate
observation. Engine version not given.

### W12 · A new world puts you 128 nodes above the floor

**Why** — no finding id. `mgflat_ground_level` goes from the engine's 8 to 128 —
declared in `settingtypes.txt`, defaulted in `minetest.conf`, and forced onto the
world by `cc_mapgen`. The bedrock plane stays at `y = 0`, so the number is how
much stone there is between the surface and the bottom of the world.

**How** — create a **new** world with default settings, enter it, and read your
own position with `/status` or the debug display, `F5`. Have a program clear a
shaft and confirm the bottom of it is bedrock at `y = 0`. Then open Advanced
settings → Content: Games → Codecube.

**Pass** — you are standing on stone at `y` about **128.5**, with solid stone all
the way down to the bedrock plane at `y = 0` — the floor did not move, the surface
did — and **Surface height** is offered at 128 beside **World half-extent** at
1024, which is a server owner's route to it and the reason it is a setting rather
than a constant. **Fail: `y` about 8.5.** That is the engine's own default, and it
means the game's `minetest.conf` did not reach `core.settings` or `cc_mapgen`'s
forced `set_mapgen_setting` did not take — the same failure `W6` catches for
`mapgen_limit`, by the same mechanism, and it reads as a perfectly ordinary world
unless you look at the number.

Result: pass — `3479e25`, record-only over `48cc63e` · **engine version not
stated** · 2026-09-08 — reported by the author from a sitting in a world, against
the check as written: a new world stands the player on stone at `y` about 128.5,
not the engine's 8.5, with stone down to the bedrock plane at `y = 0`, and
**Surface height** is offered at 128 in Advanced settings. So the game's
`minetest.conf` reached `core.settings` and `cc_mapgen`'s forced
`set_mapgen_setting` took — the same mechanism `W6` proves for `mapgen_limit`.
The last commit to touch this game's Lua or its conf is `d6e4a12`. **Limits:**
engine version not given, and the report was one word per check, so no `y` value
was read back — the pass is against the numbers this check names.

### W13 · An existing world's surface moves to 128 when you open it

**Why** — the engine writes every `mgflat_*` parameter into a world's
`map_meta.txt` when the world is created, so a world made at ground level 8 keeps
8 for ever unless `override_meta = true` overrides it. `W7` is the same check for
`mapgen_limit`; that the argument also carries a non-`MapgenParams` mapgen key was
read out of the engine source — `MapgenFlatParams::writeParams` at 5.9.0 writes
the key, and `MapSettingsManager::setMapSetting`'s `override_meta` branch is
generic — and **reading is not running**.

**How** — open a world created before this change, one whose `map_meta.txt` still
says `mgflat_ground_level = 8`, and walk out into ground that has **never been
generated**, well past anywhere you visited before. Watch it emerge ahead of you.
Close the world and read the key.

**Pass** — the newly generated ground comes in at `y = 128`, not 8, there is a
step where the old terrain meets the new, and `mgflat_ground_level = 128` in that
world's `map_meta.txt` afterwards. **A seamless world is the failure here** — new
ground arriving at 8 like the old ground looks consistent and correct, and this is
the only check in this document where the tidier-looking outcome is the wrong one.
Ground already generated keeps the height it has; that is under *what ships
broken* in `ROADMAP.md`.

Result: pass — `3479e25`, record-only over `48cc63e` · **engine version not
stated** · 2026-09-08 — reported by the author from a sitting in a world, against
the check as written: a world created before the change, carrying
`mgflat_ground_level = 8` in its `map_meta.txt`, generates new ground at `y = 128`
with a step where the old terrain meets the new, and the key reads 128 afterwards.
So `override_meta = true` carries a non-`MapgenParams` mapgen key too, which until
now was read out of the engine source and `W7`'s pass for `mapgen_limit`. **This
is the entry `code-expert` called the thing most likely to be wrong**, and the one
check here whose tidier-looking outcome — a seamless world — is the failure. The
last commit to touch this game's Lua or its conf is `d6e4a12`. **Limits:** engine
version not given, and one word per check was reported, so neither the step nor
the `map_meta.txt` line was read back to me; the pass is against the check as
written.

### W14 · The rescue still knows where the surface is [B50]

**Why** — `B50`'s rescue, re-checked under a depth it was not written for.
`cc_security` derived its spawn fallback and its scan bound from `(ground or 8)`;
with the game's default now 128 that would have put a rescued player at `y = 9`,
inside a hundred and twenty nodes of solid stone. It is now a single `or 128` at
the definition. The defect was never committed and carries no id.

**How** — three cases, reading your `y` each time. **Cases 2 and 3 are the
check**; case 1 is here so the three read as one setup, and it is the only one
whose pass value did not move with the depth, so passing it alone says nothing
about the constant this check exists for.

1. **Through the floor** — `W8`'s setup at the new depth: clear a shaft to
   `y = 1`, `remove` one bedrock node under it, walk in.
2. **Clamped in from outside the wall** — `W9` case 2's setup, over ground a
   program has not touched.
3. **The spawn fallback** — `W9` case 4's setup at the new depth: fill your exit
   column solid past the scan bound, then walk out.

**Pass** — case 1: `y` about **0.5**, at the bottom of your own shaft, on a fresh
bedrock tile. Case 2: `y` about **128.5**, standing on top of the stone surface
one node inside the wall; **fail about 8.5**, which would mean the scan stopped at
the old surface height and left you buried. Case 3: spawn, open air, free to move,
`y` about **129**; **fail about 9**, the exact shape of the defect that was
caught. **An 8 or a 9 anywhere in the results means a stale constant survives
somewhere in the rescue path.**

**Not a fault, recorded so it is not mistaken for one:** the rescue's `load_area`
column grew from 5 mapblocks (~80 kB) to 13 (~210 kB), because it spans `y = 0` to
193 now, and the scan reads up to ~128 more nodes before it finds the surface.
Bounded, and at most four times a second per out-of-box player. If a rescue feels
slower than it did, that is why and it is deliberate.

Result: pass, all three cases — `3479e25`, record-only over `48cc63e` · **engine
version not stated** · 2026-09-08 — reported by the author from a sitting in a
world, against the check as written, so the pass is on cases 2 and 3 as well as
the cheap case 1: through the floor lands at `y` about 0.5, clamped in from
outside the wall lands on top of the stone surface at about 128.5 rather than
buried at 8.5, and the spawn fallback arrives in open air at about 129 rather than
9. No 8 or 9 anywhere, so no stale constant survives in the rescue path and the
single `or 128` at the definition is what the world sees. **This is the check that
stood behind the `(ground or 8)` defect**, and it is now run rather than reasoned
about. Engine version not given, and the report was one word per check rather than
three `y` values.

---

## L · Light

`mods/cc_day/init.lua` is one `on_joinplayer` calling five player methods.

### L1 · Permanent noon, no sky objects [A7]

**Why** — `override_day_night_ratio(1)` pins the light level and the other four
calls remove the sky objects. They are separate effects, so a partial result has
to say which of the two failed.

**How** — enter a world and look up. Advance time with `/time` and look again,
including `/time 5000`, which is dawn.

**Pass** — full daylight regardless of the time of day; no sun, no moon, no
stars, no clouds, and no sunrise or sunset glow.

Result: pass — `b9bf82b` · engine 5.17.0 · 2026-09-01 — full daylight at
every hour, and no sun, moon, stars or clouds at any time of day. No sunrise or
sunset glow either, which is what this re-run was for.

Previously partial at `7f649d8`: **part of the sun was visible at `/time 5000`**
— the sunrise texture, which `set_sun{visible = false}` leaves alone. `B47`.
Adding `sunrise_visible = false` to `cc_day` was enough on its own, which also
answered the open question in that finding: `codeblock`'s duplicate bare
`set_sun` does **not** put the field back, so `A7` was never a prerequisite.

### L2 · It survives a rejoin, and it applies to a second player

**Why** — the callback is `on_joinplayer` and these are per-player settings, not
world settings. A rejoin is the path that matters, and a second player is what
would catch a setting applied to whoever joined first.

**How** — leave the world and rejoin. On a server, have a second player join
after the first.

**Pass** — the same for both, every time.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — survives a rejoin.
The second-player half was not exercised: singleplayer only.

### L3 · Permanent noon still holds once the duplicate is removed [A7]

**Why** — `codeblock` registers its own `on_joinplayer` calling the same five
methods, annotated `-- TODO: TEMP fix`, and `A7` removes that copy, leaving
`cc_day` the only thing setting the sky. Until this runs, `cc_day` being
sufficient on its own is an assumption.

**How** — run this **only once the game has adopted a `codeblock` release with
the block removed**; the edit is upstream, so nothing in this repository will show
that it has landed. Then re-run `L1` and `L2`, looking at dawn and dusk in
particular: the one field that distinguishes the two copies is
`sunrise_visible = false`, which only `cc_day` has.

**Pass** — `L1` and `L2` both still pass with the mod's copy gone.

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
them (`A8`).

**The `B50` rescue is the one place in this mod that writes to the map**; every
other rule in it denies. Worth knowing here, because "`cc_security` only ever
denies" is otherwise the natural summary of this group and it is no longer true.
Since `60259dd` it writes **one node** on the ordinary path — the floor tile under
the rescued column — and only the spawn fallback clears anything. Those two read
with the rest of the world's bounds and are `W8` and `W9`, not here.

### R1 · Nothing is diggable

**Why** — the override pass runs once at `on_mods_loaded` over
`minetest.registered_nodes`, so a node registered later — by another mod, or by a
future `default` trim — is not covered. And since `B48` an inner `pairs` over every
node's `groups` runs in the same loop: if it errors on any single node,
`register_on_mods_loaded` aborts and **every node after that point keeps
`diggable = true`**. Table iteration order is not stable, so a partial failure hits
a different set of nodes on every boot and one punch on one wall would miss it.

**How** — punch and hold on the ground, on a wall the drone built, and on several
different block types including one from `wool` and one from `default`. Try a
block type the drone can place but you have not seen before, and try it in a fresh
world rather than the one already open.

**Pass** — nothing breaks, anywhere, on any node.

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

**Why** — two halves, and only the first can be checked by playing normally.
`handle_node_drops` is unreachable while `diggable = false` holds on every node: it
is the fallback for the one gap `R1` names, a node registered after the override
pass. **A check that cannot be run reads exactly like one that passed**, so the
drop half has to reproduce that gap deliberately. Ruled out against the 5.17.0
reference on 2026-09-02: no built-in chat command digs a node — `/give` and
`/giveme` put an item in an inventory, a different path, and nothing exposes
`core.dig_node`; privileges do not help, because `diggable = false` is a node
property, *"if false, can never be dug"*, so `node_dig` refuses before drops are
computed however privileged the player; and the drone writes with `set_node` and
`VoxelManip` (`lib/commands.lua`, `lib/shapes.lua`), neither of which computes
drops, so `R4` does not exercise this either.

**How** — open the inventory. Then, to reach the drop half, comment out **both**
the `diggable = false` line and the `groups = groups` line in
`mods/cc_security/init.lua`'s `override_item` call, restart the server, dig a node
by hand, and revert both lines. Both are needed since `B48`: the hand digs by
groupcap, so with the groups stripped `diggable = true` on its own may leave
nothing the hand can break and the check would silently do nothing instead of
failing. This is not cheating the check — an uncovered node is exactly the
situation the guard exists for.

**Pass** — the inventory formspec is blank; the node dug with the lines commented
out disappears and **no item appears**, none on the ground and none in the
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

**Why** — `calculate_knockback` is replaced to return 0.

**How** — take a hit, from another player or from anything that would push you.

**Pass** — you are not moved.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — no knockback.

### R4 · The drone can still build [R1 must not have broken it]

**Why** — the widening control. `diggable = false` is a property of the node for
a *player's* tool and the drone writes the map directly, so it must be unaffected;
this is the check that says a restriction has not been made so broad it disables
the point of the game. It also guards the `B48` loop, where six groups have just
vanished from under whatever might have been reading them.

**How** — run `stairs.lua`, then a program that places and one that removes
blocks. Run it in the same session as `R8`.

**Pass** — the drone places and removes normally.

Result: pass — `6f2409e` · engine 5.17.0 · 2026-09-02 — re-run after `A8` changed
`cc_security`. The drone still places and removes normally, so chaining the drop
handler and declaring `last_mod` have not narrowed the game.

Result: pass — `c042364` · engine 5.17.0 · 2026-09-01 — the drone places and
removes normally with every node undiggable, and still does with the `S8` guard
denying every player-initiated inventory action. That second run was the point:
the guard is deliberately total, and this is what would have caught the editor or
a tool depending on an inventory move. Also passed at `7f649d8`, before the
guard.

### R5 · The chained drop handler still hands out nothing [A8]

**Why** — a regression check, not a composition one. `A8` replaced
`function minetest.handle_node_drops() end` with a call to the handler it
captured, given an empty drop list, and nothing else in this game assigns either
global — `grep -rn "handle_node_drops\|calculate_knockback" mods/` finds only
`cc_security` — so the captured value is the engine default and the new code should
behave exactly like the old. `previous_drops` being non-nil is read from the
5.17.0 reference and has never been run, and a `nil` there would error on the one
path that is meant to be silent.

**How** — re-run `R3`, and run `R2` **by its drop method**, which now needs two
lines commented out rather than one. That is the only way to put a real dig
through the chain; no second mod, nothing to install. Without it this proves
nothing `R3` does not already prove.

**Pass** — both still pass. No item entity ever appears, and nothing pushes you.

**Untested by choice, recorded so it does not read as an omission.** `A8`'s other
half — that `last_mod = cc_security` makes this mod's assignment the one that
survives — needs a second mod installed that assigns the same globals, and none
ships here; building one for the occasion would be testing a composition this game
does not have. The scenario it defends is a server owner adding a worldmod from
ContentDB, and even then the game's promise is held by `diggable = false`: the
drop handler matters only once something has already re-enabled digging, at which
point the owner has deliberately changed the game. Decided by the author on
2026-09-02.

Result: partial — `7dc764f` · engine 5.17.0 · 2026-09-02 — **the half that could
have broken is done.** `R2`'s drop method passed: the chain fires, hands an empty
list to the captured handler, and nothing drops. `R3` was not re-run on current
code, so the knockback half is still resting on its 2026-09-01 pass. The risk
there is small — `A8` left `calculate_knockback` byte-identical and nothing
competes for it — but small is not none, and thirty seconds closes it.

### R6 · A bookshelf opens nothing you can use [S8]

**Why** — `default:bookshelf` carries a node formspec containing
`list[current_player;main]`, so it reaches around the blanked inventory formspec:
it is a way into the player's own inventory even when nothing can be moved into
the bookshelf itself. The first `S8` fix closed only the bookshelf half and left
that standing.

**How** — have a program place a `bookshelf`, then right-click it. Try to drag
one of the two drone tools from the inventory panel into the bookshelf's own slots,
and try to drag it back out. **Then drag a drone tool from the hotbar into one of
the rows below it.** Leave the world, rejoin, and open the same bookshelf. Run
`R4` beside it, and fold this into the `B48` re-runs — the three
`allow_metadata_inventory_*` callbacks are set by the same `override_item` call in
the same loop, so a mid-loop error takes them out alongside `diggable`.

**Pass** — the formspec still opens, because that part is in node metadata and
`cc_security` cannot reach it, but no item moves in either direction, nothing
leaves the hotbar, and the bookshelf is empty after the rejoin. The three
`allow_metadata_inventory_*` callbacks return 0 on every registered node, so the
denial is not specific to bookshelf; a chest or furnace would behave the same if
one existed.

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

**Why** — neutralising an ABM by replacing its `action` is not documented
behaviour, because Luanti has no API to unregister one, so nothing but this says
whether it works. On the code before `B49` all three cases below change, which is
what makes this a real check rather than an assertion.

**How** — have a program build the three things below, then leave them alone for
**at least five minutes** of running server and look again. The ABMs run on 6- and
8-second intervals with a 1-in-50 chance, so a glance after thirty seconds proves
nothing; build many of each if you want it faster.

1. A patch of `dirt` with `dirt_with_grass` next to it, and another `dirt` with a
   `grass_3` on top.
2. A floor of `dirt_with_grass` with an opaque roof — `stone` will do — one node
   above part of it.
3. A `sapling`, in the open.

**Pass** — nothing has changed. The `dirt` is still `dirt`, the roofed
`dirt_with_grass` is still grass, and the sapling is still a sapling. Before the
fix, 1 turns to grass, 2 reverts to plain `dirt` — destroying what the program
placed — and 3 becomes a tree that may overwrite blocks above it; if any of the
three still changes, the `action` replacement does not take effect and the fallback
is deleting the two ABMs from `mods/default/functions.lua` directly. **Also
confirm a sapling has not simply frozen the server:** the timer stopper returns
`false`, and **`0` is truthy in Lua 5.1**, so had it returned `0` every node timer
in the world would restart for ever instead of stopping.

Result: pass — `d16f9bb` · engine 5.17.0 · 2026-09-02 — nothing changed after
five minutes: the `dirt` stayed `dirt`, the roofed `dirt_with_grass` stayed
grass, the sapling stayed a sapling, and the server kept running. The `action`
replacement takes effect, so the fallback of deleting the two ABMs from
`mods/default/functions.lua` is not needed.

### R8 · No node ever plays a dig animation [B48]

**Why** — the outcome and the animation are different claims and only the
animation is new. Every node was already undiggable at `R1`; what `B48` changes is
that the client no longer *predicts* a dig it is about to be refused, so a node
staying put proves nothing here. The observation is what the screen and the
speakers do during the punch.

**How** — punch and **hold** on each of three nodes, for a full two seconds each,
close enough to see the face clearly and with sound on. The fix is at `ec02760`,
split out of `G6` so the `G4` fix stands separately; `f5f2385` carries it too and
either names the same `cc_security` override pass.

1. `wool`, any colour. Was `oddly_breakable_by_hand = 3`, and is the node that
   produced the finding: it cracked through all five stages and then stayed.
2. `default:leaves`. Was `dig_immediate = 3`, so before the fix it cracked
   *instantly*, in a single frame. It is the fastest case and the one where a
   partial strip would still show.
3. `default:stone`. `cracky`, never hand-diggable, so it never cracked and must
   still not. The control: a stone that now behaves differently means something
   other than the digging groups was touched.

Then confirm the strip did not cost anything else — wool must still show its
colour and `leaves` must still look like leaves, because the fix keeps every
non-dig group deliberately and colour, flammability, attachment and decay all ride
on them. Run `R4` in the same session; this change edits the loop `R4` guards.

**Pass** — on all three, **no cracking texture appears at any stage**, not stage
one and not a single frame, and **no dig sound plays**. A block that does not
break while the first crack stage still flashes on `leaves` is the whole defect
reading as a pass, and only holding the punch and watching the face catches it; a
`wool` that stops cracking while `leaves` still flashes means the group list is
incomplete, not that the fix works. The nodes are also still there afterwards,
which is `R1`'s claim and not this one.

Result: unchecked

---

## P · Packaging, boot and install

### P1 · A fresh recursive clone boots

**Why** — this catches a submodule pointer naming a commit nobody can fetch,
`reference is not a tree`, which is invisible from a working tree that already has
the object. **Only a clone whose submodule objects are not already local covers
that**, which is why the author's own checkout booting does not discharge it. It is
also the gate the `release-codecube` skill runs before a tag.

**How**, in bash — `git clone --recurse-submodules` into an empty directory, run
`bash scripts/check_game.sh` inside it, put it in Luanti's `games/`, create a
world, enter it.

**Pass** — both submodules populate from the HTTPS remotes in `.gitmodules`,
`check_game.sh` passes inside the clone, and the game boots into a playable world.

Result: partial — `8b27f2f` · 2026-09-01 — the clone half only. A fresh
`git clone --recurse-submodules` populated both submodules from the HTTPS remotes
in `.gitmodules`: `codeblock` `2647228` (`v0.4.0-98-g2647228`) and `vector3`
`16621648` (`v1.5`), so neither pointer names a commit nobody can fetch, and
`check_game.sh` passes inside the clone. **Not booted in Luanti** — the half that
says it is playable is still unchecked.

### P2 · The release archive holds only what a player needs [C15]

**Why** — `.gitattributes` decides what reaches a player and **nothing in either
CI checks it**, so a file added to the repository ships unless a rule excludes it,
and nothing fails locally when one does. This is the half of `C15` that reading
cannot settle. Run it whenever a tracked file is added, not only at a release.

**How**, in bash — `git archive --format=zip HEAD -o /tmp/codecube.zip` and list
it. Note the entry count and the total size **with the method**, so the next run is
comparable; the last measurement was 494 entries and 1.95 MB zipped by
`git archive --format=zip`, at `48cc63e`.

**Pass** — absent: `.claude/`, `.reports/`, `.github/`, `scripts/`, art sources,
and none of `CLAUDE.md`, `ROADMAP.md`, `TODO.md`, `AUDIT.md`, `PLAYTEST.md` or
`CONTENTDB.md`. Four things **are** present and the absence of any is a fail:
`menu/*.png`, because the main menu reads it; `menu/license.txt` beside them and
`mods/cc_mapgen/license.txt` with its two textures, because a licence notice has
to travel with what it licenses and nothing else in the archive states the media
licence (`C22`); and `THIRD-PARTY-LICENSES.md`, for the same reason. A missing
`menu/license.txt` most likely means the file was never committed.

Result: pass — `48cc63e` · engine n/a, this check touches no engine ·
2026-09-08 — 494 entries, **1.95 MB zipped** by `git archive --format=zip`. Every
clause checked, not inferred. Absent, zero entries each: `.claude/`, `.reports/`,
`.github/`, `scripts/`, `*.svg`, `*.xcf`, `*.blend*`, every top-level dotfile,
and all six record documents including `CLAUDE.md`. Present, all four: the three
`menu/*.png`; `menu/license.txt` beside them; `mods/cc_mapgen/license.txt` with
`cc_mapgen_bedrock.png` and `cc_mapgen_barrier.png`; `THIRD-PARTY-LICENSES.md`.
**The size is noted, not accounted for** — 1.93 → 1.95 MB is more than the two
16×16 textures (a few hundred bytes) and the two licence files (about 2 kB)
explain, and the remainder was not tracked down. This settles `C15`'s
archive half **for this commit only**: nothing in either CI reads
`.gitattributes`, so the next tracked file ships or not with nothing failing.

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

**Why** — `B19` and `B24` were fixed directly rather than left to `A13`, so this
can ask for nothing at all instead of asking you to count seven known messages and
hope no eighth is hiding among them. Luanti deduplicates deprecation warnings by
message, so a count here is of distinct messages and not of occurrences — that is
what hid the two `TileDef.image` warnings behind the `formspecs` warnings until
`B20` removed them, and a single occurrence of anything new is worth a finding.

**How** — watch the log while a world loads, from a cold start.

**Pass: nothing.** No `NodeResolver` errors, no deprecation warnings, nothing red
or yellow at all. The seven that should now be gone, so a re-appearance is
recognisable: five `NodeResolver` errors from four `default` log schematics
embedding `flowers:mushroom_brown` and `flowers:mushroom_red` (`B19`, now aliased
to `air` in `cc_mapgen`), and two `TileDef.image` deprecation warnings, from
`default`'s furnace and from `cc_security`'s `override_item` pass re-processing it
(`B24`, now `name =`). **If either is back, `default` has been re-vendored** and
took the fix with it — `B24`'s especially, since it is one word inside a
third-party file. `B48` makes this worth more than it was: `override_item` is now
handed a rebuilt `groups` table rather than the one already there, so whatever the
pass re-triggers, it re-triggers against something different.

Result: unchecked

### P4 · The main menu presents the game

**Why** — `menu/*.png` is what the menu reads, and it is the one thing
`.gitattributes` deliberately keeps in the archive; a `P2` rule written too broadly
would break this and nothing else would notice.

**How** — open Luanti's main menu with the game installed and select it.

**Pass** — the game's name, its menu artwork and its icon all appear.

Result: unchecked

### P5 · The ContentDB page reads as a page [C20]

**Why** — **images are not visible inside Luanti**, so an instruction that
depended on an icon has lost its object for exactly the readers it was written
for. Needs a release first: this is the page as published.

**How** — open the package page on ContentDB and read the long description as
someone who has just arrived there. Then read it **from inside Luanti**, in the
content browser, not only in a web browser — that is the reader the rule exists for
and the one a web preview does not show you.

**Pass** — it says what the game contains, what distinguishes it and how to play
it once installed. No heading repeating the title, no badges, no screenshots, no
licence line, no link to the repository or back to the page itself. Every
instruction is complete as words.

Result: unchecked

---

## Revisions

Newest first.

- **2026-09-08, `3479e25`, record-only over `48cc63e`.** `W10`–`W14` pass, so the
  counts move to **23 pass and 5 unrun**; `W4`, `W8` and `W9` stay owed re-runs,
  and the *what needs action* table now says why `W14` discharges none of the
  three. The boot gap is recorded as **narrower, not closed** — the passes at
  `3479e25` are unobservable without the game booting, so a working checkout
  boots, while `P1`'s fresh-clone boot half and `P3` stay unrun; `P1` is
  deliberately **not** widened, because a clone that already holds the submodule
  objects does not test what it exists for. **Every check in all four groups was
  rewritten to the Why / How / Pass shape**, at the author's instruction — *"no
  story, no tens of lines of background"*. No `Result:` line was changed. Two
  facts left this document because another already holds them: the three findings
  the 2026-09-01 rounds produced (`AUDIT.md`), and the barrier texture's change of
  source file on 2026-09-07 (`ROADMAP.md` `G7`).
- **2026-09-08, `d6e4a12`.** `W10`–`W14` gained a sha and stayed `unchecked`.
  `## How a check is written` and `## Where it stands` added — the counts existed
  nowhere before, and `TODO.md` had been carrying the action list instead, which
  is exactly the duplication that goes stale. Two recording rules written down:
  name both commits at a record-only commit, and results newest first within an
  entry, which is the opposite of the sibling `codeblock` project's convention.
  `R5` put back in group order.
- **2026-09-08, `6a0258a`.** `P2` now names the four things that must be
  **present** in the archive, not only what must be absent: a licence notice that
  does not ship states nothing (`C22`).
- **2026-09-07, `93b8ea1` plus an uncommitted tree.** `W10` added for the
  translucent barrier, then `W11`–`W14` for the game's own textures and the
  world's new depth — five checks with no sha at once, the most this document has
  carried. `W4`, `W8` and `W9` put on notice for re-runs, and the `W` methods
  rewritten to carry **both** depths wherever a number was unavoidable rather than
  being written for a world nobody had run them in.
- **2026-09-07, `60259dd`, twice in one day.** First the rescue's destination was
  reversed at the author's request, and `W8`'s and `W9`'s passes at `f5f2385` were
  **retired rather than carried** — `W8`'s pass condition inverted, `W9` case 2 no
  longer reached `repair_spawn()`, case 3's assertion gone vacuous. `W9` was
  rewritten around four cases, two of them new: the blocked column, the author's
  *"nearest free block above him"* and the first check of the clamp arithmetic,
  and the bound exhausted, the only surviving route into `repair_spawn()`. Then
  **the whole `W` group passed, six for six, and `B50` closed** on both routes;
  `W6` and `W7` were first runs of checks nobody had ever run. The retirement cost
  two re-runs and is what makes every remaining result checkable.
- **2026-09-07, `578b364` plus an uncommitted tree.** `W4`–`W8` added for `B50`;
  `R8` added for `B48`, with `R1`, `R4`, `R6` and `P3` marked for re-running
  beside it; `R2`'s drop method corrected to comment out `groups = groups` as
  well. `W4`'s and `W8`'s methods were stale and could not have been run as
  written — `W4` teleported to `y = -5`, which the clamp now answers, and `W8`
  needed the shaft first. The `R` intro corrected: `cc_security` writes to the map
  in exactly one place.
- **2026-09-01 over three rounds, and 2026-09-02.** `P2` and half of `P1` at
  `8b27f2f`; the `W`, `L` and `R` groups at `7f649d8`; `L1` and `R6` at `b9bf82b`
  against the fixes those produced; `R6` and `R4` again at `c042364`. All played
  by the author on Luanti 5.17.0 — **recovered from the engine's own debug log
  afterwards, not noted at the time.**
- **Written 2026-08-30 at `54a2b7e`.**
