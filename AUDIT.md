# Audit — Codecube (the game)

Findings only: what was wrong, what it cost, how it was fixed, and the reasoning
a future change would otherwise re-break. **No roadmap and no milestones here** —
the order of work and the `G1`–`G7` lettering live in `ROADMAP.md`. The manual
checks are in `PLAYTEST.md`. What shipped, for a player, is in `CHANGELOG.md`.

**This is not the main audit.** `codeblock` is the main project and keeps its
own, at `mods/codeblock/AUDIT.md` in this checkout — read that one first. Until
2026-08-26 there was a single audit covering both projects; it was split so each
document follows its project rather than the working tree. The *inherited*
document, with the full history and the `Phase N` numbering that commit messages
quote, is the mod's; this one holds the game-side findings only.

Ids are **never renumbered**, because commit messages cite them: `B` bugs, `S`
sandbox and security, `C` compliance and packaging, `A` architecture and
performance. They were allocated once across this audit and the mod's, so a
number never means two things and **a gap here is a finding that lives in the
mod's audit**, not one dropped. Every id below kept the number it had in the
shared audit; `C15` is the first allocated after the split, then `C20`, then
`B50` and `C21` on 2026-09-07.
The `S` series was all the mod's until `S8` was filed, fixed and confirmed here
on 2026-09-01; the `F` feature series is the mod's own.

States: **resolved**, **open**, **won't fix** (the defect is real, the decision
is not to fix it), **withdrawn** (no longer applies — none is). Severities:
critical, high, medium, low.

Compression rule: a closed finding whose reasoning is spent is one line. A closed
finding whose reasoning is load-bearing keeps a **Keep** paragraph, because
someone could otherwise undo it by accident. Nothing has ever been renumbered and
nothing dropped.

## Where it stands

20 findings, this game's own. **15 resolved, 5 open, none won't-fix.** No open
finding is critical or high. Three are medium — `A7`, `A8` and `A13` — and two
are low, `C21` and `C22`.

**`C22` is new on 2026-09-07 and is the only finding here that has been true since
the project began.** The game's three menu images ship to every player and no file
anywhere states a licence for them, while every bundled mod has a `license.txt`
and a row in `THIRD-PARTY-LICENSES.md`. It was turned up sideways, by `G7` giving
`cc_mapgen` its own textures and a *License of media* section with them: the game
now names a licence for two 16×16 files and none for 655 kB of artwork seen
before anyone enters a world. Raised by `code-expert` as suspected and **verified
here by reading all four files**.

**`B50` is resolved, and it is the one finding here closed by evidence rather than
by a commit.** Falling out of the world had **two routes**: the generated edge,
and a hole a program carves in the floor. Both are shut — a bedrock plane at
`y = 0` with air beneath, a full-height bedrock wall at the outermost generated
column, and a `cc_security` globalstep that puts a player found outside the box
back into their own column — committed at `f5f2385` with the rescue's destination
reversed at `60259dd`. **What closed it is `PLAYTEST.md` `W4`–`W9`, all six
passing at `60259dd`.** Route one had never been walked to at all and rested
entirely on `W5`; route two had passed at `f5f2385` and lost that evidence when
`60259dd` replaced the destination it described. Both are now observed. Two
defects found while building this were in uncommitted code and carry **no id** —
the `y = 1` fallback inside solid stone, and the rescue looping at the spawn
column — and their record is `ROADMAP.md` `G6`, as is the design reversal at
`60259dd`, which was the author's instruction after playing and not a defect at
all.

**A third defect was found in uncommitted code on 2026-09-07 and carries no id
either, which makes it the third application of the same rule.** `G7` raises
`mgflat_ground_level` to 128, and `cc_security` derived both its spawn fallback
and its scan bound from `(ground or 8)` — so on the fallback path a rescued
player would have been put at `y = 9`, inside a hundred and twenty nodes of solid
stone. It is the same shape as `G6`'s `y = 1` fallback and was caught the same
way, by reading the change against the number it had just moved. Collapsed to a
single `or 128` at the definition. **No id, because what gets one is a defect in
committed code**; the record of a change that was wrong before it landed is
`ROADMAP.md` `G7`, and `PLAYTEST.md` `W14` cases 2 and 3 are what would have
caught it in a world. Filed nowhere else, so that a future reader who finds `W14`
asking pointedly about the number 9 knows why.

`C21` is the other finding new on 2026-09-07, from shaping the same feature: a
version ceiling in a bundled submodule, and the only one here the game cannot fix
in its own tree.
`A13` is **deferred rather than pending** — the trim it describes is
waiting on a decision in `codeblock`, not on work here. It no longer carries
`B19` and `B24`: both were closed directly on 2026-09-02, which was the point of
looking at them, since "resolved for free by `A13`" had kept two boot-log defects
invisible behind a deferred item. `A7` is written upstream in `codeblock` and
closes here at adoption; `A8`'s drop chain is confirmed and its table walk is
what keeps it open.

**`B49` is resolved and confirmed.** Its fix rests on undocumented behaviour —
replacing an ABM's `action`, because Luanti cannot unregister one — so `R7` was
the only thing that could say whether it works, and it passed on 2026-09-02.
`S8` and `B47` were fixed and confirmed the day before, by `R6` and `L1`.

**`B48` is fixed and unverified, as of 2026-09-07.** The stripped digging groups
are committed on their own at `ec02760` — split out of `G6` so the `G4` fix
stands separately, which also gives `R8` a sha to be run against — both gates are
green, and neither gate runs a line of this game's Lua, so it stays here in full
until `R8` is run in a world. What did
change is that the question the filing left open is now answered from the
documented API: `core.get_dig_params` never sees `diggable`, so the fix had to
come from the groups and no other reading of the defect survives.

**Three of the twenty arrived on 2026-09-01, from the first hours anyone has
spent playing this game against `PLAYTEST.md`** — `B47`, `B48` and `S8`. None was
visible from reading the three `cc_*` files, **which between them were 21 lines
at the time** and are **464** now across four files, since `G6`, the rescue
rewrite, the barrier node and the world's new depth; two
of the three are in how those lines meet a vendored node or the client. That is
the argument for the `W`, `L` and `R` groups, and it is now evidence rather than
an assertion.

**Re-running a check against its own fix is the other thing that day established.**
`L1` re-run cleared a blocker that had been predicted for `B47` and did not
exist. `R6` re-run found that the first `S8` fix had closed the wrong half, and
would have been marked pass on the strength of the fix alone; a second re-run,
with `R4` beside it, is what closed it properly. Neither outcome was available
from the code. **A fix is not evidence** — the check is, and it costs minutes.

