# Playtest — Codecube (the game)

The manual checks nothing else here can reach. **This game has no test suite at
all** — `scripts/check_game.sh` verifies that the game *assembles*, not that it
behaves, and luacheck reads four files without running them. So every claim about
what the game actually does in a world rests on reading four short Lua files, and
this document is where that gap is written down rather than rediscovered from
prose in `ROADMAP.md` and `AUDIT.md`.

The mod's own manual checks are separate and are the larger set:
`mods/codeblock/PLAYTEST.md`. Nothing here re-checks the drone, the editor, the
sandbox or the API. What is checked here is the world those run in, and what a
player gets when they install the package.

`PLAYTEST.md` carries its own `export-ignore` line in `.gitattributes`, so this
file never ships to a player.

Groups are lettered **W** (world and mapgen), **L** (light), **R**
(restrictions) and **P** (packaging, boot and install). Those letters are
deliberately none of `B`, `S`, `C`, `A` or `F`, so a check id can never be read
as a finding id, and none of `G1`–`G7`, the milestone lettering in `ROADMAP.md`.

## How a check is written

Every entry takes this shape. It is written down here because someone adding a
check opens this file and not an agent definition.

```
### <id> · <what a pass means, as a sentence> [<finding ids>]

<one or two sentences on what the check is really about, where that is not
obvious from the title — especially where a wrong result would look like a
right one>

1. <a numbered step, done in a running world>
2. <the next one>

**Pass:** <what distinguishes a pass from something that merely did not crash>

Result: unchecked
```

Two rules about the steps, and both were bought with a wasted session.

- **Hand the runner an actual program or command, not a description of one.** A
  step that says "have the drone build a large cube" is a step the runner has to
  design before they can run it, and two runners will design it differently. Give
  the program.
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
date**: a pass recorded three milestones ago is not evidence about today's code,
and the point of the line is that a stale pass reads as stale rather than as
current. A `fail` is not a finding — report it and let `AUDIT.md` allocate or
widen an id.

Four more rules, each of which this project has needed.

- **Name both commits when the checkout was at a record-only commit.** If the
  tree that was run has no code change of its own — a documentation or record
  commit sitting on top of the code being checked — write it as
  `` `2feadb1`, record-only over `24842d3` ``, so the reader can see which
  commit the behaviour actually came from.
- **Results are listed newest first within an entry.** An entry accumulates its
  history downwards, so the top line is what the check most recently said. `R4`
  and `R6` are the two entries here with more than one result and both read that
  way.
- **A result is never carried across a change to the code it exercised.**
  Backdating a pass onto a later commit, or leaving one in place after the code
  moved, produces something that looks like evidence and is not. Retire it and
  re-run instead. That rule cost this project two re-runs on 2026-09-07 and is
  what makes every remaining result checkable.
- **Never move a result off `unchecked` on reading.** Only a person running it in
  a world can do that.

## Where it stands

| | |
|---|---|
| Entries | **30** |
| Live checks | 30 |
| Most recent result a `pass` | **18** |
| `partial` | 2 |
| `fail` | 0 |
| Unrun (`unchecked`) | **10** |
| Results retired | 2 — `W8` and `W9`, both at `f5f2385`, on 2026-09-07 |
| Findings closed by a check | `B47`, `B49`, `B50`, `S8` |

**What needs action**, and it is the list — `TODO.md` points here rather than
keeping a second copy.

| Check | State | Why it needs action |
|---|---|---|
| `W3` | pass, **method stale** | it passed by teleporting "several thousand nodes" out, which now lands outside a world whose limit is 1024. The pass is still what was seen at `7f649d8`; the instruction has to be re-read before it is re-run |
| `W4` | pass, **re-run owed** | passes at `60259dd`, where `mgflat_ground_level` was 8. `d6e4a12` moved it to 128 and the rescue derives its heights from that number |
| `W8` | pass, **re-run owed** | same reason as `W4` |
| `W9` | pass, **re-run owed** | same reason as `W4` |
| `W10` | unrun | the barrier is see-through and still a wall. Sha `d6e4a12` |
| `W11` | unrun | the game's own textures, and the floor not showing a tiling grid. Sha `d6e4a12` |
| `W12` | unrun | a new world puts you 128 nodes above the floor |
| `W13` | unrun, **run first** | an existing world's surface actually moving. It is the whole point of forcing the setting, and `code-expert` calls it the thing most likely to be wrong |
| `W14` | unrun, **run first** | the rescue reading the new depth. It stands behind a real defect the same change introduced and caught — a `(ground or 8)` fallback that would have put a rescued player inside 120 nodes of stone |
| `L3` | unrun | gated on `A7`'s removal landing upstream in `codeblock` and being adopted here |
| `R1` | pass, **re-run owed** | `B48`'s fix rewrites `groups` on every registered node, a far wider blast radius than the `diggable` field beside it |
| `R3` | pass, **re-run owed** | thirty seconds, and it is the whole of what keeps `R5` partial |
| `R4` | pass, **re-run owed** | same blast radius as `R1` |
| `R5` | **partial** | its drop half passed at `7dc764f`; the knockback half rests on `R3` not having been re-run |
| `R6` | pass, **re-run owed** | same blast radius as `R1` |
| `R8` | unrun | the whole of `B48`'s evidence, at `ec02760` |
| `P1` | **partial** | the clone half passed at `8b27f2f`; the boot half has never been run |
| `P2` | pass at `48cc63e`, **standing obligation** | re-run on 2026-09-08 and it stays in this table permanently rather than closing: the entry says to run it **whenever a tracked file is added**, and nothing in either CI reads `.gitattributes`, so the next tracked file ships or does not with nothing failing (`C15`, `C22`). It has been needed twice in two milestones — `G6`'s two files, then `G7`'s new directory, two textures and `menu/license.txt` |
| `P3` | unrun | the boot log, and the whole of `B19` and `B24`'s evidence |
| `P4` | unrun | the main menu shows the game's name, artwork and icon |
| `P5` | unrun | needs a release first — it is the ContentDB page as published |