| Category | Count | Open |
|---|---|---|
| B bugs | 7 | — all 7 resolved. `B50` closed on 2026-09-07 with `W4`–`W9` passing at `60259dd`, both routes verified. Three of the seven are resolved but **unverified in a world**: `B19` and `B24` wait on `P3`, `B48` on `R8` |
| S sandbox and security | 1 | — `S8` resolved, `R6` passes |
| C compliance and packaging | 8 | `C21` (a submodule's version ceiling, not ours to edit), `C22` (the menu artwork ships with no licence stated) |
| A architecture and performance | 4 | `A7` (upstream), `A8` (drop chain confirmed, table walk open), `A13` (deferred) |

The game is current with `codeblock` `2647228`, adopted at `33bdae8`; both are at
`origin` and both CI workflows were green on those exact shas. `C15` was open as
a working-tree change at the last revision and has since landed in `8d18e8b`.
`C20` is new — filed and fixed in the same change, committed in `9ad884c`, and
the only finding here to arrive from reading a published rule rather than from a
defect.

## Findings in full

The open findings, plus the closed ones whose reasoning is load-bearing enough to
be undone by accident. A finding stops being pending once a `PLAYTEST.md` check
has passed on it — `S8` and `B47` on 2026-09-01, `B49` on 2026-09-02, `B50` on
2026-09-07 — and each stays here in full for that reason. `C21` is short and lives
in the `C` section.

### B50 · medium · resolved, `W4`–`W9` all pass — a player could fall out of the world, by two routes

`minetest.conf` · `mods/cc_mapgen/init.lua` · `mods/cc_mapgen/mapgen_env.lua` ·
`mods/cc_security/init.lua`

**There are two routes, and the second was not visible when this was filed.**
Route one is walking off the generated edge, described below, and the bedrock
wall closes it. Route two is falling through a hole a program made in the floor,
and **the wall does not touch it**: the drone's bound is `mapgen_limit`, so the
drone reaches every node of the floor, and `cc_mapgen:bedrock` is an ordinary
node to a program — `remove` deletes a floor tile or a wall column. A player who
walks into that hole drops into unlit air below `y = 0` and then straight out of
the bottom of the generated world, with the same no damage, no `fly`, no way
back. `diggable = false` does not help, because it binds the player and not a
program. Found by `code-expert` on 2026-09-07 while building the wall.

#### Route one — the generated edge

`minetest.conf` set `mapgen_limit = 4096`, so generation stopped at roughly ±4080.
**Nothing marks that edge and nothing stops a player reaching it.** Past it there
is no node to stand on, `default_privs` grants no `fly`, and `enable_damage =
false` — so a player who walks off falls into ungenerated space indefinitely,
unhurt, with no ground to land on and no privilege to fly back. The floor is the
same defect downwards: `mgflat` fills stone to the bottom of the generated range,
so nothing is *visibly* a limit in either direction.

**Filed from reading, and never observed in the broken state.** It was inferred
from `minetest.conf`, `game.conf` and the mapgen the game selects; nobody walked
to ±4080 and stepped off, because at roughly seven minutes' walk the edge may
never have been met in play. What was observed instead is the *fixed* state, by
`W5` on 2026-09-07: the wall is there, full height, at 1024. That is the weaker of
the two possible evidence shapes and it is the one available — a finding closed by
seeing the fix hold rather than by first reproducing the defect.

**Closed by `ROADMAP.md` `G6`, and the fix is a shape rather than a patch.** The
agreed answer is a bounded slab — a bedrock plane at `y = 0` with nothing
generated beneath it, and a full-height bedrock wall at the horizontal edge — so
that both limits are things a player can see before reaching them. For route two
the author ruled, on 2026-09-07, that **`cc_security` clamps the player**: a
connected player found outside the world box is put back at the spawn point — a
destination reversed on 2026-09-07, see below. It
is the only answer that holds regardless of what a program does to the floor, and
`cc_security` is already the mod whose job is what a player may do. The six
decisions behind the shape, and what was rejected — a `y`-only clamp that puts
the player back into the hole, recording the fall as a known limit, and asking
CodeBlock to refuse writes to `cc_mapgen:bedrock` — are recorded in `ROADMAP.md`
under `G6` and under *deliberately not doing*; they are a feature's grounds, not
a finding's, which is why they are there and not here.

**Fixed at `f5f2385` and `60259dd`; closed on 2026-09-07 by `W4`–`W9`.** The
wall, the floor, the 1024 default, the `settingtypes.txt` entry, the raised engine
floor **and the clamp for route two** are `f5f2385` on branch `g6-world-limits`,
and where the clamp puts a rescued player was reversed at `60259dd`. Both gates
were re-run green after each, and **neither runs a line of the game's Lua** — so
what closes this finding is not either commit but `PLAYTEST.md` `W4`–`W9`, which
all six pass at `60259dd`. They split by route: `W4`, `W8` and `W9` are route
two — the floor, the fall through a program-made hole, and where the rescue puts
you — while route one, the generated edge, is `W5` and `W6`'s proof that the
drone's bound and the wall are the same number. **`W7` is neither route**: it is
whether an old world is re-bounded at all.

**Both routes are observed, and neither was when this document last said so.**
Route one had never been walked to at any point in this project — the edge is
minutes away on foot and the finding was filed from reading `minetest.conf`,
`game.conf` and the mapgen the game selects — and `W5` closed it by walking into
an unbroken bedrock face, full height, with no gap at a mapchunk seam. Route two
was observed on 2026-09-07 against an uncommitted tree and again at `f5f2385`,
and **that evidence was retired on 2026-09-07** when `60259dd` replaced the
rescue's destination: every one of those observations watched a rescue to the
spawn point. `W8` and `W9` were rewritten around the new destination and both pass
at `60259dd`, `W9` across all four of its cases including the two the rewrite
added. `W6` additionally settles what was the last inferred part of `G6`
decision 2 — the drone's error names 1024, so this game's `minetest.conf` reaches
`core.settings` and the two bounds are one number rather than two that agree.

**The reversal is not a defect and has no id.** Nothing was wrong with the code
`60259dd` replaced — both its checks passed — and the author asked for different
behaviour after playing it. The record of a design decision is `ROADMAP.md`,
under `G6` decision 7, and the audit's only interest in it is that it invalidated
this finding's route-two evidence.

**Keep — refusing to backdate `W4` and `W8` is what this finding's evidence cost,
and it was worth paying.** Both once named an uncommitted tree rather than a sha,
and two commits landed on the rescue path afterwards — `repair_spawn()` at
`f5f2385`, the reversal at `60259dd` — so writing either sha on would have carried
a result across a change to the code it exercised, which is what `R6` cost this
project once already. They were re-run instead, by their own methods, and both
pass at `60259dd`. **No result in this project now names a tree instead of a
commit.** `W8`'s near-miss half — the clamp *not* firing on a player standing
legitimately at the edge — was the part that had never been run at all, and the
2026-09-07 rewrite made it part of the check's own instructions rather than a note
beside them, which is why the pass covers it.

**What the fix nearly got wrong, and why the spawn height is derived.** The
clamp's first fallback spawn was `{x = 0, y = 1, z = 0}`, with a comment calling
it *"one node above the bedrock plane at y = 0"*. `mgflat_ground_level` defaults
to **8** and nothing here overrides it, so the plane is eight nodes underground
and `y = 1` is inside solid stone; `static_spawnpoint` is unset in this game, so
that fallback was the ordinary path and not an edge case. Damage is off, so a
rescued player would have been left embedded rather than killed — a worse place
than the fall. It is now
`tonumber(core.get_mapgen_setting("mgflat_ground_level")) + 1`. `core.get_spawn_level`
answers the same question and cannot be used: it needs the emerge manager, which
initialises after every mod has loaded, so at mod load time it returns 1 — the
same wrong number — and writes to `errorstream` on every boot. **This carries no
finding id**: `git diff HEAD` shows the whole clamp as an insertion, so the wrong
fallback was the change being wrong and was caught before it shipped. Its record
is the `G6` entry in `ROADMAP.md`, and it is repeated here only because the next
reader of that line needs to know why the number is derived rather than written
down.

**And the second thing it nearly got wrong, found by playing on 2026-09-07.**
After the rescue above, the author stood at spawn and cut the floor out from
under themselves — so the hole was now exactly where the rescue lands. They were
put back at `(0, 9, 0)` in mid-air, fell about 1.35 s back through it, crossed
`y = 0`, and were moved back: **airborne throughout, so never able to walk out.**
It is the same shape as the `y = 1` fallback — *the rescue destination was never
checked for being a place you can stand* — which is why the two sit together.
`repair_spawn()` in `mods/cc_security/init.lua` now runs immediately before
`player:set_pos(spawn)`. **No finding id either**: the clamp had never been
committed when this was found. Its record is the `G6` entry, `W9` is its
evidence, and **`W9` passes at `60259dd`** across all four cases. Since the
reversal `repair_spawn()` is the fallback path only, reached when a column has no
room in 64 nodes, so `W9` case 4 is the one that exercises it — and it is also the
only case left that puts a write into possibly non-resident map, which is what the
`get_node_or_nil` / `ignore` branch and the `load_area` are for. An earlier full
pass at `f5f2385` covered the same function on the ordinary path and was retired
with the destination it described.

**This Keep was reversed on 2026-09-07 and is kept as the reasoning that was
outweighed.** It read: *the repair goes one node under the destination, not on
the plane at `y = 0`, because filling the plane would leave the player at the
bottom of the shaft the program dug, unable to climb out and unable to dig — the
same softlock by another route.* `60259dd` restores the plane under the player's
own column and accepts that outcome, on the ground that **from a shaft you can
point the drone at its wall and program your way out, and from an endless fall
you cannot**. The reasoning above was not wrong; it was outweighed by keeping the
player where they were building. The grounds are `ROADMAP.md` `G6` decision 7,
since they are a feature's and not a finding's. `repair_spawn()` still repairs
one node under the destination and is now the fallback path only.

**Keep — `get_node_or_nil` and `load_area`, and neither is tidiable away.**
`minetest.get_node` reports `ignore` for an unloaded mapblock, which reads as an
ordinary solid node, so a repair written on it would be skipped on exactly the
tick that needs it — the loop would still be there and the code would still look
right. Hence `get_node_or_nil` plus an explicit `ignore` test. And the area is
loaded as well as read, because **`set_node` into a non-resident mapblock
silently does nothing**: checking without loading gives a repair that reads
correctly and writes nothing. `emerge_area` was rejected as asynchronous — the
player would arrive before the ground.

**Keep — the `walkable` tests are against `false`, not against truthiness.**
`walkable` defaults to true and node definitions leave it out, so
`registered_nodes["default:stone"].walkable` is `nil` and not `true`. A
truthiness test would read every ordinary solid node as walk-through, and the
mirror case — a player sealed inside stone at spawn, with damage off and no way
out — would be left unfixed while the code looked like it handled it.

**Keep — `W8`'s near miss, traced in the code first and observed on 2026-09-07.**
The margins below are why the clamp does not fire on a player standing
legitimately at the world's edge, and `W8` confirms in a world that it does not.
A player's position is their feet and the bedrock plane's nodes span
`y = -0.5` to `0.5`, so a player standing on an exposed floor tile reads `0.5` —
half a node of margin under the `p.y < 0` test, which is why the test is `< 0`
and carries a comment saying that `<= 0` is the tidy-up that would break it.
Standing against the wall is inside the box for the same reason: the wall
occupies the outermost generated column, so the furthest column a player can
stand in is one short of `world_max`. **The join-timing failure mode was
considered and withdrawn**: `ServerEnvironment::loadPlayer` sets the base
position before `addPlayer`, and `l_get_connected_players` skips a `RemotePlayer`
whose `PlayerSAO` is null, so the first globalstep that can see a joining player
sees a settled position. A player who logged out mid-fall *is* teleported within
250 ms of rejoining, and that is the clamp working. It was never written into
`W8` and nothing was removed from it.

**Keep — the engine floor is 5.9 and it was recorded as 5.7 first.** The fix
needs `core.register_mapgen_script`, which is absent from the shipped `lua_api`
at 5.7.0 and 5.8.0 and present at 5.9.0. Below 5.9 the call is `nil`, `cc_mapgen`
fails to load and the game does not start — which is why `game.conf` requires
5.9 unguarded rather than shipping an unbounded world to older engines. The full
correction is under `ROADMAP.md` `G6` decision 4.

### A13 · medium · open, deferred — `default` is 9,744 lines to supply 106 node definitions, and the rest still runs

`mods/default`

The palette references **122** nodes: 106 from `default`, 15 from `wool`, plus
`air`. Nothing else in `default` is reachable — digging is disabled for every
node, the inventory formspec is blanked, `handle_node_drops` is stubbed, mapgen
is flat with no decorations, ores or biomes, and creative is on. So
`mapgen.lua` (2,492 lines), `trees`, `crafting`, `furnace`, `chests`, `tools`,
`craftitems`, `item_entity` and `torch` register and do nothing — roughly 6,800
lines. It also installs 3 LBMs and 101 craft recipes.

**Corrected 2026-09-02: 106 and 122, not the 108 and 124 first recorded.** Counted
this time rather than estimated, by extracting every `default:`/`wool:` string
from `codeblock/lib/config.lua` at the adopted commit and sorting it unique. The
shape of the finding is unchanged.

**All 106 are in `nodes.lua`**, which needs only `functions.lua` for its sound
helpers and `init.lua` for two more. Twelve of the 106 have no literal
`register_node` call because they are registered in loops — the grass, dry grass,
fern and marram grass series. So the removable set is whole files, and no
palette node is entangled with one.

**The ABMs are not part of this finding any more.** They were cited here as a
background CPU cost; `B49` establishes that two of them were rewriting players'
builds, and closes that in `cc_security`. They live in `functions.lua`, which this
trim keeps, so trimming would never have removed them — the two findings are
independent and `B49` is the one that mattered.

**The two-texture keep-list this finding carried for one day is withdrawn,
2026-09-07.** `G6` added it and `G7` widened it: the world's bounds shipped no
media of their own and borrowed `default_obsidian.png` for `cc_mapgen:bedrock`
and `default_obsidian_glass.png` for `cc_mapgen:barrier`, so a trim done against
`nodes.lua` alone would have taken both and rendered half the world's edge as the
unknown-node texture. **That is no longer true.** The same day, `cc_mapgen` was
given its own two textures in `mods/cc_mapgen/textures/`, and **nothing in this
game names either `default` file any more** — `grep -rn obsidian mods/cc_*` finds
nothing. The trim's scope is exactly what it was before `G6`, and the paragraph
distinguishing `default_obsidian_glass_detail.png` from the other two went with
it, having nothing left to disambiguate.

**Recorded rather than deleted, because that is the shape this finding keeps
producing.** A constraint appeared on this finding from an unrelated milestone,
was widened, and vanished inside a week; the same thing happened with `B19` and
`B24`, which sat here as "resolved for free by `A13`" until it turned out that a
deferred item was hiding two live boot-log defects. **Anything that attaches
itself to a deferred finding needs its own reason to be here**, and a borrowed
texture had one for about a day.

**Re-declined by the author on 2026-09-07, on fuller information.** Asked while
the textures were being made whether `default`, `wool` and `dye` could simply be
removed, they were shown that CodeBlock's palette is 106 `default:*` names plus
15 `wool:*`, and that **`mods/codeblock/mod.conf` declares
`depends = default, wool, vector3`** — so removing either stops the bundled mod
loading, and `dye` is present because `wool` requires it. The answer was *"leave
it for now"*. This is the second decision on the same subject, five days after
the first, and it does not change the finding's state: deferred, not pending.
**One correction from that exchange**: the hard dependency was attributed to
`cc_mapgen`'s `mod.conf`, which was wrong — none of the three `cc_*` mods
declares a `depends` line at all. It is the submodule's, which if anything makes
the case for the deferral stronger.

**One thing to check before cutting, since the palette is the contract.** The
block list a player's program uses is `codeblock`'s, in its config; the nodes
come from here. Removing a node the palette names breaks saved player programs,
which is the game's own reason to care about the mod's major version.

**Deferred on 2026-09-02, by the author, and the reason is the good one.**
`codeblock` is expected to integrate the blocks it needs, at which point the
game's vendored `default` is not trimmed but deleted. Doing the trim now means
hand-curating 9,744 lines of third-party code against a contract owned by the
other repository, and then mirroring every palette change the mod makes — the
coupling this project avoids everywhere else. The saving is size and boot noise,
not behaviour, so nothing a player meets is waiting on it. See `ROADMAP.md` under
*deliberately not doing* for what would change that.

### A7 · medium · open, and the edit is upstream — `cc_day` duplicates a block `codeblock` already runs, marked "TEMP fix"

`mods/cc_day/init.lua` · `codeblock lib/register.lua:178`

Both register an `on_joinplayer` calling the same five sky methods; the copy
inside `codeblock` is annotated `-- TODO: TEMP fix`. Sky presentation is the
game's job, not the programming mod's — and removing it also stops `codeblock`
imposing permanent daylight on any other game that installs it.

**Routed here, and it is the one genuinely two-sided item.** The duplicate to
delete is in `codeblock`, but the decision and the behaviour that must survive it
are the game's: `cc_day` is what should own permanent noon. Kept in this audit as
one finding rather than split in two; the mod's roadmap does not list it.

**Nothing is written in this repository for it.** `codeblock` removes the block
upstream, so `cc_day` is already what this side should look like — it is the copy
that survives, and no `cc_*` file changes. The game's half is adopting the release
that carries the removal and then running `L3`, which is why this finding stays
open here after the upstream edit lands and closes only at adoption.

**Corrected 2026-09-02: "identical arguments" above was wrong.** `codeblock` calls
a bare `set_sun{visible = false}`; `cc_day` calls
`set_sun{visible = false, sunrise_visible = false}` — the `B47` fix. The
difference does not make the removal urgent, and `B47`'s **Keep** is where that is
settled: `L1` passes with the duplicate still in place, and removing a call cannot
reintroduce the texture whichever way `set_sun` treats an omitted field. Recorded
here only so the next reader does not re-derive it from the claim that the two
calls match.
### A8 · medium · open — the drop chain is confirmed; `last_mod` is untested by choice and the table walk untouched

`mods/cc_security/init.lua` · `game.conf` · `.luacheckrc`

`function minetest.handle_node_drops() end` and
`function minetest.calculate_knockback() return 0 end` overwrote the globals
outright, discarding whatever another mod installed and being discarded in turn
by any later mod that did the same, with the winner decided alphabetically.

**`last_mod` is a `game.conf` key, not a `mod.conf` one** — checked against the
5.17.0 reference on 2026-09-02, where `mod.conf` has only `depends` and
`optional_depends`. So the declaration goes in this game's `game.conf`, which set
none before, and **only one mod can be last**: spending it on `cc_security` is a
choice about the whole game, not a line in a mod. It is the right mod to spend it
on — it is the only one here whose job is to have the last word.

**Fixed in two halves, and only one of them is a chain.**

- **Drops are chained, with an empty list.** `previous_drops(pos, {}, digger)`
  keeps whatever the captured handler did besides handing out items — logging,
  statistics, a sound — while handing out nothing. Chaining with the real list
  would drop items and break the game's central promise, so the empty list is the
  whole trick.
- **Knockback is not chained, deliberately.** The reference suggests caching and
  calling the old function "to allow multiple mods to change knockback
  behaviour"; that is advice for a mod *modifying* knockback. This one abolishes
  it, the function is a pure calculation, and calling the captured value could
  only cost time before its result was thrown away. `return 0` is the honest
  shape, and `last_mod` is the whole of what protects it.

**A chain cannot make the guarantee on its own, which is why both halves exist.**
A captured handler that invents items rather than reading its `drops` argument
would still drop them. Nothing stops that; being last is what keeps such a mod
from being the one in charge in the first place.

**`.luacheckrc` still ignores `122` for this file, and the reason has changed.**
Replacing the two globals is the point of the lines, so the assignment stays;
what the warning was really pointing at — the replacement being discarded by
whatever loads next — is what `last_mod` fixes. The old rationale said the fix
"belongs with that work"; that work is this.

**Nothing in this game competes for either global, so the fix is defensive.**
`grep -rn "handle_node_drops\|calculate_knockback" mods/` finds only
`cc_security` — not `default`, not `codeblock`, not `wool`. Both halves of the
defect are therefore unobservable in the game as it ships: the captured handler
is the engine default, and `last_mod` orders this mod against nothing. Behaviour
today is identical to the two lines it replaced. The code is kept because it is
cheap and correct if a mod is ever added, but **`last_mod` is not free** — only
one mod in a game can be last, and this spends that slot.

**The chain is confirmed in a world, on 2026-09-02.** `R2` was run by its drop
method — `diggable = false` commented out, server restarted, a node dug by hand,
the line reverted — and nothing dropped, on the ground or into the inventory. So
`previous_drops` is not `nil`, the chain fires, and the empty list reaches the
captured handler. That was the one thing this change could have broken silently,
and it is now evidence rather than a reading of the reference. `R5` is *partial*
only because `R3` was not re-run beside it; `calculate_knockback` is byte-identical
to before, so that half is low risk rather than open.

**What is still untested, by choice.** The composition half — that `last_mod`
makes this mod's assignment the surviving one — needs a second mod that assigns
the same globals, and building one would be testing a composition this game does
not have. Decided by the author on 2026-09-02, recorded so it does not later read
as an oversight. The scenario it defends is a server owner adding a worldmod to a
Codecube server, and even then `diggable = false` is what holds the promise: the
drop handler matters only after something has re-enabled digging.

**`R2`'s drop half had never run before this, in the whole project.** It was
recorded as passing from the first playtest on the strength of the inventory
panel alone, because the check said "with digging somehow permitted" and nothing
in a running game permits it — no chat command digs, `diggable` is a node
property rather than a privilege, and the drone writes with `set_node` and
`VoxelManip`, which never compute drops. A check that cannot be run reads exactly
like one that passed.

**The other half of this finding is untouched, and is why it stays open.** The
mod overrides **every registered node** at `on_mods_loaded` to set
`diggable = false` — a large table walk to express one rule. It has to run there
to see every mod's registrations (moving it earlier silently covers fewer nodes
and nothing fails), and Luanti offers no global switch for it, so there may be
nothing better than the walk. Deciding that is what remains.

**The walk got wider on 2026-09-07**, when `B48`'s fix added an inner `pairs`
over each node's `groups` and a rebuilt table per node. It is the same one pass,
so the cost is still paid once at load — but a walk that now *writes* `groups` on
every registered node has a larger blast radius than one setting `diggable`, and
that is why `R1`, `R4` and `R6` are all marked for re-running.

### B49 · medium · resolved, `R7` passes — the world rewrites what a program built

`mods/default/functions.lua` · `mods/cc_security/init.lua`

`default` registers six ABMs, and they run in this game. Two of them act on
nodes the palette can place, so they reach a player's build:

- **Grass spread** turns `default:dirt` into whatever `dirt_with_*` is within one
  node of it, or into `dirt_with_grass` if any `group:grass` node sits on top. It
  requires light 13 or more above, **which permanent noon always satisfies** —
  `cc_day` makes the one condition that would otherwise gate it unsatisfiable to
  fail.
- **Grass covered** reverts *any* of the five `spreading_dirt_type` nodes to plain
  `default:dirt` the moment an opaque node covers it. All five are in the
  palette. So a program that lays a `dirt_with_grass` floor and roofs part of it
  loses the grass under the roof, minutes later, with nothing said.

The second is destructive: it removes what the program wrote rather than adding
to it. Saplings are the same defect by another route — the palette has ten of
them, and `nodes.lua` gives each an `on_timer` that grows a tree the program
never asked for, over blocks it may have placed.