**Two sittings cover all of it, and `P2` is in neither** — it touches no engine
and needs no world, so it is run from a shell whenever a tracked file is added.
One sitting is `G4`'s and it is small: `R8` at `ec02760`, with `R1`, `R4`, `R6`
and `P3` re-run beside it, plus `P4`, `P1`'s boot half, and the thirty seconds of
`R3` that closes `R5`. The other is `G7`'s: `W13` and `W14` first, then `W10`,
`W11`, `W12`, and the `W4`, `W8` and `W9` re-runs the new depth made owed.

**Nothing has confirmed the game boots at `48cc63e`, and that is the largest gap
this document holds.** `P1`'s boot half has never been run and `P3` is unrun,
while three commits have added two nodes, a setting, a new mapgen depth, two
textures and a licence file. Every claim about any of it rests on both gates,
which prove that the game assembles and run no line of its Lua. The cheapest
evidence available is `G7`'s sitting — one world, about an hour — and running it
settles the boot as a by-product of entering a world at all.

**The whole `W4`–`W9` group passed at `60259dd`, and it is the largest piece of
evidence this project has ever held.** All six are `B50`: the floor at `y = 0`
with air under it, the wall unbroken and full height with no gap at a mapchunk
seam, the drone's own error naming 1024, an existing world re-bounded, the clamp
firing on a fall and *not* on someone standing legitimately at the edge, and the
place the rescue puts you. **`B50` closed on this**, on both of its routes: `W5`
is route one, walking off the generated edge, which nobody in this project had
ever done; `W8` and `W9` are route two, a program carving a hole.

**Three things stopped being inferred with it, and `W6` carried the most.** `W6`
is the only check that can say the game's `minetest.conf` reached `core.settings`
and that the drone's bound and the wall are one number — the whole architecture of
`G6` decision 2, which until that run rested on reading
`mods/codeblock/lib/commands.lua:49`. `W7` is the only thing `override_meta =
true` ever bought. `W5` is the wall at full height with no seam, which no amount
of reading `mapgen_env.lua` could settle.

**`W8` is a full pass and the ambiguity it used to carry is gone.** Its earlier
passes were recorded against a near-miss half nobody had run — the clamp must
**not** fire on a player standing against the wall or on the exposed floor plane —
and by this document's convention an unrun half is `partial`. The 2026-09-07
rewrite put that half into the check's own instructions, so a pass against the
check as written is a pass on both halves.

**`W10`–`W14` gained a sha on 2026-09-08 and are still unrun.** They cover the
three changes `d6e4a12` committed: a translucent `cc_mapgen:barrier` at the
world's edge instead of solid bedrock (`W10`), the game's own textures for both
bound nodes instead of two borrowed from `default` (`W11`), and a world 128 nodes
deep instead of 8 (`W12`, `W13`, `W14`). **Both gates were green on that commit
and neither runs a line of this game's Lua**, so nothing about how any of it
looks, how deep it is, or where a rescue puts anybody is evidence yet. For a
stretch of 2026-09-07 these were five entries with no commit at all to be run
against, which is the most this document has ever carried.

**The game's behaviour has been checked in a world on 2026-09-01 over three
rounds, again on 2026-09-02, and three times on 2026-09-07.** Twenty of the
thirty entries have a live result, eighteen of them a pass.

**Three findings came out of those rounds** — `B47`, `B48` and `S8` — none of
them visible from reading the `cc_*` files, **which were 21 lines between them at
the time** and are 464 now across four. All three are fixed; `B48` is the one
whose fix has not been seen in a world, which is what `R8` is for.

**`B49` came the other way, and is worth noting for that.** It was found by
reading `mods/default` while scoping `A13`, not by playing — three rounds in a
world walked past dirt spreading grass and a roofed grass floor reverting,
because nobody had thought to wait five minutes and look again. Playing finds
what reading misses; this one went the other way, and `R7` put it back in front
of a world. `R7` is also the check that earned the most: the fix behind *the
world never changes on its own* rests on undocumented behaviour — replacing an
ABM's `action`, because Luanti cannot unregister one — and nothing but `R7` could
say whether it works.

**`R6` is the case for re-running a check against its own fix.** The first `S8`
fix stopped items going into the bookshelf and left the real hazard standing: the
same panel is a way into the player's own inventory, and a drone tool dragged out
of the hotbar there lands in a row the player can no longer open. Marking `R6`
pass on the strength of that fix would have shipped it. `R4` is re-run beside it
because the second fix denies *every* player inventory action, and `R4` is what
would catch that being too broad.

**`R2`'s drop half ran on 2026-09-02, for the first time in this project.** It
had been recorded as passing since the first playtest on the strength of the
inventory panel alone — nothing had ever been dug, because `diggable = false`
makes it impossible, and the check said only "with digging somehow permitted".
Commenting that line out for one run is what finally exercised
`handle_node_drops`, and it is the method the check now carries. **A check that
cannot be run reads exactly like one that passed.**

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` settles the world's flags and its size, and
`mapgen_env.lua` beside it writes the bounds into each chunk on the emerge
threads: nothing below `y = 0`, a bedrock plane at `y = 0`, and a bedrock wall at
the outermost generated column. `cc_security` holds the two that are about the
player rather than the map — the clamp (`W8`) and the place it puts them (`W9`).
`W4`–`W9` are all `B50`. **All six pass at `60259dd`**, which closes `B50` on both
of its routes; `W8` and `W9` were rewritten on 2026-09-07, when `60259dd`
reversed the rescue's destination, and the passes below are against the rewritten
checks, not the retired ones.

**Three facts about the world these checks are run in, because each one changes a
method below.** First, `mg_flags` carries `nobiomes`, so `mgflat` has no top or filler
node and **the surface is stone** — there is no dirt and no grass anywhere until
a program places some. Second, the surface stands at `mgflat_ground_level` and
the bedrock plane is at `y = 0` whatever that is, so the plane is always
underground: it is never seen in ordinary play, and reaching it means having a
program clear a shaft down to it. Third, the clamp in `cc_security` is committed, and since `60259dd`
it rescues a player **into their own column** rather than to spawn, so
**`/teleport`ing to a negative `y` no longer leaves you there** — within 250 ms
you are stood on the first room in the column you were over. That is `W8`'s
subject and `W4`'s obstacle.

**`mgflat_ground_level` is the number that moved, and every result below was
recorded before it did.** It was **8** at `60259dd`, which is the commit `W4`–`W9`
all pass at, so those runs went down eight nodes of stone. **`d6e4a12` sets it to
128**, and `W12` is the check that says so. The methods below are written to work
at either — they say "the surface" and "the plane" rather than a number — but
**anywhere a number is unavoidable, both are given**, and a pass recorded at
`60259dd` is a pass against a world eight nodes deep. **`W4`, `W8` and `W9` are
therefore owed re-runs at `d6e4a12`**: all three exercise `cc_security`'s rescue,
and the constant it derives its heights from is exactly what changed. Their
passes are not moved and not backdated — they are what was seen at `60259dd`.

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

**The method changed on 2026-09-07 and the old one no longer works.** It was
`/teleport` to `y = -5`; the clamp now puts you back at spawn within 250 ms, so
that only exercises `W8`. Go from above instead.

Have a program clear a shaft from the surface down to `y = 1` — the surface is at
`mgflat_ground_level` and everything between it and `y = 1` is stone — then climb
or teleport into it and stand on the bottom. **That is 8 nodes of stone at
`60259dd`, where the pass below was recorded, and 128 at `d6e4a12`**,
so the shaft the program has to clear is sixteen times longer than it was and a
loop written for the old depth will stop short.

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

`/teleport` toward `+x` past 1000, then walk into the edge. Look up along the
face, and walk some way along `z` with the wall beside you.

**Pass:** an unbroken bedrock face, from the floor up out of sight, standing at
the same `x` all along `z`, with no gap where one mapchunk meets the next.

**A near miss looks like this:** a wall that is there at eye level and absent
thirty nodes up. That is the wall being written only into the chunk that
contains the ground, and it is exactly the case a check done from standing height
would pass.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — an unbroken bedrock face
from the floor up out of sight, at the same `x` all along `z`, with no gap at a
mapchunk seam. **This is route one of `B50` and the check the finding was waiting
on**: walking off the generated edge is closed by something someone has walked to,
rather than by reading `mapgen_env.lua`.

### W6 · The drone's bound followed the number [B50]

Ask the drone to move past 1024 on any horizontal axis.

**Pass:** it refuses with *"The drone cannot leave the world (1024 nodes)"* —
naming **1024**, not 4096.

This is the only thing that proves the game's `minetest.conf` reached
`core.settings` and that the drone's bound and the wall are the same number.
CodeBlock reads `mapgen_limit` itself; nothing in this game writes it into the
mod, so a disagreement here would let a program build where a player cannot walk.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — the drone refuses and its
message names **1024**. So the game's `minetest.conf` reached `core.settings`, and
the drone's bound and the wall are the same number rather than two numbers that
happen to agree. **This was the last inferred part of `G6` decision 2**, which
until now rested on reading `mods/codeblock/lib/commands.lua:49`; nothing in this
repository writes the setting into the mod, and it did not need to.

### W7 · An existing world is re-bounded [B50]

Open a world created before this change — one whose `map_meta.txt` still carries
the old `mapgen_limit = 4096` — and walk or teleport out to 1024.

**Pass:** the edge is at 1024, not 4096.

`mapgen_limit` is stored per world, so without `override_meta = true` on
`cc_mapgen`'s `set_mapgen_setting` call an old world keeps its old edge for ever.
This check is the only thing that argument buys and the only route to seeing it
fail.

Result: pass — `60259dd` · engine 5.17.0 · 2026-09-07 — a world carrying the old
`mapgen_limit = 4096` in its `map_meta.txt` has its edge at 1024 when reopened.
That is the whole of what `override_meta = true` on `cc_mapgen`'s
`set_mapgen_setting` call buys, and it is the only route to seeing it fail.
Note what this does **not** cover, which is under *what ships broken*: terrain
already emerged beyond 1024 in such a world keeps no wall, because the wall is
written by the mapgen callback and nothing regenerates a visited chunk.

### W8 · A player who falls through a program-made hole is put back [B50]

Implemented in `mods/cc_security/init.lua`, not `cc_mapgen`: the wall and the
floor do not close this, because a program may `remove` a floor tile and
`diggable = false` binds the player, not a program.

The floor is under the whole depth of the stone, so this needs two steps, not
one. Have a program clear a shaft from the surface down to `y = 1` and then
`remove` one bedrock node at `y = 0` under it — `W4`'s shaft will do, and it is
eight nodes deep at `60259dd` and 128 at `d6e4a12`. Then walk into the
hole.

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
That is the defect exactly as it was reported on 2026-09-07, and it is what
making the floor whole under you prevents.

**2 · The blocked column** — the author's *"nearest free block above him"*, new on
2026-09-07 and the case nothing has ever covered. Have the drone remove a wall
column so there is a way out of the world, then walk out through the gap, over
ground the program has not touched.

**Pass:** you are put back **one node inside the wall, at the same `z`**, standing
on top of the stone surface — `y` about **`mgflat_ground_level` + 0.5**, so 8.5 at
`60259dd` and 128.5 at `d6e4a12`. Not embedded in the stone, and
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
`mgflat_ground_level` — **72 at `60259dd`, 192 at `d6e4a12`** — and
this is the **only surviving route into `repair_spawn()`**. Reuse case 2's way out
of the world: have the drone fill the column one node inside the wall, at the `z`
you will walk out at, with stone from `y = 1` up past that height, then walk out
through the removed wall column at that same `z`. **At 128 this case costs
sixteen times the pillar it used to**, and it is the one case here that a depth
change makes materially harder to set up.

**Pass:** you arrive at spawn, in open air, free to move — `y` about
`mgflat_ground_level` + 1, so 9 at `60259dd` and **129** at `d6e4a12`.
**Fail:** you arrive embedded in a node, or the rescue does nothing at all.
Building a solid pillar the full height of the scan and falling out of the world
at exactly its footprint is the case the bound trades away, and what it costs is the old
behaviour — spawn — rather than a softlock.

**Two false passes this check must be run against, because they are how the fix
looks fixed without being fixed:**

- **The `ignore` branch, and it is weaker than it was.** `minetest.get_node`
  reports `ignore` for an unloaded mapblock and that reads as an ordinary solid
  node, so a repair written on it would be skipped on exactly the tick that needs
  it — hence `get_node_or_nil` and the explicit test. But the column the rescue
  now works in is the one the player is standing in, so it is nearly always
  resident, and **the out-of-range variant no longer forces that branch.**
  `load_area` still matters, because the scan reaches the whole depth of the world
  plus 64 above a player who is below `y = 0` and the top of that column need not be in memory. Of the four
  cases only **case 4** still puts a possibly non-resident area under a write, at
  spawn, which is a few hundred nodes from where it is run.
- **Landing on the bedrock plane at `y = 0` rather than on the surface, which was
  the tell for a bad fix and is now the fix.** Exactly reversed by `60259dd`, so
  read it per case: in case 1 about **0.5** is the pass and landing up at the surface would mean
  the scan is not stopping at the lowest room in the column; in case 2 the
  **surface** is the pass and about 0.5 would mean the column was carved out rather
  than scanned up.

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

No finding id: this is not a defect. The wall was already correct — it stood,
full height, unbroken, and `W5` proves it. What changed is what it *looks* like,
because the author asked for a world edge that is visible and a solid opaque face
is not what they wanted to look at. Nothing but a running world can settle
whether the new one reads as an edge.

Walk or `/teleport` to the world edge on any axis and face the wall. Look at it
from a few nodes back, then from up against it. Then try to walk through it, and
try to place a node on its far side.

**Pass**, and all four parts are required:

- **A dark outline around every node face** — a regular grid across the whole
  wall, one cell per node, with sky visible through the middle of each cell.
- **No shadow band along the edge.** The ground and anything built near the wall
  is lit the same as ground in the middle of the world. That pair is
  `paramtype = "light"` and `sunlight_propagates` doing their job.
- **Still solid.** You are stopped at the column, and you cannot place a node
  through it onto its far side.
- **Still nothing you can take.** It does not crack under a punch, drops nothing,
  and is not in any inventory — the same properties bedrock has.

**Two near misses, and both look like a pass from the wrong angle.**

1. **Sky past the edge proves nothing on its own.** If the wall simply failed to
   generate you would also see sky, and see it far better. So the deciding part
   is being *stopped*: confirm you cannot walk out, at the same column the
   bedrock wall used to occupy. Seeing through it and being stopped by it have to
   be observed in the same place, in the same sitting.
2. **An outline only along the top of the wall and at the world's corners**, with
   clear glass between, is the framed drawtype having come back — the engine
   drawing the wall as one connected pane instead of a node each. That is the
   exact appearance this change exists to avoid, and from far enough back it can
   pass for a clean edge. The grid must be there *per node*, in the middle of a
   straight run of wall, not only where the wall ends or turns.

**The floor is not part of this check.** `cc_mapgen:bedrock` is still the plane at
`y = 0`, including the outermost column at that layer, and still under the whole
depth of the stone. `W4` is its check and this does not replace it. **What the
floor now *looks* like is `W11`**, which is new beside this one: the same commit
gives both bound nodes the game's own textures, so
`cc_mapgen:bedrock` is no longer unchanged the way this paragraph used to say.

**The texture the outline comes from changed on 2026-09-07, after this check was
written, and the pass is unaffected.** It was `default_obsidian_glass.png`,
borrowed from the vendored mod; it is now `cc_mapgen_barrier.png`, the mod's own,
keeping the same 1px-border, transparent-centre geometry. What is checked here is
the *geometry* — an outline per node face with sky through the middle — and that
is what both textures give. `W11` is where the new artwork itself is looked at.

Result: unchecked — committed at `d6e4a12`, both gates green there, and neither
gate runs a line of this game's Lua. It has a sha to be run against and nobody
has looked at it.

### W11 · The floor and the wall are the game's own artwork, and the floor does not tile

No finding id: nothing is defective. On 2026-09-07 the author asked for bedrock
*"more black like in minecraft"*, and `cc_mapgen` now ships its own two 16×16
textures instead of borrowing `default_obsidian.png` and
`default_obsidian_glass.png`. **Nobody has rendered either file.** Both were
decoded back after they were written, which says what bytes are in them and
nothing at all about what a wall or a floor of them looks like from three nodes
away.

Have a program clear a shaft to the bedrock plane at `y = 0` and then clear a
**wide** expanse of it — twenty nodes on a side at least, and more is better —
and stand on it. Look straight down, then look across it to its far edge at a
shallow angle. Then go to the world's edge and look at the wall beside the floor
where the two meet.

**Pass**, and the second part is the one worth the trip:

- **The floor reads as black mottled rock**, distinctly darker and less blue than
  the obsidian it replaced. Anyone who remembers the old floor should be able to
  say which is which.
- **No tiling grid across the expanse**, at any angle. No repeating shape, no
  seam every sixteenth node, no line where one texture meets the next. **This is
  what the wrapping blur exists for and it is the thing most likely to look
  wrong** — a non-wrapping blur darkens or lightens the four edges of the tile
  and a large floor turns into visible graph paper.
- **The floor and the wall read as one material**, dark and of a piece, rather
  than as two nodes that happen to be adjacent.

**A near miss looks like this:** a floor that is fine when you look straight down
and grids up when you look across it. Tiling artefacts are far more visible at a
shallow angle than from directly above, so looking down at your feet and calling
it clean is the way to miss this. Look across the expanse, at eye level.

**And one thing that is *not* this check.** The barrier's outline grid is `W10`,
and it is meant to be there — a regular grid on the *wall* is a pass, a regular
grid on the *floor* is a fail. The two are next to each other and easy to
conflate.

Result: unchecked — committed at `d6e4a12`, both gates green there, and neither
gate renders a pixel. It has a sha to be run against and nobody has looked at it.

### W12 · A new world puts you 128 nodes above the floor

No finding id. On 2026-09-07 the author asked for the floor at 128, and
`mgflat_ground_level` goes from the engine's 8 to 128 — declared in
`settingtypes.txt`, defaulted in `minetest.conf`, and forced onto the world by
`cc_mapgen`. The bedrock plane stays at `y = 0`, so the number is how much stone
there is between the surface and the bottom of the world.

Create a **new** world with default settings, enter it, and read your own
position — `/status` or the debug display, `F5`.

**Pass:** you are standing on stone at `y` about **128.5**, and the world under
you is solid stone all the way down to the bedrock plane at `y = 0`. Have a
program clear a shaft and confirm the bottom of it is bedrock at `y = 0`, exactly
as `W4` says — the floor did not move, the surface did.

**A near miss looks like this:** you are at `y` about **8.5**. That is the
engine's own default, and it means the game's `minetest.conf` did not reach
`core.settings` or `cc_mapgen`'s forced `set_mapgen_setting` did not take. It is
the same failure `W6` catches for `mapgen_limit`, by the same mechanism, and it
reads as a perfectly ordinary world unless you look at the number.

**Also check the setting is offered.** Advanced settings → Content: Games →
Codecube shows **Surface height** at 128 beside **World half-extent** at 1024.
That is a server owner's route to it and the reason it is a setting rather than a
constant.

Result: unchecked — committed at `d6e4a12`, both gates green there.

### W13 · An existing world's surface moves to 128 when you open it

No finding id, and **`code-expert` calls this the thing most likely to be wrong
and the whole point of the change.** The engine writes every `mgflat_*` parameter
into a world's `map_meta.txt` when the world is created, so a world made at
ground level 8 keeps 8 for ever unless something overrides it. `cc_mapgen` passes
`override_meta = true` on the `set_mapgen_setting` call for exactly that reason.

**`W7` is the precedent and this is the same check for a second key.** `W7`
proved the mechanism for `mapgen_limit` — an old world carrying 4096 in its
`map_meta.txt` is re-bounded to 1024 on opening — and it passed at `60259dd`.
That the same argument works for `mgflat_ground_level` was verified by reading:
`MapgenFlatParams::writeParams` at 5.9.0 writes the key, a real `map_meta.txt` on
this machine carries it, and `MapSettingsManager::setMapSetting`'s `override_meta`
branch is generic rather than restricted to `MapgenParams` fields. **Reading is
not running**, and `W7` is the only reason to expect this to pass at all.

Open a world created before this change — one whose `map_meta.txt` still says
`mgflat_ground_level = 8` — and walk out into ground that has **never been
generated**, well past anywhere you visited before. Watch it emerge ahead of you.

**Pass:** the newly generated ground comes in at `y = 128`, not 8, and there is a
step where the old terrain meets the new. Confirm `mgflat_ground_level = 128` in
that world's `map_meta.txt` after closing it.

**A near miss looks like this:** the new ground arrives at 8 like the old ground,
and everything looks consistent and correct. A seamless world is the *failure*
here, and it is the only check in this document where the tidier-looking outcome
is the wrong one.

**What this deliberately does not promise**, and it is under *what ships broken*:
ground already generated keeps the height it has. The setting reaches new chunks
only, exactly as the wall does.

Result: unchecked — committed at `d6e4a12`, both gates green there.

### W14 · The rescue still knows where the surface is [B50]

No new finding id — this is `B50`'s rescue, re-checked under a depth it was not
written for. **It is also the check that would have caught a real defect in this
change.** `cc_security` derived its spawn fallback and its scan bound from
`(ground or 8)`; with the game's default now 128 that constant had become the
wrong fallback and would have put a rescued player at `y = 9`, inside a hundred
and twenty nodes of solid stone. It is now a single `or 128` at the definition.
The defect was never committed and carries no id; this check is what stands
behind the fix.

**Every number here is the point.** Run the three cases and read your `y` each
time. An **8** or a **9** anywhere in the results means a stale constant survives
somewhere in the rescue path.

1. **Through the floor.** `W8`'s setup at the new depth: clear a shaft to `y = 1`,
   `remove` one bedrock node under it, walk in.
   **Pass:** `y` about **0.5**, at the bottom of your own shaft, on a fresh
   bedrock tile.

2. **Clamped in from outside the wall**, over ground a program has not touched —
   `W9` case 2's setup.
   **Pass:** `y` about **128.5**, standing on top of the stone surface one node
   inside the wall. **Fail: about 8.5**, which would mean the scan stopped at the
   old surface height and left you buried in a hundred and twenty nodes of stone.

3. **The spawn fallback**, `W9` case 4's setup at the new depth: fill your exit
   column solid past the scan bound, then walk out.
   **Pass:** you arrive at spawn in open air, free to move, at `y` about **129**.
   **Fail: about 9**, and this is the exact shape of the defect that was caught —
   spawn derived from the engine's default instead of the game's.

**A near miss looks like this:** case 1 passes and you stop there. It is the
cheapest of the three and the only one whose pass value did not move with the
depth, so it says nothing at all about the constant this check exists for. **Cases
2 and 3 are the check**; case 1 is here so the three read as one setup.

**The cost this check runs into, recorded so it is not mistaken for a fault.**
The rescue's `load_area` column grew from 5 mapblocks (~80 kB) to 13 (~210 kB),
because it spans `y = 0` to 193 now, and the scan reads up to ~128 more nodes
before it finds the surface. Bounded, and at most four times a second per
out-of-box player. If a rescue feels slower than it did, that is why and it is
deliberate.

Result: unchecked — committed at `d6e4a12`, both gates green there, and neither
gate runs a line of this game's Lua.

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

**The `groups` line is why this method changed on 2026-09-07.** `B48` strips six
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
`CONTENTDB.md`. Four things **are** present and their absence is a fail:
`menu/*.png`, because the main menu reads it; `menu/license.txt` beside them and
`mods/cc_mapgen/license.txt` with its two textures, because a licence notice has
to travel with what it licenses and nothing else in the archive states the media
licence (`C22`); and `THIRD-PARTY-LICENSES.md`, for the same reason. A missing
`menu/license.txt` most likely means the file was never committed. Note the total
size; the last measurement was 1.93 MB zipped, by `git archive --format=zip`.

**This is the half of `C15` that reading cannot settle**, and the reason it stays
worth running: `.gitattributes` decides what reaches a player and **nothing in
either CI checks it**, so a file added to the repository ships unless a rule
excludes it, and nothing fails locally when one does. Run this whenever a tracked
file is added, not only at a release.

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

Revised 2026-09-08 at `6a0258a` plus the uncommitted media licence change: `P2`
now names the four things that must be **present** in the archive, not only what
must be absent, because the licence decision added `menu/license.txt` and a
licence notice that does not ship states nothing (`C22`). No result line was
changed and no check was added; `P2`'s pass at `8b27f2f` predates the file.

Written 2026-08-30 at `54a2b7e`. Revised 2026-09-01 across three rounds: `P2` and
half of `P1` at `8b27f2f`; the `W`, `L` and `R` groups at `7f649d8`; then `L1`
and `R6` at `b9bf82b` against the fixes those produced, and `R6` and `R4` again
at `c042364`. All played by the author in a world on Luanti 5.17.0 — recovered
from the engine's own debug log afterwards, not noted at the time.

Revised 2026-09-07 a second time, at `578b364` plus the uncommitted `G6` work:
`W4`–`W8` added for `B50` — the floor, the wall, the drone's bound, an existing
world re-bounded, and the clamp that puts a player back at spawn after they fall
through a hole a program made. All five `unchecked`; nothing of `G6` has been run
in a world. No existing result line was changed.

Revised 2026-09-07 at `578b364` plus an uncommitted `cc_security` change: `R8`
added for `B48`, `R1`, `R4`, `R6` and `P3` marked for re-running beside it, and
`R2`'s drop method corrected to comment out `groups = groups` as well as
`diggable = false` — with the groups stripped, the first line on its own may
leave the hand nothing it can break, and the check would do nothing rather than
fail. No result line was changed.

Revised again on 2026-09-07, after the clamp landed in the working tree and the
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

Revised a fourth time on 2026-09-07, and this one records evidence. The author
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
code it replaces. `W8` had also been re-run at `f5f2385` on 2026-09-07 and
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

Revised 2026-09-07 at `60259dd`, and this is the largest single addition of
evidence the document has had: **the whole `W` group passed** — `W4`, `W5`, `W6`,
`W7`, `W8` and `W9`, six for six, all `B50`. Route one of that finding, the
generated edge, had never been walked to and rests entirely on `W5`; route two,
the hole a program carves, had lost its evidence earlier the same day when `60259dd`
reversed the rescue's destination and `W8` and `W9` were rewritten around it. Both
routes are now observed and **`B50` is closed**. `W4` is re-run by its own method
and no longer names an uncommitted tree, so **no result in this project is left
without a sha**. `W6` and `W7` are first runs of checks that had never been run at
all: the drone's error naming 1024, which is the only proof `minetest.conf`
reached `core.settings`, and an old world re-bounded, which is the only thing
`override_meta = true` buys. **`W8` is recorded as a full pass rather than an
upgraded partial**: what made it ambiguous before was a near-miss half nobody had
run, and the 2026-09-07 rewrite put that half into the check's own instructions,
so a pass against the check as written covers it. `W9` passed all four cases,
including the two the rewrite added. **No gate was re-run and none was owed** —
nothing in the code changed, and the last green run of both was on `60259dd`.

Revised 2026-09-07 at `93b8ea1` plus an uncommitted working tree, and this
revision covers **two** passes of the same day's work, because the first was
recorded in the checks themselves and never in this footer. **`W10` was added
first**, for the translucent barrier at the world's edge, and it was the first
entry in this document with no sha at all to be run against. **`W11`–`W14` follow
here**, for the two changes that arrived on top of it: the game's own textures for
both bound nodes, and a world 128 nodes deep instead of 8. All five are
`unchecked` and all five stay that way — the three changes are written, both gates
are green on them, **neither gate runs a line of this game's Lua**, and none of
the three is committed. Five checks with no commit at once is the most this
document has ever carried.

`W11` is the artwork and the tiling grid, which is the thing a wrapping blur
exists to prevent and the thing most likely to look wrong. `W12` is a new world
at `y = 128`. **`W13` is an existing world's surface moving, and it is the one to
run first** — `code-expert` calls it the point of the change, `W7` is its
precedent for a different key, and its near miss is the seamless-looking outcome
rather than the broken one, which no other check in this document has. `W14` is
the rescue under the new depth, and it exists because the same change introduced
a real defect and caught it: `cc_security` derived its spawn fallback and scan
bound from `(ground or 8)`, which at a default of 128 would have put a rescued
player at `y = 9` inside solid stone. It was never committed and carries no
finding id; `W14`'s cases 2 and 3 are what would have caught it in a world, and
its case 1 deliberately would not.

**No result line was moved, and one is now on notice.** `W4`, `W8` and `W9` pass
at `60259dd`, where `mgflat_ground_level` was 8, and all three read heights the
rescue derives from that number. Those passes are what was seen at `60259dd` and
are left alone; when the depth change is committed all three are owed re-runs,
under this document's own rule that a result cannot survive a change to the code
it exercised. The methods of the `W` group were rewritten in the meantime to
carry **both** depths wherever a number was unavoidable — 8 at `60259dd`, 128 in
the working tree — rather than being written for a world nobody has run them in.
`W10`'s note about `cc_mapgen:bedrock` being "unchanged" was corrected for the
same reason: it is not, it has a new texture, and `W11` is where that is looked
at.

Revised 2026-09-08 at `d6e4a12`, on `G7` being committed and on this document
gaining the two things it never had: a statement of **how a check is written**,
and **counts**.

- **`W10`–`W14` have a sha and are still `unchecked`.** `d6e4a12` committed all
  three `G7` changes, so the five newest entries stop being checks with nothing
  to be run against — which for a stretch of 2026-09-07 was five at once, the
  most this document has ever carried. **No result moved**, and none may: only a
  person running one in a world can do that.
- **`W4`, `W8` and `W9` go on the owed-re-run list properly**, in the *what needs
  action* table rather than only in prose. Their passes at `60259dd` stand; the
  depth they were run against does not.
- **`## How a check is written`** is new. Every entry here already followed that
  shape and nothing said so, and the nearest statement of it lived in the
  `run-checks` skill — the wrong place, since someone opening this file to add a
  check does not read a skill. The two rules under it, *hand the runner an actual
  program or command* and *a recipe names the shell it is for*, were each bought
  with a wasted session.
- **`## Where it stands` is now two tables and a third of the prose.** The counts
  existed nowhere before; the *what needs action* table existed nowhere at all,
  and `TODO.md` was carrying the list instead, which is exactly the duplication
  that goes stale. `TODO.md` now points here. **No fact was dropped to do it** —
  `W3`'s method having gone stale, `P2` being owed harder than it was, and the
  argument for each re-run all moved into the table or the prose under it.
- **Two recording rules were missing and are written down**: name both commits
  when the checkout was at a record-only commit, and **results are listed newest
  first within an entry**. That second one is this document's actual practice —
  `R4` and `R6` are the only entries with more than one result and both read
  newest first — and it is the opposite of the sibling `codeblock` project's
  convention. Written to match what is here rather than what is there.
- **`R5` is back in group order.** The file ran `R1 R2 R3 R4 R6 R7 R5 R8`; it now
  runs `R1`–`R8`. Nothing in the entry changed.