**This contradicts the game's own page, in as many words.** `CONTENTDB.md` tells
players *"Every block that appears was placed by a program, so the world always
shows what your code did and nothing else."* That was not true. The other four
ABMs — lava cooling, papyrus, cactus, moss — cannot fire, because no lava, water,
papyrus or sand is in the palette; they were only cost.

**Fixed in `cc_security`, not in `default`.** The rule belongs to the game and is
written where the game's other rules are: every node's `on_timer` is replaced,
and every ABM's `action` is replaced with a no-op. Two things about the shape:

- **`0` is truthy in Lua 5.1**, so a timer stopper must return `false`. Reusing
  the `deny` helper that returns 0 would have restarted every timer forever
  instead of stopping it — the opposite of the intent, and silent.
- **Luanti has no API to unregister an ABM.** `core.registered_abms` is listed in
  the reference as a table, but only `core.registered_privileges` is documented
  as modifiable in place, which reads as a deliberate distinction. The table is
  therefore not cleared — the engine registers each ABM by position, and emptying
  it would leave those registrations pointing at nothing. Replacing each `action`
  keeps the shape.

**Keep — the fix rests on undocumented behaviour, and only a world could say so.**
Neutralising an ABM by mutating its `action` is not documented; `PLAYTEST.md`
`R7` was therefore not a formality but the only thing that could confirm the fix
at all, and it passed on 2026-09-02 — a built `dirt` patch, a roofed
`dirt_with_grass` floor and a sapling all unchanged after five minutes, with the
server still running. The fallback, had it failed, was deleting the two ABMs from
`functions.lua` — a vendored edit, which is why it was not the first choice. Undo
either half of this and nothing here fails a gate; only `R7` would catch it.

### B48 · low · resolved, unverified in a world — wool plays the dig animation before the server refuses

`mods/cc_security/init.lua` · `mods/wool/init.lua`

`diggable = false` is enforced by the server. The client predicts a dig from the
node's groups and its own tool capabilities, so for a node it believes a hand can
break, it plays the cracking animation and only then finds the block still there.
The world's ground never does this and wool always does, which is the evidence
for the mechanism: wool is `oddly_breakable_by_hand = 3`, and `default:stone` and
its neighbours are `cracky`, never hand-diggable, so the client never predicts
them. Seen by `PLAYTEST.md` `R1` on 2026-09-01.

Cosmetic — nothing breaks — but it teaches a player that digging half-works,
which is the opposite of what the restriction is for.

**The open question is settled, and from the documented API rather than by
inference.** This was filed saying the mechanism was guessed from which nodes
crack, and that if `diggable` did reach the client then the client was ignoring
it. Neither alternative is open now:
`core.get_dig_params(groups, tool_capabilities, wear)` — `lua_api.md` 5.17.0,
line 4691 — takes **groups and tool capabilities only**, and `diggable` is not an
input to the dig-time calculation at all. So the client cannot consult the field,
and the fix had to come from the groups. The corroboration is the hand's own
groupcaps in `mods/default/tools.lua:13-17` — `crumbly`, `snappy`,
`oddly_breakable_by_hand`, and **no `cracky`** — which is exactly why the
stone-family ground never cracked and wool always did. The observation the
finding was built on now has a mechanism behind it.

**Fixed by stripping six digging groups in the same `override_item` pass.** The
`on_mods_loaded` loop now takes `def` as well as `name` and replaces each node's
`groups` with a copy without `crumbly`, `cracky`, `snappy`, `choppy`,
`oddly_breakable_by_hand` and `dig_immediate`. `diggable = false` is unchanged
and is still what enforces the restriction; the strip only stops the prediction.

**Keep — the six are a closed set, and every other group is kept on purpose.**
The filing warned this was "a change to make deliberately, not as a tidy-up", and
the deliberate part is the list. `flammable`, `falling_node`, `attached_node`,
`soil`, `spreading_dirt_type`, `leafdecay`, `wool`, `dye`, `color_*` and `level`
all survive, because none of them says anything about digging — `level` is kept
because it means nothing without a digging group beside it. Three things a future
change would otherwise re-break:

- **`dig_immediate` is load-bearing, not defensive.** Roughly a dozen `default`
  nodes carry `dig_immediate = 3` — leaves, papyrus, grass, `nodes.lua:725, 789,
  888, 1344, 1722` among them — and that is the engine's always-diggable special
  group, so those predicted a dig regardless of the hand's groupcaps and cracked
  *instantly*. Dropping it from the list brings back the fastest case.
- **`override_item` replaces a top-level `groups` outright rather than merging**,
  so no `cracky` survives from the original definition. That is what makes a
  rebuilt copy sufficient.
- **`del_fields` was not an option.** It arrived in 5.9.0 and `game.conf` sets
  `min_minetest_version = 5.4`, and it deletes top-level fields rather than keys
  inside `groups` — the same note `S8` carries for callbacks.

Nothing else here reads node groups: `codeblock` does not (its `api.groups` is a
documentation grouping of API entries, not node groups), and neither
`codeblock:poser` nor `codeblock:setter` declares `tool_capabilities`.

**Not closed, because nothing has been run.** Both gates are green —
`check_game.sh` passes and luacheck is silent — and **neither runs a line of the
game's Lua**, so this is committed rather than verified, in the same state as
`B19` and `B24`. `PLAYTEST.md` `R8` is what closes it: no crack texture and no
dig sound on `wool`, `default:leaves` and `default:stone` under a held punch.

### B19 · low · resolved, unverified in a world — five `NodeResolver` errors on every world load

`mods/default/schematics/*_log.mts` · `mods/cc_mapgen/init.lua`

Four log schematics embed `flowers:mushroom_brown` and `flowers:mushroom_red`,
and no `flowers` mod is vendored. Harmless — `cc_mapgen` disables decorations —
but every boot log opened with red errors that are not real problems, which
trains you to ignore the log.

**Fixed with two aliases, not by touching the schematics.** `cc_mapgen` now
registers `flowers:mushroom_brown` and `flowers:mushroom_red` as aliases of
`air`, which gives the resolver something to resolve. The alternative was editing
four vendored binary `.mts` files, or deleting the `register_decoration` calls in
`default/mapgen.lua` — both larger, both undone the moment `default` is
re-vendored. Two lines in the game's own mod survive `A13` either way, and cost
nothing if `default` goes.

**No longer waiting on `A13`.** This was recorded as "resolved for free by `A13`",
which made it invisible behind a deferred item. It is not free and it is not
`A13`'s: an alias costs two lines and closes it now. `P3` is what confirms the
log is clean.

### B24 · low · resolved, unverified in a world — vendored `default` used a deprecated tile field, and `cc_security` re-triggered it

`mods/default/furnace.lua:354` · `mods/cc_security/init.lua`

Two `TileDef.image` warnings per load: `default`'s own node definition, and
`cc_security`'s `override_item` pass re-processing it against its own call site.

**Fixed by renaming the field, one word in one line.** The 5.17.0 reference lists
`image` under *"deprecated, yet still supported field names: `image` (name)"*, so
`name` is the same field by its current spelling and the definition is unchanged.
`default:furnace_active`'s animated front tile was the only `image =` in the whole
of `default`. Both warnings go with it: `cc_security` re-processed the same
definition, so there was never a second cause to fix.

**This is an edit to a vendored mod, which is normally out of bounds.** It is one
token, it fixes a real deprecation rather than restyling, and re-vendoring
`default` would silently bring the warning back — so if that happens, look here
first. `P3` is what confirms the log is clean.

## B — bugs

**7 findings, all 7 resolved.** `B50` closed on 2026-09-07, when `W4`–`W9` all
passed at `60259dd` and both of its routes became observed; it is kept in full
above, because its **Keep** paragraphs are what a future change would re-break.
The resolved count **said 5 until 2026-09-07**, while the
table above already said 6; the body was the one that was wrong, `B20` having
been left out of it. Three of the seven are resolved but unverified in a world:
`B19` and `B24` wait on
`P3`, `B48` on `R8`. `B19`, `B24`, `B48` and `B47` are kept in full above — the
first two because a re-vendored `default` would bring both back, `B48` because
the six stripped groups are a set someone could narrow by accident, and `B47`
because the prediction it got wrong is the reusable part.

### B47 · low · resolved, `L1` passes — the sunrise texture is still drawn, so part of the sun shows

`mods/cc_day/init.lua`

`player:set_sun({visible = false})` hides the sun disc and nothing else. The
sunrise and sunset glow is a separate field of the same table,
`sunrise_visible`, which defaults to true — so at dawn and dusk part of the sun
is still painted on a sky the game promises has none. Seen at `/time 5000` by
`PLAYTEST.md` `L1` on 2026-09-01.

The light half of the promise is intact: `override_day_night_ratio(1)` pins the
level and it does not vary. This is the objects half, and it is one field:
`set_sun{visible = false, sunrise_visible = false}`. `L1` passes on it.

**Keep — a blocker that was predicted and did not exist, and how that was
settled.** This was filed with a warning that the one-field fix might not hold:
`codeblock` registers the same five calls in its own `on_joinplayer` (the
duplicate `A7` removes), including a bare `set_sun{visible = false}`. The
reference lists every `set_sun` field as optional with a stated default, and says
that passing *no* arguments resets the sun entirely — which reads as though an
omitted field might take its default rather than keep its current value. If so,
the mod's bare call would put `sunrise_visible` back and `A7` would be a
prerequisite.

**It is not.** `L1` re-run at `b9bf82b` passes with the duplicate still in place.
Either `set_sun` merges with the current parameters or `cc_day`'s callback runs
second; the outcome does not distinguish them and it does not need to, because
removing a call cannot reintroduce the texture either way. The reusable part is
the method: the ambiguity was written down as unverified rather than resolved by
reading the reference a second time, and one re-run settled it in a minute.


- **B20 · low · resolved** — every deprecation warning in the boot came from
  `mods/formspecs/init.lua:110, 117`: two `TileDef.image` warnings plus a
  `description.txt` one, the complete set from the whole game. The first-party
  code had no deprecation debt at all. Removing the mod removed its warnings,
  with `codeblock`'s `A1` (the replacement is its `lib/forms.lua`).

  **Keep — and it was hiding two others.** Two more warnings appeared once
  `formspecs` was gone: `mods/default/furnace.lua`, and `cc_security`'s blanket
  `override_item` re-triggering the same check. Both were always present —
  **Luanti deduplicates deprecation warnings by message**, and formspecs' two
  identical ones were consuming the quota. Worth remembering as a general trap
  when reading a boot log. Those two became `B24`.

## S — sandbox and security

1 finding, resolved and confirmed by `R6`. The first `S` on the game's side:
`S1`–`S7` are the mod's and are about the Lua sandbox, which is the mod's
boundary to hold. This one is about the *player's* boundary, which is the game's,
and it is kept in full because it took two fixes and the first was wrong.

### S8 · medium · resolved, `R6` passes — a bookshelf's formspec reaches around the blanked inventory

`mods/cc_security/init.lua` · `mods/default/nodes.lua:2483`

`cc_security` blanks the player's inventory formspec, and `PLAYTEST.md` `R2`
confirms the inventory key opens nothing. But `default:bookshelf` carries a node
formspec of its own, set into node metadata by its `on_construct`, and that
formspec contains `list[current_player;main;0,2.85;8,1;]` and a second `main`
list below it. Right-clicking the bookshelf therefore displays the player's real
main inventory — the two drone tools included — with a `listring` to the
bookshelf's own `books` list, so items can be moved into it.

**Reachable in ordinary play, and that is what makes it a finding rather than a
curiosity.** The palette exposes `bookshelf` (`mods/codeblock/lib/config.lua:285`
at the adopted commit), so any program can place one. Nothing can then dig it —
that is the rest of `cc_security` working correctly — so a tool moved in comes
back only if the player finds that bookshelf again. Found by `R1` on 2026-09-01;
reading the three `cc_*` files could not have shown it, because the defect is in
the interaction between the blanked formspec and a vendored node's own.

**`A13` does not close this one, unlike `B19` and `B24`.** Trimming `default` to
what the palette references *keeps* `bookshelf`, since the palette names it.
`chest` and `furnace` carry the same `list[current_player;main;…]` pattern and
are **not** in the palette, so those two do go away with `A13` — bookshelf is the
one that has to be handled here.

**Fixed in two passes on 2026-09-01, and the first was too narrow.** The
`on_mods_loaded` walk that sets `diggable = false` also overrides
`allow_metadata_inventory_put`, `_take` and `_move` to return 0 on every
registered node, chosen from four options. That stopped items reaching the
bookshelf, and `R6` confirmed it — while failing on the half it had left open.

**The hazard was never the bookshelf's inventory. It was the player's.** The
formspec's `list[current_player;main]` is a way *into the player's own
inventory*, so the tools could be dragged out of the hotbar into a row below it —
and with the inventory formspec blanked, the player then has no way to open that
row. `R6` found a player who had just put both drone tools out of reach.
Recoverable, since reopening any bookshelf shows the same rows, but nothing in
the game says so, and a player who does not think of it has lost the game's only
two tools.

Closed by `minetest.register_allow_player_inventory_action` returning 0: the
player may not move an item anywhere, within their inventory or across it. It
governs only actions the player initiates, so `codeblock` still hands out the two
tools from Lua. The node-side overrides are kept alongside it — they are the same
boundary from the other side, and either closes the bookshelf alone.

**`R6` passes on it at `c042364`, and `R4` was re-run beside it.** That pairing
was deliberate: the guard denies *every* player-initiated inventory action, which
is broad enough to break the editor or a tool that moved an item, and `R4` is
what says the drone still builds through it. Both pass.

**Keep — why the narrow fix looked complete, which is the trap worth remembering.**
The reasoning stopped at the node: deny the node inventory, nothing can be put in
it, done. But a formspec is not only a view of the node it belongs to, and this
one names two inventories. The question to ask of any formspec reached through a
restriction is *which inventories does it name*, not *what is it a formspec for*.
`R6` is written to test both halves now.

The panel still opens, and that residue is accepted: the formspec is a metadata
string on the placed node, not a field of the definition, so nothing reachable
from `cc_security` removes it. It now shows a set of rows nothing can move.

The three rejected options, so they are not re-derived. **Clearing the metadata
`formspec`** closes it completely but has to happen per placed node, via an
`on_construct` wrapper plus an LBM for worlds that already have one — more code
and more to get wrong for a panel that is now inert. **Dropping `bookshelf` from
the palette** closes it at the source and lets `A13` delete the node, but the
work is the mod's and it breaks any saved program that names the block.
**Leaving it documented** was the cheapest and loses a boundary the game
advertises.

Note for any wider fix: `del_fields` on `override_item` arrived in 5.9.0 and
`game.conf` declares `min_minetest_version = 5.4`, so removing a callback
outright is not available.

## C — compliance and packaging

8 findings, 6 resolved. `C21` and `C22` are open. `C21` is the only one here the
game cannot fix in its own tree; `C22` is entirely in it.

### C22 · low · open — three original images ship to every player with no licence stated anywhere

`menu/background.png`, `menu/header.png`, `menu/icon.png`

The game's own menu artwork. **All three reach every player** — `P2` at `8b27f2f`
lists them by name in the release archive, and `.gitattributes` keeps them there
deliberately, because `menu/*.png` is what the main menu reads. **No licence is
stated for them in any file.** `THIRD-PARTY-LICENSES.md` has no media row and no
mention of `menu/` at all; there is no `menu/license.txt`; the root `LICENSE` is
the bare AGPL-3.0 text with no statement of what it covers here; and `.cdb.json`
carries `"license": "AGPL-3.0-only"` and **no `media_license`**, though
ContentDB's package config accepts one — `.claude/skills/luanti-reference/references/contentdb-package-config.txt:84`,
*"media_license : A license name, see /api/licenses/"*.

**Verified rather than taken on report.** `code-expert` raised it as suspected; it
was checked here by reading all four files. `menu/background.svg`, `header.svg`
and `icon.svg` are the sources beside them and are `export-ignore`d by the `*.svg`
rule, so they do not ship — the PNGs do.

**Low, and the reason is worth stating because it argues both ways.** The root
`LICENSE` plausibly covers the whole repository, so this is not a legal void; it
is an unstated one, and the licence named on the package page describes the
*code*. What makes it worth filing anyway is that this project already answers
the question everywhere else: every bundled mod has a `license.txt`, every one is
catalogued in `THIRD-PARTY-LICENSES.md`, and `C3`, `C4` and `C5` exist because
that cataloguing was done deliberately rather than by accident. The one directory
of original media the game ships is the one place the convention was not applied.

**Sharpened on 2026-09-07 by `G7`, which is what turned it up.** `cc_mapgen` now
ships two textures of its own, and `mods/cc_mapgen/license.txt` gained a *License
of media* section naming both files and their licence. So the game now states a
media licence for two 16×16 textures and none for three images totalling 655 kB
that every player sees before they enter a world. That contrast is the finding.

**Not fixed here.** The fix is `code-expert`'s in all three of its parts: a media
licence statement, a `THIRD-PARTY-LICENSES.md` row, and a `media_license` field
in `scripts/gen_cdb_json.sh` — `.cdb.json` is generated and must never be
hand-edited. **Which licence to state is the author's**, not either agent's, and
it is the same question `G7`'s texture decision raises: AGPL-3.0-only keeps the
package single-licence, CC BY-SA 4.0 is the convention for game art and lets the
artwork be reused. `ROADMAP.md` `G7` records that decision and flags it
reversible.

### C21 · low · open — a bundled submodule carries the version ceiling this game's own check forbids

`mods/vector3/mod.conf`

`max_minetest_version = 5.5`, beside `min_minetest_version = 5.3`. `C1` is the
same defect in this game's `game.conf`, and `check_game.sh` now fails a
reinstated one there — while a mod the game hard-depends on has carried one all
along, unchecked.

**It blocks nothing at load.** Per the 5.17.0 reference the engine reads only
`depends` and `optional_depends` out of a `mod.conf`, so this is ContentDB
metadata: it constrains what the *package page* claims to support, not what the
engine will start. That is what makes it low rather than high.

**What makes it worth filing anyway is the direction of travel.** `ROADMAP.md`
`G6` raises this game to `min_minetest_version = 5.9`, **four minor versions**
above `vector3`'s stated ceiling — so the game advertises a floor its own
dependency advertises as out of range. A reader comparing the two package pages
sees a contradiction, which is exactly the shape `C4` was filed for.
`mods/codeblock/mod.conf` still says 5.4, which is the other half of the same
picture and is upstream's call.

**Corrected 2026-09-07, the same day this was filed: three minor versions, not
four.** It was written against a `min_minetest_version` of 5.7, which was the
author's instruction and was factually wrong —
`core.register_mapgen_script` first appears in the 5.9.0 `lua_api`, so 5.7 and
5.8 cannot start the game at all. The gap this finding describes widened with
the correction; the severity did not, because the engine still reads no
`max_minetest_version` out of a `mod.conf`. Recorded rather than overwritten:
`G6` decision 4 in `ROADMAP.md` carries the evidence.

**Not ours to edit.** `vector3` is a pinned submodule with its own repository
(`v1.5` at `16621648`); the fix is upstream or a re-pin, and neither is work this
repository does on its own. Nothing here should hand-edit a submodule's
`mod.conf` — that change would be silently discarded by the next pointer move.
Recorded so it reads as known rather than missed.

- **C20 · medium · resolved in `9ad884c`** — the ContentDB long
  description was `README.md` verbatim: `scripts/gen_cdb_json.sh` embedded the
  file whole into `long_description`, and ContentDB's own guidance says most of
  what a good README contains does not belong there. The two documents have
  different readers — GitHub wants badges, repository links and a licence line,
  while a ContentDB page reader is **already on the page**, so those are noise at
  best. The README broke the rules on a title heading, the licence line, links to
  the repository, and links to the package's own ContentDB page — two of the
  latter. Fixed by writing `CONTENTDB.md` and pointing the generator at it, with
  the rules in the script's own header so they are not re-derived; `.cdb.json`
  regenerated. `PLAYTEST.md` `P5` is the check that it reads as a page.

  **Keep — nine images, five of them load-bearing, which is what made this more
  than tidiness.** ContentDB's stated reason for the images rule is that
  *"images … are not visible inside Luanti"* — its words — so all nine reached
  the website's readers and nobody browsing in-game. The *Quick start* used the
  two tool icons **inline in the instructions**: *"Right click with
  `![drone_poser]` tool on a block to place the drone"*. Strip the image and the
  sentence loses its object; four `dp.png` and one `ds.png` were in that state,
  which is why `CONTENTDB.md` names the two tools in words. The mod's counterpart
  is `C19`. <https://content.luanti.org/help/appealing_page/>

- **C2 · low · resolved, and the filing was wrong** — image URLs named `master`
  while the repository has only `main`. Now they name `main`. The
  `codeblock/master/…` URLs alongside were correctly left alone: that repository
  really does use `master`.

  **Keep — the error was methodological, and it is why this entry survives.**
  It was filed as High, claiming the ContentDB screenshot was broken. *That was
  incorrect — the images always worked*: GitHub serves the old name of a renamed
  default branch as an alias, the `master` URL returned the identical
  510,694-byte file, and a bogus ref 404s. `git ls-remote` confirmed only `main`
  existed, and the 404 was then **inferred rather than fetched**. One `curl`
  would have settled it. Verify the claim you are about to publish, not the fact
  next to it.

- **C3 · medium · resolved** — `mods/worldedit` and `mods/formspecs` shipped
  AGPL and MIT code without its licence text; both licences require the notice to
  travel with the code, and AGPL §5 is explicit. `worldedit` gained the AGPLv3
  text.

  **Keep — with one correction, and the mechanism it produced is what remains.**
  For `formspecs` an MIT LICENSE was written into the directory and reported
  done: *that was wrong* — it was a submodule of a repository we do not control,
  so the file was untracked and would have vanished from every fresh clone. Its
  MIT text went into `THIRD-PARTY-LICENSES.md` instead, and `check_game.sh` now
  verifies that a mod either carries its own licence file or is named in that
  document. Negative-tested both ways. Both mods have since been deleted; the
  mechanism covers `default`, `dye` and `wool`.

- **C4 · medium · resolved** — licence metadata disagreed across the project: the
  game AGPL-3.0-only, the mod inside it GPL-3.0-only with a GPLv3 badge.
  Combining is permitted and AGPL is the right label for the result, but a reader
  comparing the two saw a contradiction. Unified on AGPL-3.0-only.

  **Keep — whether relicensing was permitted, and how that was settled.** AGPL
  was the only available direction, since the game vendored AGPLv3 WorldEdit.
  `codeblock` descends from TurtleMiner and three other authors appear in its
  history, so permission needed checking: blaming every tracked text file found
  exactly **two external lines out of ~4,880** — a markdown underline and a blank
  line — neither copyrightable. Changed: `LICENSE`, the README badge and line,
  `.cdb.json`'s `license` and `media_license`, and `scripts/gen_cdb_json.sh`,
  which hardcoded the licence and would have reverted a hand-patched `.cdb.json`.
  Kept in this audit rather than the mod's because the contradiction was between
  the two repositories and the label that resolves it is the game's; the matching
  edits inside `codeblock` are recorded in its changelog as a breaking change for
  redistributors.

- **C5 · medium · resolved** — the three `cc_*` mods had no licence file and a
  `mod.conf` carrying only `name` and `description`. Each now has a `license.txt`
  naming AGPL-3.0-only and pointing at the root `LICENSE` rather than three 35 kB
  copies, and `check_game.sh` enforces their presence.

  **Keep — `title` and `author` were added deliberately not uniformly.** The four
  first-party mods carry `author = giga-turbo`; the vendored ones get a `title`
  only, because claiming authorship of a vendored mod would be false attribution
  however tidy. This entry also carried a stale *partial* chip for several
  revisions while its own prose said the work had landed; corrected at `580cf1f`.
  Same drift as the mod's `A12`: prose updated when the work landed, state marker
  not.

- **C15 · low · resolved in `8d18e8b`** — the release archive shipped `.claude/`
  (993 kB of agent and skill definitions), the audit, `.github/`, `scripts/`, the
  project record and the two root screenshots the README pulls from GitHub by
  absolute URL anyway. `.gitattributes` carried four rules — `scr`, `*.xcf`,
  `*.blend*`, `*.svg` — and **no rule for hidden files at all**. `.* export-ignore`
  now covers every hidden file and directory, and the art sources, `scripts`,
  `CLAUDE.md`, `ROADMAP.md` and `TODO.md` are excluded by name. `menu/*.png` is
  deliberately kept: it is what the main menu reads. Excluding `.cdb.json` costs
  nothing because ContentDB reads it from the repository rather than from the
  archive, and the file's own header now says so. Measured with `git archive
  --format=zip` at `8d18e8b^` and at `8b27f2f`: **3.29 MB down to 1.93 MB
  zipped**, 523 files down to 488. An earlier measurement by another route
  recorded 4.94 MB down to 2.75 MB — see the evidence section. First finding
  allocated after the audit split; its counterpart in the mod's audit is `C10`,
  the same subject in `mods/codeblock/.gitattributes`.

  **Keep — the standing hazard, which is the part that outlives the fix.**
  `.gitattributes` decides what reaches a player, and **nothing in either CI
  checks it** — not `check_game.sh`, not the mod's workflow. A file added to the
  repository ships unless a rule excludes it, and the failure is silent in both
  directions: nothing local fails, and the only way to see it is to build the
  archive. Every tracked document added since — `AUDIT.md`, `PLAYTEST.md`,
  `CONTENTDB.md` — needed its own line for exactly that reason.

## A — architecture and performance

4 findings, 1 resolved. `A7`, `A8` and `A13` are open and in full above.

- **A14 · medium · resolved** — CI conflated the component with the composite.
  `codeblock` Phase 0 put every check in the game repository, where they linted
  and unit-tested the submodule. Three things were wrong: the game's badge
  reported on the mod's internals; the mod's own repository, separately developed
  and separately published, had **no CI at all**; and a submodule bump could turn
  the game red for reasons outside the game. Split along the component/composite
  line in `codeblock` Phase 3: the mod owns its `.luacheckrc` (nearly all of the
  game's was facts about that mod), its specs and its badge.

  **Keep — what the game's own check covers, and what it still does not.**
  `scripts/check_game.sh` keeps only what this repository alone can check:
  `game.conf` sane and no reinstated version ceiling, submodules populated, every
  `mod.conf` name matching its directory and unique, every declared hard
  dependency shipped, first-party mods and the root carrying licences,
  `.cdb.json` not stale — plus luacheck over the three `cc_*` mods. It was
  **negative-tested before being trusted**: a reinstated ceiling, a dangling
  dependency and a stale `.cdb.json` were each injected and each caught. A check
  that cannot fail is worth nothing. What it still does not check is
  `.gitattributes`, and therefore what the release archive contains — see `C15`.
  The same split is why this repository's CI and the mod's go red independently;
  check the repository you changed.

## Verified, committed, claimed

**Verified:** `scripts/check_game.sh` passes, in this tree and inside a fresh
clone; luacheck is silent on the three `cc_*` mods; the `.claude/` size quoted in
`C15` (993 kB, measured here); `C20`'s counts, read out of `README.md` — nine
images, four `dp.png`, one `ds.png`, two links to the game's own ContentDB page.

**Verified from the outside, at `8b27f2f`:** `.gitattributes` excludes what it
intends to. `P2` built the archive and listed it — 488 entries, nothing hidden,
no art source, no `scripts/`, none of the six record documents, and all three
`menu/*.png` present. That closes the half of `C15` that reading could not
settle. `P1`'s clone half passed with it: a fresh `git clone
--recurse-submodules` populates `codeblock` `2647228` and `vector3` `16621648`
from the HTTPS remotes in `.gitmodules`, so neither pointer names a commit
nobody can fetch.

**Corrected by that run — the sizes.** By `git archive --format=zip`, the pair
is **3.29 MB → 1.93 MB zipped** (4.32 MB → 2.26 MB uncompressed, 523 files down
to 488), measured at `8d18e8b^` and at `8b27f2f`. Neither half matches the
4.94 MB → 2.75 MB in `C15` and the changelog, so that pair was measured by some
other route — most likely `du` on the unpacked tree, where cluster rounding over
~450 small files accounts for the gap. The reduction is real and slightly larger
than claimed; the absolute figures were not reproducible, and the method now
travels with the numbers so the next measurement is comparable.

**Verified in a world at `60259dd`, on 2026-09-07 — the whole of `G6`.** `W4`
through `W9` all pass, which is the largest single piece of evidence this project
has produced and the thing that closes `B50` on **both** routes. The floor is at
`y = 0` with air under it and `mapgen_env.lua` demonstrably ran on the emerge
threads; the wall is unbroken and full height with no gap at a mapchunk seam; the
drone's own error names 1024, so this game's `minetest.conf` reaches
`core.settings` and the drone's bound and the wall are one number; a world
carrying `mapgen_limit = 4096` in its `map_meta.txt` is re-bounded on opening,
which is the whole of what `override_meta = true` buys; the clamp fires on a fall
and not on a player standing against the wall or on the exposed floor plane; and
the rescue's destination is a place you can stand, across all four of `W9`'s
cases.

**Verified, and note what shape of evidence it is.** Route one of `B50` was never
observed in its broken state — nobody walked to ±4080 before the fix — so `W5` is
the fix holding rather than the defect reproduced. Route two *was* observed both
ways. `C21` is read straight out of a tracked file (`mods/vector3/mod.conf`) and
is verified as *a fact about the metadata*; what is unverified is whether it costs
anything.

**Committed and unproven, on branch `g6-world-limits`, tip `60259dd`:** what is
left in this state is `B48`'s group strip at `ec02760` — `R8` is its check, with
`R1`, `R4`, `R6` and `P3` re-run beside it — and `B19` and `B24`, which wait on
`P3`. `G6` itself is no longer here: `f5f2385` carried `minetest.conf` at
`mapgen_limit = 1024`, `game.conf` at `min_minetest_version = 5.9`, a new root
`settingtypes.txt`, `cc_mapgen`'s bedrock node and forced limit, the new
`cc_mapgen/mapgen_env.lua`, and `cc_security`'s world-box globalstep with
`repair_spawn()`; `60259dd` rewrote the rescue on the same file; and the `W`
group has now been run against the result. **Both gates were re-run green after
each commit** — `check_game.sh` ending `all game integration checks passed` with
`.cdb.json matches CONTENTDB.md`, and luacheck on the three `cc_*` mods printing
nothing — and **neither gate runs a line of the game's Lua**, which is why the
`W` group and not either commit is what closed `B50`. **Nothing was re-run for
the playtest and nothing was owed**: no code changed. CI still has no run on this
branch; the latest is on `578b364`, which predates it.

**Written and gated, and none of committed, released or seen — three changes, in
one working tree over `93b8ea1`.** This is a fourth state and it is weaker than
*committed and unproven*, because there is no sha to name. `G7` holds all three:
the translucent barrier at the world's edge; the game's own two textures for both
bound nodes, in a new `mods/cc_mapgen/textures/`; and `mgflat_ground_level` at
128 with the settings entry, the `minetest.conf` default and the forced override
that carry it, plus the `cc_security` fallback that moved with it. **Both gates
were run green by `code-expert` after the last edit** — `check_game.sh` ending
`all game integration checks passed`, luacheck on the three `cc_*` mods printing
nothing — and **neither runs a line of this game's Lua**, so green says the game
still assembles and nothing more. `PLAYTEST.md` `W10`–`W14` are the five checks,
all `unchecked`, none with a sha. **No finding is opened by any of the three**:
`G6`'s wall was correct and `W5` says so, and the one real defect the pass
introduced was caught before it was committed.

**Committed, unproven:** `CONTENTDB.md` and the generator change for `C20`
landed in `9ad884c`, `.cdb.json` regenerated and `check_game.sh` passing on it.
It has not been seen rendered on ContentDB, in a browser or in-game — that is
`P5`, and `P5` can only run after a release.

**Played, at `7f649d8` on 2026-09-01.** The `W`, `L` and `R` groups were run in a
world by the author: `W1`–`W3`, `L2` and `R1`–`R4` pass, `L1` is partial. So
`cc_mapgen` is proven — flat and clean at spawn, far out into unemerged map, and
in a world created with other flags — the light level is pinned, nothing is
diggable, no item drops, there is no knockback, and the drone still builds with
every node undiggable. `B47`, `B48` and `S8` came out of the same hour. The
engine version was Luanti 5.17.0, read from the install path in the engine's own
debug log rather than noted at the time.

**Re-run at `b9bf82b`, same day.** `L1` passes: no sun, moon, stars, clouds or
sunrise glow at any hour, so `B47` is closed and the `A7` prerequisite it
predicted was imaginary. `R6` was partial — the bookshelf refused items, and the
player could still move their own tools out of reach through it, which reopened
`S8`.

**Re-run again at `c042364`, and this is where the restrictions stopped being an
assertion.** `R6` passes on both halves and `R4` passes beside it, so `S8` is
closed with the guard proven not to be too broad. Every restriction the game
claims is now checked: nothing diggable, no drops, no knockback, no inventory
reachable, and the drone building through all of it.

**Played three times on 2026-09-07, and the record of the first two is worth
keeping for what it cost.** The first was the uncommitted working tree: `W8`'s
ordinary case passed and `W4` was partial as a by-product, and the same sitting
produced the spawn-column loop and its fix. Both result lines named a date and a
tree instead of a sha, and they were **kept that way rather than backdated onto
`f5f2385`**, because `repair_spawn()` landed on the same path in between. The
second was at `f5f2385`: `W8` passed, clearing its missing sha, with `W9`'s full
pass beside it. **`60259dd` then reversed where the rescue puts a player** — the
author's instruction after playing, with both checks passing beforehand — so
neither result was about the code in the tree any more, and both were **retired on
2026-09-07**, the first evidence this project has ever taken away.

**The third run is the whole `W` group, at `60259dd`, and it is six passes.** It
is what the two retirements were holding out for: every one of `W4`–`W9` now names
a sha, both routes of `B50` are observed, and `W6` and `W7` — the drone's bound
and an old world re-bounded — were run for the first time in this project rather
than re-run. `W9` passed all four cases, including the blocked column and the
exhausted scan bound, which the 2026-09-07 rewrite added and which nothing had ever
covered. `W8` is a **full** pass rather than an upgraded partial: what left it
ambiguous before was a near-miss half nobody had run, and the rewrite put that half
into the check's own instructions. **The rule cost one re-run and bought results
that name the code in the tree rather than code that had since changed**, which
is the argument for it whatever the re-run costs.

**Still not checked:** `R8`, which is the whole of `B48`'s
evidence; `R3` beside `R5`, which is all that keeps `R5` partial; `L3`, gated on
`A7` landing upstream; `P3` (the boot log), `P4` (the main menu), `P5` (the
ContentDB page, which needs a release), and the boot half of `P1`. **`R1`, `R4`
and `R6` are marked for re-running** at the same time: the `B48` change rewrites
`groups` on every registered node, and if the new inner loop errors on any one of
them, `register_on_mods_loaded` aborts and every node after that point keeps
`diggable = true` — with table iteration order unstable, that is a different set
of nodes each boot.
`L2`'s second-player half was not exercised either — singleplayer only, so a
per-player setting applied to whoever joined first would not have been caught.

**Recovered rather than recorded:** the engine version. It was not noted at the
time, and was read afterwards out of the engine's own `debug.txt` — a single
install, `AppData/Local/luanti/5.17.0`, running every session from 22:13 to
23:40 on 2026-09-01. The same log confirms the three rounds fall either side of
`3ce1eed`, `b9bf82b` and `c042364`, which is what makes the commit on each result
line checkable. **Note it at the time next time**: this only worked because one
version is installed and the log had not rotated.

## Corrections kept rather than edited away

Two filings in this document were wrong and say so where they stand: `C2` was
filed High on an inferred 404 that one `curl` disproved, and `C3` reported an
untracked licence file as a fix. Both are kept because the method that produced
them is the reusable part. `C5` additionally carried a stale state marker for
several revisions while its prose was already correct.

**Two more from 2026-09-07, both about a version number.** `C21` was filed
against a `min_minetest_version` of 5.7 and the real floor is 5.9 — the number
came from an instruction and was believed rather than checked, and reading the
shipped `lua_api` at three tags settled it in minutes. And `B50` was filed as one
route out of the world when there are two; the second was found by building the
fix for the first, which is the reusable part: **a fix is where a defect's real
shape shows up**, and this one was not visible from any amount of reading
`minetest.conf`.

---

Revised 2026-09-07, on the world's wall becoming a translucent
`cc_mapgen:barrier` above the `cc_mapgen:bedrock` floor. **No finding was filed
and no state changed: the counts stay at 19 findings, 15 resolved, 4 open** —
`A7`, `A8`, `A13` and `C21`. The wall `G6` built was a correct barrier and `W5`
proves it stands unbroken and full height; what the author wants changed is what
it looks like, which is an appearance goal and not a defect, so its record is
`ROADMAP.md`'s new `G7` milestone and `PLAYTEST.md`'s `W10`, not an id here.
`code-expert` also found no defect in code it did not write. The one change to
this document is `A13`'s **Keep** paragraph, which now names **two** textures the
trim must preserve — `default_obsidian.png` and `default_obsidian_glass.png` —
and says explicitly that `default_obsidian_glass_detail.png` is *not* one of
them, because the framed drawtype that would have used it was rejected. The
change itself is **written and gated but not committed**: both gates were run by
`code-expert` after the final edit and both are green, and neither runs a line of
this game's Lua, so nothing here is behaviour evidence.

Revised 2026-09-07 at `60259dd`, on the whole `W` group passing. **`B50` moves to
resolved**, closed by `PLAYTEST.md` `W4`–`W9` rather than by a commit: route one,
walking off the generated edge, had never been observed at all and rests on `W5`;
route two had lost its evidence earlier the same day when `60259dd` reversed the
rescue's destination, and `W8` and `W9` were rewritten and re-run against it. The
counts move to **19 findings, 15 resolved, 4 open** — `A7`, `A8`, `A13` and `C21`
— and the `B` category has no open finding left. `B50` stays in this document in
full, because its **Keep** paragraphs are what a future change would re-break, and
one is added: refusing to backdate `W4` and `W8` bought results that name the code
in the tree rather than code that had since changed, and **no result in this
project now names a tree instead of a commit**. Route one is recorded as closed by *the fix holding* rather
than by the defect being reproduced, which is the weaker of the two shapes and the
only one that was available. `W9`'s pass moves from `f5f2385` to `60259dd` and
from three cases to four, and `repair_spawn()` is now exercised only by case 4.
Nothing was re-run for this and nothing was owed — no code changed, and both gates were last green on
`60259dd`. `B48` stays **resolved, unverified**: `R8` has still not been run.

Revised 2026-09-07, on the rescue being reversed at `60259dd` and on this
finding's route-two evidence going with it. **No finding changed state, none was
filed, and the counts are unchanged: 19 findings, 14 resolved, 5 open** — the
reversal is a design decision the author asked for after playing, not a defect,
and its record is `ROADMAP.md` `G6` decision 7. What changed here is `B50`'s
verification: it goes from *verified for route two only* to **unverified on both
routes**, because `W8` and `W9` had passed on a rescue to spawn and `60259dd`
replaced that destination. The **Keep** about the repair going one node under the
destination rather than filling the plane at `y = 0` is **reversed and kept as the
reasoning that was outweighed** — the shaft it warned about is now accepted, on
the ground that from a shaft you can program your way out and from an endless fall
you cannot. `W4`'s re-run target moves from `f5f2385` to `60259dd`. The `cc_*`
line count is corrected from 338 to **397** with comments, **160** without.

Revised 2026-09-07, a fifth time, on `G6` being committed and `W9` passing.
`B50`'s fix is now `f5f2385` on branch `g6-world-limits`, with `B48`'s group
strip split out ahead of it as `ec02760`, and **both gates were re-run after
committing** rather than before. The finding moves from *fix written and never
seen in a world* to **fix committed, verified for route two only**, and the two
routes are now mapped onto their checks: `W4`, `W8` and `W9` are route two,
`W5` and `W6` are route one, `W7` is neither. `W9` is a full pass at `f5f2385`,
out-of-range spawn included, which is the false pass it was written to exclude.
`W4` and `W8` **keep their missing sha rather than being backdated onto
`f5f2385`** — `repair_spawn()` landed on the path they exercise in between, and
`R6` is why this project does not carry a result across a change to the code it
tested. The `cc_*` line count is corrected from 103 to **338**. No finding
changed state and the counts are unchanged: 19 findings, 14 resolved, 5 open.
**`B50` now closes on `W5`, not on more code.**

Revised 2026-09-07, a fourth time, on the first in-world evidence `G6` has. The
author played the **uncommitted working tree**: route two of `B50` and the clamp
that answers it are **observed rather than inferred**, so this finding stops
being suspected in that half, while route one and the wall stay inferred. The
same sitting found the rescue looping at the spawn column, which has **no id** —
the clamp has never been committed, so that is the change being wrong before it
shipped and its record is `ROADMAP.md` `G6`. Three **Keep** paragraphs added
against `repair_spawn()`: why the repair goes under the destination rather than
on the plane at `y = 0`, why `get_node_or_nil` and `load_area` are both required,
and why the `walkable` tests are against `false` rather than truthiness. Each
would ship a silent half-fix if tidied away. No finding changed state and the
counts are unchanged: 19 findings, 14 resolved, 5 open.

Revised 2026-09-07, a third time, while `G6` was built: `B50` widened to two
routes — the generated edge, and a hole a program digs in the floor, which the
wall does not close — with the author's ruling that `cc_security` clamps a player
outside the world box back to spawn; its fix recorded as written-and-unrun, with
`W4`–`W8` as the evidence it will need. The engine floor is corrected from 5.7 to
**5.9** in `C21` and in `B50`'s **Keep**, on the shipped `lua_api` at three tags:
`register_mapgen_script` is absent at 5.7.0 and 5.8.0 and present at 5.9.0. The
gap `C21` describes is four minor versions, not three. `A13` gains a constraint —
the trim must keep `default_obsidian.png`, which the bedrock node reuses. No
finding changed state and the counts are unchanged: 19 findings, 14 resolved,
5 open.

Revised 2026-09-07, a second time, while the world-limits feature was shaped with
the author: `B50` and `C21` filed, both open and both with nothing written for
them. `B50` is the defect `ROADMAP.md` `G6` closes and is **suspected from
reading, not seen in a world**; `C21` is `vector3`'s `max_minetest_version = 5.5`,
which `G6`'s move to 5.7 makes visible. The counts move to 19 findings, 14
resolved and 5 open. The feature's own grounds are in `ROADMAP.md`, not here —
work that is wrong before it ships is the roadmap's record.

Revised 2026-09-07, describing codecube `578b364` (main) plus an uncommitted
`cc_security` change: `B48` moves to resolved-unverified, its open question
settled from `core.get_dig_params` rather than from inference; `A8` records that
the table walk it holds open has widened; the `B` count in the body is corrected
from 5 to 6, and a duplicated stale `### A8` heading is removed.

Revised 2026-09-02 five times: while scoping G3, which produced `B49` and
deferred `A13`; at `377d1f9`, when `R7` confirmed the `B49` fix in a world; again
when `A7` was routed upstream — the duplicate is removed in `codeblock`, so
nothing is written here and the finding closes at adoption, and the same pass
corrected `A7`'s "identical arguments" and `A8`'s `last_mod`, which is a
`game.conf` key and not a `mod.conf` one; again at `6f7d118`, when `A8`'s
callback half was fixed, and once more when `R5` was cut back to a regression
check — nothing in the game competes for those globals, so the composition half
is untested by the author's decision; and finally at `7dc764f`, when `R2`'s drop
half ran for the first time and confirmed the chain.
Before that, 2026-09-01, five times in one day: at `8b27f2f` for the packaging checks;
at `7f649d8` for the first playtest; again for the `B47` and `S8` fixes it
produced; again after re-running `L1` and `R6` against those fixes, which closed
`B47` and reopened `S8`; and again at `c042364`, when `R6` and `R4` closed `S8`
for good. The adopted codeblock release is `2647228` (master). `S8`, `B47`, `B48`
and `B49` are the new findings; ids were allocated against the mod's audit in the
sibling checkout, which stands at `B46`, `S7`, `A16`, `C19` and `F8` — the game's
`C20` is the highest `C`.
