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
`B50` and `C21` on 2026-09-07, then `C22`, then `A19` and `A20` on 2026-09-09 —
the next two free `A` numbers, the mod's audit holding `A15`–`A18`.
The `S` series was all the mod's until `S8` was filed, fixed and confirmed here
on 2026-09-01; the `F` feature series is the mod's own.

States: **resolved**, **open**, **won't fix** (the defect is real, the decision
is not to fix it — `A20` since 2026-09-09), **withdrawn** (no longer applies —
none is). Severities:
critical, high, medium, low.

**Findings are grouped by state first, then by series.** Open findings are in
full, ahead of everything else; resolved ones follow in `B`, `S`, `C`, `A`
order, each series behind an index table.

Compression rule: a closed finding whose reasoning is spent is one line. A closed
finding whose reasoning is load-bearing keeps a **Keep** paragraph, because
someone could otherwise undo it by accident — and a `Keep` never states a rule
without the finding id it came from. They are identified by the `**Keep —`
marker in this document and are **not listed anywhere else**: a list of them goes
stale silently and then licenses the deletion of the ones it missed. Nothing has
ever been renumbered and nothing dropped.

## Status

| Series | Total | Resolved | Open | Won't fix |
|---|---|---|---|---|
| `B` bugs | 7 | 7 | 0 | 0 |
| `S` sandbox and security | 1 | 1 | 0 | 0 |
| `C` compliance and packaging | 8 | 8 | 0 | 0 |
| `A` architecture and performance | 6 | 3 | 1 | 2 |
| **Total** | **22** | **19** | **1** | **2** |

**No open finding is critical or high, and the `C` series has none left.** `A7`
is medium and is the only one open. Both **won't fix** entries in this document
are medium and are decisions rather than debt: `A20`, the first, and `A8`,
decided 2026-09-09.

| Id | Sev | State | What | Waiting on |
|---|---|---|---|---|
| `A7` | medium | open | `cc_day` duplicates a sky block `codeblock` also runs | adopting a release at or past their `6fea453`. **`L3`'s half is now done** — it passes at the adopted `fb75bc8` on 2026-09-09, so `cc_day` is sufficient alone. **Settled upstream on different terms than predicted** — a setting off by default, not a deletion. Nothing is written in this repository for it, and the flag must not be set |

**`A8` is won't fix as of 2026-09-09, and is waiting on nothing.** The author
decided the every-node walk stays: *the case of another mod in this game is not
actual*. Its drop-chain half is confirmed by `R2` at `dd83b99`, on the current
tree. No source changed for the decision.

**`A20` is won't fix as of 2026-09-09, and is waiting on nothing.** The condition
is real and permanent — nothing in the game is hand-diggable — the author declined
the only fix on the merits, and the obligation the finding created is discharged:
`R1` ran falsifiably under the temporary hand override and passed. It is in full
below, beside `A7` and `A8`, because it is not resolved and a reader needs
its standing cost. Do not report it as outstanding work.

**Two findings are resolved in code and unverified in a world**, which is a
weaker state than resolved and is tracked here because nothing else tracks it.
The game has no test suite, so a `PLAYTEST.md` result line is the only thing that
closes the gap. Both are committed. **`B48` left this table on 2026-09-09**,
closed by `R8`; **`A13` and `A19` left it the same day**, closed by `R9` and by
`L4`.

| Id | Resolved in | Unverified until |
|---|---|---|
| `B19` | `e51f969` | `P3` |
| `B24` | `e51f969` | `P3` |

**One playtest sitting closes both** — `P3` takes `B19` and `B24` together, and
it is the boot log. `R4` is still owed a re-run for the reason `R8` was, `B48`'s
fix rewriting `groups` on every registered node, and a partial strip is what it
would catch; it is the last of the `R` group's re-runs and no finding's state
rests on it. `PLAYTEST.md` holds the list of what needs action; it is not
restated here.

## Where it stands

**`C21` is resolved on 2026-09-09 by a re-pin, and it is the only finding here
closed without a line of this repository changing.** `mods/vector3` moved from
`v1.5` (`16621648`) to `v2.0.2` (`fc8a5b8`), whose `mod.conf` is four lines and
carries `min_minetest_version = 5.3` and no ceiling at all. That is the route the
finding itself named — upstream or a re-pin — and it closes the `C` series. **No
gate in this repository ever saw the defect and none sees it gone**: the
`max_minetest_version` guard at `scripts/check_game.sh:34` reads `game.conf`
alone and has never read a `mod.conf`, so the evidence is the pointer and the
file rather than a green run. Both gates were green at `c7c2c43` with the pointer
staged, which says the game still assembles and nothing more. Extending the guard
to every bundled `mod.conf` would have caught this and is a `TODO.md` line, not a
finding.

**`A20` was filed and closed as won't fix on 2026-09-09, and it cost this project
evidence rather than behaviour.** `A13`'s deletion of `mods/default` removed the
only thing that gave the hand any groupcaps, so **no node in this game is
hand-diggable, with or without `cc_security`**. That was traced read-only through
the engine at both 5.9.0 and 5.17.0, and **it is now confirmed in a world**: `R2`
ran its drop half under the temporary hand override at `dd83b99` and dug, where
without the override nothing could be dug at all. The consequence was that
`PLAYTEST.md` `R1`, *nothing is diggable*, **would have passed with `cc_security`
deleted outright**; the override makes it falsifiable and it passed on
2026-09-09. The restriction itself stays: `A20` records four paths on which
`diggable = false` and the group strip are still what refuses, and it **does not
weaken `A8`**. What it leaves behind is a standing setup cost on `R1`, `R4` and
`R8`, not open work.

**`A19` was filed, fixed and verified on 2026-09-09, and its stated cause was
wrong.** One `set_sky{type = "plain", base_color = "#90d3f6"}` in `cc_day`,
committed at `dd83b99`. The finding blamed unpinned `sky_color` entries; the
engine says the day branch was the only one ever selected and the mover was
`m_horizon_blend`, which no colour table can hold still. The wrong reading is
kept beside the corrected one in the finding, because it is the natural one. It
also turned out to cost more than the finding claimed: **every fresh world sat
permanently in a sunrise-tinted blend**, and the horizon moved as the player
turned. `L4` passed on the fix, engine 5.17.0, which is the whole of its in-world
evidence; `L1`, `L2` and `L3` are behind it.

**`B50` is resolved, and it is the one finding here closed by evidence rather
than by a commit.** Falling out of the world had **two routes**: the generated
edge, and a hole a program carves in the floor. Both are shut — a bedrock plane
at `y = 0` with air beneath, a full-height wall at the outermost generated
column, and a `cc_security` globalstep that puts a player found outside the box
back into their own column — committed at `f5f2385` with the rescue's destination
reversed at `60259dd`. **What closed it is `PLAYTEST.md` `W4`–`W9`, all six
passing at `60259dd`.** Route one had never been walked to at all and rests
entirely on `W5`; route two had passed at `f5f2385` and lost that evidence when
`60259dd` replaced the destination it described. Both are now observed.

**Three defects were found in uncommitted code while building `G6` and `G7`, and
none carries an id.** The `y = 1` spawn fallback inside solid stone, the rescue
looping at the spawn column, and — on 2026-09-07 — `cc_security` deriving both
its fallback and its scan bound from `(ground or 8)` after the game's default
became 128, which would have put a rescued player at `y = 9` inside a hundred and
twenty nodes of stone. **What gets an id is a defect in committed code**; a
change that is wrong before it lands is the change being wrong, and its record is
the `ROADMAP.md` entry — `G6` for the first two, `G7` for the third. `W14` cases
2 and 3 are what would have caught the third in a world, which is why that check
asks pointedly about the number 9, and **both passed at `3479e25` on 2026-09-08**
— no 8 and no 9 anywhere, so the single `or 128` is right in a world and not only
in the diff. The rescue's reversal at `60259dd` is not a
defect either: it is what the author asked for after playing.

**`C22` is resolved on 2026-09-08, one day after it was filed, and it was the
only finding here that had been true since the project began.** The author
decided the split — **code stays AGPL-3.0-only, all of the game's own media is
CC BY-SA 4.0** — and it is written into a new `menu/license.txt`, both media rows
of `THIRD-PARTY-LICENSES.md`, and a `media_license` field in
`scripts/gen_cdb_json.sh`. The decision is `ROADMAP.md` `G7`, *The media licence*. What
the closure does **not** cover is that nothing enforces it: a media file added
tomorrow with no licence line fails no gate, which is `C15`'s standing hazard in
a second form — see `C22`'s `Keep`.

**Two findings changed shape on 2026-09-08, when the working tree's
`mods/codeblock` was moved to upstream `fb75bc8` to test a bump ahead of
CodeBlock's 1.0.0, and both changed differently from what this document
predicted.** `A13`'s deferral **ended**: CodeBlock registers its own 105 nodes and
depends on `vector3` alone, which is the condition the deferral named, so the
answer is deleting `mods/default`, `mods/dye` and `mods/wool` outright rather than
trimming — and the deletion drags the engine's three essential mapgen aliases and
the world's surface material with it. `A7` was **not** resolved the way this
document said it would be: the duplicate sky block was put behind a setting that
is off by default, not deleted, and the consequence is that **this game must not
set that setting**. Both entries carry the correction where they stand.
**`A13` is now resolved, at `50fd05f` the same day, and unverified in a world**;
`A7` closes at adoption.

`C21` was the other finding new on 2026-09-07, from shaping the same feature: a
version ceiling in a bundled submodule, and the only one here the game could not
fix in its own tree. It is resolved — see the top of this section. `A13` no longer
carries `B19` and `B24`: both were closed directly on 2026-09-02, which was the
point of looking at them, since "resolved for free by `A13`" had kept two
boot-log defects invisible behind a deferred item. `A8`'s drop chain is confirmed
and its table walk is won't fix, decided 2026-09-09.

**`B49` is resolved and confirmed.** Its fix rests on undocumented behaviour —
replacing an ABM's `action`, because Luanti cannot unregister one — so `R7` was
the only thing that could say whether it works, and it passed on 2026-09-02.
`S8` and `B47` were fixed and confirmed the day before, by `R6` and `L1`.
**`B48` is fixed and confirmed, since 2026-09-09**: the stripped digging groups
were committed on their own at `ec02760`, split out of `G6` so the `G4` fix stands
separately and `R8` had a sha to be run against, and `R8` passed against it — no
crack texture and no dig sound under a held punch. The question the filing left
open was already answered from the documented API before that: `core.get_dig_params`
never sees `diggable`, so the fix had to come from the groups and no other reading
of the defect survives. What the run adds is that the strip works on the client,
which no reading could say.

**Three of the 22 arrived on 2026-09-01, from the first hours anyone has
spent playing this game against `PLAYTEST.md`** — `B47`, `B48` and `S8`. None was
visible from reading the three `cc_*` files, **which between them were 21 lines
at the time** and are **591** now across four files, since `G6`, the rescue
rewrite, the barrier node, the world's new depth and `G3`'s ground; two of the
three are in how
those lines meet a vendored node or the client. That is the argument for the `W`,
`L` and `R` groups, and it is now evidence rather than an assertion.

**Re-running a check against its own fix is the other thing that day
established.** `L1` re-run cleared a blocker that had been predicted for `B47`
and did not exist. `R6` re-run found that the first `S8` fix had closed the wrong
half, and would have been marked pass on the strength of the fix alone; a second
re-run, with `R4` beside it, is what closed it properly. Neither outcome was
available from the code. **A fix is not evidence** — the check is, and it costs
minutes.

**Where the repository stands.** `C15` landed in `8d18e8b`; `C20` is the only
finding here to arrive from reading a published rule rather than from a defect,
and was filed and fixed in one change at `9ad884c`. The adopted `codeblock`
pointer is `fb75bc8` since `50fd05f`, which is **a commit off `master` and not a
tagged release** — see `ROADMAP.md` `G5`, which is where it is put back on the
release track. It moved because `A13` forced it: the previous pointer hard depends
on `default` and `wool`, so the deletion and the old pointer together leave a
fresh clone failing `check_game.sh`.

**Two corrections to what this document said about the remote, both read from git
and the Actions API on 2026-09-08.** The branch is **not unpushed**:
`origin/g6-world-limits` exists and is at `5777dc0`, so `50fd05f` and `dd83b99`
are the only local-only commits. **A third correction, 2026-09-09**: the branch
carries **14** commits over `main`, not the 23 written here and in `ROADMAP.md`
for two passes — `git rev-list --count main..HEAD`, with `main` at `578b364`. And **CI's most recent run is not on
`578b364`** — that commit was never pushed either. The newest run of any kind is
`main` at `35fa2a1`, **success**, 2026-09-01, and **no commit on
`g6-world-limits` has a run at all**, so nothing on this branch has been checked
by anything but a local shell.

**The game boots from the author's own checkout, and the boot gap is narrower
rather than closed.** `W10` and `W12`–`W14` pass at `3479e25`, record-only over
`48cc63e`, and none of those observations is possible without booting and entering
a world.
What is still unrun is `P1`'s boot half — a **fresh recursive clone**, whose
submodule objects nobody has locally, which is the case that catches a pointer
nobody can fetch — and `P3`, so `B19` and `B24` above are still waiting on a boot
log nobody has read.

## Open findings

In full, and they are the reason to read this document. `A7` is the only one open,
and it is medium; nothing here is critical or high. **`A8` and `A20` sit here too
and are won't fix**, because a decision taken against a real condition has to be
as readable as an open item or it gets re-argued — each state is in its own
heading and neither is counted as open anywhere.

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

**Nothing is written in this repository for it.** `cc_day` is already what this
side should look like — it is the copy that survives, and no `cc_*` file changes.
The game's half was adopting the release that settles it and then running `L3`,
which is why this finding stays open here after the upstream edit lands and closes
only at adoption.

**`L3` is done, 2026-09-09, so adoption is the only thing left.** It passed at
`50fd05f`, whose adopted `mods/codeblock` is `fb75bc8`, engine 5.17.0:
with `codeblock.config.flat_sky` off and this game not setting it, there is no
sun, no moon, no stars and **no sunrise** — so `cc_day` is sufficient on its own,
`sunrise_visible = false` included. A rejoin was in the same sitting, so the
re-application half is covered. The finding stays open because the duplicate is
still in the mod's source at a pointer this game has not adopted; the check that
was gating it is no longer what holds it. The residual that sitting found is a
separate defect, `A19`, and not this one.

**Corrected 2026-09-08: the prediction above was wrong in mechanism and right in
outcome.** This finding said the duplicate would be **deleted** upstream. It was
not. At `fb75bc8` `codeblock lib/register.lua:243-252` still calls all five sky
methods, now guarded by `codeblock.config.flat_sky` — a setting **off by
default**, which is their finding `C18`, resolved at their `6fea453`. So the
duplicate still exists in the mod's source and simply does not run. Recorded
rather than overwritten: a claim silently changed is one the next reader
re-derives.

**Keep — the game must not set `codeblock_flat_sky = true`, and upstream's own
documents ask it to.** Both CodeBlock's `ROADMAP.md` and its `CHANGELOG.md`
instruct a game bundling the mod to set the flag. Following that instruction would
**restore the exact duplicate this finding exists to remove, in the worse of the
two versions**: `cc_day` calls
`set_sun{visible = false, sunrise_visible = false}` — the `B47` fix — and the
mod's copy still calls a bare `set_sun{visible = false}`. The flag being off by
default is what makes `cc_day` sufficient and costs the game nothing. The decision
and *what would change it* are `ROADMAP.md`, under *deliberately not doing*.

**Corrected 2026-09-02: "identical arguments" above was wrong.** `codeblock` calls
a bare `set_sun{visible = false}`; `cc_day` calls
`set_sun{visible = false, sunrise_visible = false}` — the `B47` fix. The
difference does not make the removal urgent, and `B47`'s **Keep** is where that is
settled: `L1` passes with the duplicate still in place, and removing a call cannot
reintroduce the texture whichever way `set_sun` treats an omitted field. Recorded
here only so the next reader does not re-derive it from the claim that the two
calls match.

### A8 · medium · won't fix — decided 2026-09-09: the every-node walk stays; the drop chain is confirmed and `last_mod` untested by choice

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

**And confirmed again on the current tree, 2026-09-09 — the unrepeatable half of
this finding is repeatable again.** `R2` passed both halves at `dd83b99`, engine
5.17.0, its drop half run under `A20`'s temporary hand override and no item
appearing. That is the first time the drop chain has been exercised since
`7dc764f`, and the first ever under the corrected method. `R5` composes to a pass
with `R3`'s re-run beside it, so both halves of this fix now name the same
tree. **`last_mod` stays untested by choice** — the paragraph below is unchanged
by any of it, and no sitting can change it while no second mod ships. What was
not read back is the pass observation itself, the hotbar slot and the dug
position.

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

**The other half of this finding is the table walk, and it is decided rather
than fixed.** The mod overrides **every registered node** at `on_mods_loaded` to
set `diggable = false` — a large table walk to express one rule. It has to run
there to see every mod's registrations (moving it earlier silently covers fewer
nodes and nothing fails). **Decided by the author on 2026-09-09, in their
words: the case of another mod in this game is not actual.** The walk stays as it
is; nothing in `mods/` changed for the decision. The code is not being defended
as elegant — the scenario the concern rested on is not real here, so the cost of
replacing it buys nothing.

**And the walk survives the digging question regardless, which is the stronger
reason.** Read from the offline 5.17.0 API reference on 2026-09-09 — a reading of
the reference, not a run and not a world check:

- The one single-point alternative is `core.node_dig`, the overridable default
  for a node definition's `on_dig`. It could refuse every dig from one function,
  protected by `last_mod` exactly as the drop chain already is. But it covers
  only the digging job, a node declaring its own `on_dig` bypasses it entirely,
  and it does nothing about the client-side dig prediction, so `B48`'s group
  strip would still need a per-node pass. It was **not exhaustively ruled out**;
  the author's decision made it moot.
- The loop's other four jobs have no game-wide equivalent at all.
  `register_allow_player_inventory_action` governs the player's own inventory
  only and there is no counterpart for a node's metadata inventory, and node
  timers have no global switch. So the walk would remain even if digging moved
  to `core.node_dig`.

**The walk got wider on 2026-09-07**, when `B48`'s fix added an inner `pairs`
over each node's `groups` and a rebuilt table per node. It is the same one pass,
so the cost is still paid once at load — but a walk that now *writes* `groups` on
every registered node has a larger blast radius than one setting `diggable`, and
that is why `R1`, `R4` and `R6` are all marked for re-running.

**And much shorter on 2026-09-08, which changes the cost and not the question.**
`A13`'s deletion takes roughly 120 `default` and `wool` node definitions out of
`minetest.registered_nodes`, leaving CodeBlock's 105, the two drone tools and
`cc_mapgen`'s four. The walk is still a walk over every registered node to express
one rule; what goes is the argument that it is expensive. `R6` also stops being one of the re-runs, because it becomes
unrunnable — `R1`, `R4` and the new `R9` are the blast-radius checks now.

**`A20` does not weaken this finding, 2026-09-09.** That no hand in the game can
dig anything makes the table walk *unobservable*, exactly as the paragraph above
says `last_mod` is, and unobservable is not redundant: `A20` lists four paths on
which `diggable = false` and the group strip are still the only refusal. What
`A20` does change is the evidence — the drop-chain confirmation below ran at
`7dc764f`, when `mods/default` still gave the hand its groupcaps, and it **cannot
be repeated** without the temporary hand override `A20` describes. The
2026-09-02 pass stands: a run at its own commit is not retroactively invalidated.

### A20 · medium · won't fix — `A13`'s deletion took the hand's groupcaps with it, so nothing is hand-diggable and the digging restriction is unfalsifiable without a setup

`mods/cc_security/init.lua` · deleted `mods/default/tools.lua` · `PLAYTEST.md`
`R1`, `R2`

**Traced read-only from source on 2026-09-09, and the diagnosis is now confirmed
in a world the same day.** The engine was read at **both 5.9.0, this game's
floor, and 5.17.0**, and the adopted `mods/codeblock` at `fb75bc8`; nothing was
edited and no gate was run for the trace, so every claim about the engine's
internals below is a reading of source. It was found because `R2`'s drop half
refused twice with its method correctly set up. **What was traced is what
happened**: at `dd83b99`, engine 5.17.0, `R2`'s drop half dug and passed *with*
the temporary hand override in place, having been undiggable without it — so the
hand's empty groupcaps are the cause and not a hypothesis about one.

**The refusal has two layers, and the second is the one that matters.**

- **First, the wielded tool.** On join `codeblock` puts `codeblock:poser` and
  `codeblock:setter` in the first two `main` slots
  (`mods/codeblock/lib/register.lua:44-67`), and slot 1 is the default wield
  index. Both are registered with `on_use` and **no `tool_capabilities`**
  (`register.lua:107`, `:140`), so `selected_def.usable` is true and the client
  takes `if (selected_def.usable && isKeyDown(KeyType::DIG))` →
  `client->interact(INTERACT_USE, pointed)` (`src/client/game.cpp:3413` at 5.9.0,
  `:2793` at 5.17.0). `handlePointingAtNode` is never called: **left-clicking a
  node with the poser wielded runs the player's program instead of digging.** On
  its own this could account for the whole sitting.
- **Second, and the real one: the hand has no groupcaps.** The engine's builtin
  hand is registered with no `tool_capabilities` at all
  (`builtin/game/register.lua:400` at 5.9.0, `:448` at 5.17.0).
  `read_item_definition` gives it a default-constructed `ToolCapabilities` with
  **empty `groupcaps`** (`src/script/common/c_content.cpp:112` / `:145`;
  `src/tool.h:68-80`), and `getDigParams` leaves `result_diggable = false` when
  `groupcaps` is empty (`src/tool.cpp:373-426` / `:367`). Client-side
  `dig_time_complete` becomes `10000000.0`, `INTERACT_DIGGING_COMPLETED` is never
  sent, and `// Don't show cracks if not diggable` (`game.cpp:3330-3331` at
  5.17.0) suppresses even the crack overlay; the dig sound is gated on
  `params.diggable` too. The symptom is exactly *"nothing happens at all"*.

**No node in this game is hand-diggable, by any player, with or without
`cc_security`.** The single escape from empty groupcaps is `dig_immediate` 2/3,
special-cased ahead of the groupcaps loop (`tool.cpp:379-388`) — and
`cc_security` strips that group (`B48`), so that door is shut too.

**What changed.** `git show 7dc764f:mods/default/tools.lua` line 8 did
`minetest.override_item("", {… groupcaps = {… oddly_breakable_by_hand = {times =
{[1] = 3.50, [2] = 2.00, [3] = 0.70}, uses = 0}}})`. That is what let a hand break
`oddly_breakable_by_hand` 2 and 3, and it is why `R2`'s drop half ran at all on
2026-09-02 at `7dc764f`. `50fd05f` deleted `mods/default` under `A13` / `G3` and
nothing replaced it: `override_item` now appears only at
`mods/cc_security/init.lua:69`, and there is **no `register_item`, no hand
override and no CSM anywhere in the tree**.

**What is not refusing, each checked rather than assumed.** `codeblock` refuses
nothing — no `is_protected`, no `register_on_protection_violation`, no `can_dig`,
no `diggable`, no `on_dig`, no `register_on_dignode`; its only `on_punch` is on
the drone entity (`lib/drone_entity.lua:64`), and its nodes carry `cracky = 3`
with `oddly_breakable_by_hand` 2 or 3 (`lib/nodes.lua:52`, `:70`, `:86`). Nothing
else in `cc_security` blocks a dig either: `deny`/`never` reach only node timers
and metadata inventories (`init.lua:72-75`), the inventory-action guard (`:23`)
covers player-initiated actions only, and the `handle_node_drops` chain
(`:92-96`) and `calculate_knockback` (`:98`) are downstream of the refusal. Nor
the server: its own `getDigParams` re-check would refuse with `dug_unbreakable`
(`src/network/serverpackethandler.cpp:1174-1181` at 5.9.0) but is gated on
`enable_anticheat && !isSingleplayer()` (`:1145`), so singleplayer skips it — the
packet simply never arrives.

**`A` and not `B`, medium and not high.** The cause is an architecture decision —
`A13`'s deletion — and what it costs is *evidence*: `PLAYTEST.md` `R1` would pass
with `cc_security` deleted outright, so the game's headline restriction reads
green while nothing checks it. Medium because that is the loss of the only
evidence for the game's central promise; not high because **nothing a player can
reach is worse than before** — every node was already undiggable, and a left-click
now does nothing at all instead of playing an animation and being refused.

**Do not call the restriction redundant and do not remove it.** `diggable = false`
and the group strip still hold four live paths:

- a node carrying `dig_immediate` 2 or 3, from a future CodeBlock release or a
  server owner's mod, which bypasses empty groupcaps entirely;
- any mod a server owner installs that **overrides the hand**;
- any mod that adds a **tool with groupcaps**;
- `core.dig_node` called from any other mod.

Defence in depth, not duplication.

**The author's decision, 2026-09-09, and not to be re-litigated: the game will
not ship its own hand definition.** A left-click today gives no crack, no sound
and no message, which is *truer* feedback than the old misleading animation;
registering a hand would restore the feedback **and** the misleading crack, which
is what `B48` was filed to remove. The accepted cost is that `R1` and `R2` need a
temporary override to be runnable at all. See `ROADMAP.md` *deliberately not
doing*, under the shape of the world.

**Won't fix, and not open — decided 2026-09-09.** Three facts settle the state
and each points the same way. The condition is **real**: nothing in the game is
hand-diggable, and that is a consequence of `A13` nobody costed. The condition is
**permanent and accepted**: the only fix is a hand definition, the author declined
it on the merits the day this was filed, and *deliberately not doing* in
`ROADMAP.md` records the grounds. And the obligation this finding created is
**discharged**: `R1` and `R2` were run on 2026-09-09 at `dd83b99` with the
temporary hand override in place, `R1` falsifiably for the first time in the
project, and `R5` closed with them. So there is nothing left to do and nothing
left to wait for, which is what disqualifies *open*; and the defect has not gone
away, which is what disqualifies *resolved*. **Won't fix is the only state that
says both.**

**What it costs from here, and it is a setup and not a task.** Every future run
of `R1`, `R4` or `R8` needs the temporary hand override from `PLAYTEST.md`'s `R`
preamble, or it exercises nothing — three things to undo afterwards, and the
2026-09-09 sitting is corroborated as having done exactly that, because the
committed tree at `dd83b99` has both `cc_security` lines restored and no
`override_item("", …)` left in it. **Do not re-derive this as an open finding**
and do not propose the hand definition again: `B48` returns with it, which is one
of the grounds on which it was declined.

## Resolved — B bugs

**7 findings, all 7 resolved, and the `B` series has no open finding left.**
`B50` closed on 2026-09-07 when `W4`–`W9` all passed at `60259dd` and both of its
routes became observed. Two are resolved but **unverified in a world**: `B19`
and `B24`, both waiting on `P3`. `B48` left that state on 2026-09-09, when `R8`
passed.

| Id | Sev | Was | Fixed by | Where it stands |
|---|---|---|---|---|
| `B50` | medium | a player could fall out of the world, by two routes | a bedrock floor at `y = 0`, a full-height wall at the generated edge, and a `cc_security` rescue into the player's own column | `f5f2385` and `60259dd`; closed by `W4`–`W9` at `60259dd` |
| `B49` | medium | `default`'s ABMs and saplings rewrote what a program had built | every ABM's `action` and every node's `on_timer` replaced, in `cc_security` | confirmed by `R7`, 2026-09-02 |
| `B48` | low | wool played the dig animation before the server refused | six digging groups stripped from every node's `groups` | `ec02760`; confirmed by `R8`, 2026-09-09 |
| `B47` | low | the sunrise glow was still drawn, so part of the sun showed at dawn | `set_sun{sunrise_visible = false}` | confirmed by `L1`, 2026-09-01 |
| `B24` | low | vendored `default` used a deprecated `TileDef.image` field | renamed to `name`, one token | `e51f969`; **unverified**, `P3` |
| `B19` | low | five `NodeResolver` errors on every world load | two `flowers:*` aliases of `air` in `cc_mapgen` | `e51f969`; **unverified**, `P3` |
| `B20` | low | every deprecation warning in the boot came from `mods/formspecs` | the mod removed | — |

The entries below are the ones whose reasoning is load-bearing: `B50` for its
five **Keep** paragraphs, `B19` and `B24` because a re-vendored `default` would
bring both back, `B48` because the six stripped groups are a set someone could
narrow by accident, and `B47` because the prediction it got wrong is the reusable
part. The `B` resolved count **said 5 until 2026-09-07**, while the table above
already said 6; the body was the one that was wrong, `B20` having been left out
of it.

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
that both limits are things a player can see before reaching them.

**Keep — the world's size costs no mod load-order dependency, and that is why it
is one setting rather than a handshake.** `mapgen_limit` lives in the game's
`minetest.conf`, which the engine reads into `core.settings` **before any mod
runs**, so CodeBlock reading the same key for the drone's bound cannot race
`cc_mapgen` writing it. Nothing here passes the number to the mod and nothing
should start: a game-side second number, or any load-order arrangement that made
one mod tell another, is exactly what `G6` decision 2 refused. `W6` is the only
thing that proves the two bounds are one number rather than two that agree. For route two
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

**`A13`'s deletion removes the defect at its source and leaves this fix
unexercised, 2026-09-08.** The six ABMs and the ten sapling `on_timer`s were all
`default`'s; CodeBlock's 105 nodes register neither, and neither do `cc_day`,
`cc_mapgen` or `cc_security`. So after the deletion the two loops in
`cc_security` walk empty sets. The finding stays resolved — nothing reopens — but
**`R7` becomes unrunnable**, its three cases naming `dirt`, `dirt_with_grass`,
`grass_3` and a sapling, none of which will exist. Its pass at `d16f9bb` stands as
what was seen. Whether the loops are kept as defence against a worldmod or
deleted as dead code is `code-expert`'s call and is a `TODO.md` line, not a
finding.

### B48 · low · resolved, `R8` passes — wool plays the dig animation before the server refuses

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
- **`del_fields` is not the answer here, and the reason changed on 2026-09-07.**
  It was ruled out for being unavailable: it arrived in 5.9.0 and `game.conf`
  declared `min_minetest_version = 5.4`. **`G6` raised that floor to 5.9**, so
  availability is no longer the objection — the remaining one is that it deletes
  *top-level* fields rather than keys inside `groups`, which is the wrong
  operation for this fix whatever engine is running. `S8` carries the same
  correction for callbacks, where availability *was* the whole objection.

Nothing else here reads node groups: `codeblock` does not (its `api.groups` is a
documentation grouping of API entries, not node groups), and neither
`codeblock:poser` nor `codeblock:setter` declares `tool_capabilities`.

**`A13`'s deletion changes what this fix is applied to, and `R8` was written
against nodes that will not exist, 2026-09-08.** The defect stays live: CodeBlock's
own 105 nodes carry `cracky = 3` and `oddly_breakable_by_hand = 2` or `3`
(`lib/nodes.lua` at `fb75bc8`), so the client still predicts a dig on every block
a program can place and the strip is still what stops it. Two things do change.
**No `dig_immediate` node is left in the game** — the dozen that carried it were
`default`'s — so the instant-crack case, which the `Keep` above calls the one a
partial strip would still show, cannot be reproduced any more. And **the hand's
own groupcaps no longer come from `mods/default/tools.lua`**: with no game item
overriding it, the hand is the engine's default. `R8`'s method is rewritten around
`codeblock:*` and the new surface node; the change is to the check, so it carries
no id.

**Closed on 2026-09-09 by `R8`, and that result line is the whole of the
evidence.** `PLAYTEST.md` `R8` passed on the tree committed as `dd83b99`,
on engine 5.17.0: **no cracking texture at any stage and no dig sound**,
on a solid `codeblock` block, a glass one, and `cc_mapgen:grass` with the barrier
as the control. Until then the claim that the client stops predicting a dig rested
on reading the `groups` rebuild, and both gates say nothing about it — neither
runs a line of the game's Lua.

**Two limits of that closure, carried here rather than left in the check.** The
report was the single word *pass*, so nothing was read back about which subject
was watched or for how long; the pass is against the method as written, which asks
for a full two seconds each with sound on, rather than against a per-subject
account. And the **instant-crack case is gone from the game for good**: `G3`
deleted the last `dig_immediate` node, so the fastest case — the one the `Keep`
above names as what a partial strip would still show — cannot be reproduced by any
future run. So this is closed on a held punch against three surviving subjects,
not on the full set the fix was written for.

**This defect is now moot rather than held off by the fix that records it —
`A20`, 2026-09-09 — and `B48` is not being reopened.** With the hand's groupcaps
gone since `G3`, the client suppresses the crack overlay outright for a node no
hand can dig (`// Don't show cracks if not diggable`, `game.cpp:3330-3331` at
5.17.0), and the dig sound with it. So `G3` completed `B48` by accident, and
**`R8`'s pass has a second explanation**: the group strip, and the empty
groupcaps, which would have produced the same screen and the same silence on
their own. The state stays resolved — `R8` was closed on it today, the fix is
correct and nothing contradicts it; what is recorded is that the pass no longer
distinguishes the two causes. **If the game ever ships a hand definition this
defect returns, and the group strip is the only thing that would hold it** —
which is one of the grounds on which `A20` records that hand definition as
declined.

**And the run that would separate them was not done, 2026-09-09.** `R8` was
**not** re-run with `A20`'s temporary hand override in place, even though the
override was set up in the same sitting for `R1` and `R2`. A run with a hand that
*could* dig is the only thing that would show the group strip refusing on its
own, so until someone does it **`B48` cannot be separated from `A20`** and its
pass has two live explanations. Not a reason to reopen it: the fix is correct by
reading and the defect is unreachable either way. It is a reason not to write
that `R8` proves the strip works on the client.

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

**Keep — `sunrise_visible = false` is no longer observable in any world, and
this finding's evidence is frozen (`B47`, `A19`).** `A19`'s `plain` sky draws **no
sky mesh at all**, so there is nothing for a sunrise glow to be painted on: no
future run can distinguish this fix working from the sky type hiding it, whatever
`set_sun` is passed. The only evidence that ever existed is `L1`'s pass at
`b9bf82b` and `L3`'s retained 2026-09-01 `partial`, both taken under a
`"regular"` sky, which is why that retained line is kept rather than tidied. The
call itself **stays in `cc_day`** for the reason `A19`'s own `Keep` gives: a
future return to `"regular"` must not silently restore the sunrise.

**It is not.** `L1` re-run at `b9bf82b` passes with the duplicate still in place.
Either `set_sun` merges with the current parameters or `cc_day`'s callback runs
second; the outcome does not distinguish them and it does not need to, because
removing a call cannot reintroduce the texture either way. The reusable part is
the method: the ambiguity was written down as unverified rather than resolved by
reading the reference a second time, and one re-run settled it in a minute.

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

**`A13`'s deletion takes the schematics with it, 2026-09-08.** The four `.mts`
files are `default`'s, so nothing will name `flowers:mushroom_brown` or
`flowers:mushroom_red` any more and the two aliases become unnecessary. Removing
them is `code-expert`'s call and a `TODO.md` line. Resolved either way; `P3` is
still the check, and it now also covers the aliases the deletion **adds** —
`mapgen_stone` and the two water ones, whose absence is a boot-time error of
exactly the shape this finding was about.

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

**`A13`'s deletion deletes the fix along with the file, 2026-09-08.** Both
warnings came from `mods/default/furnace.lua:354` and from `cc_security`
re-processing that one definition, so the whole cause goes. Resolved and now
unreachable rather than merely fixed; the sentence above is the one that survives,
because a re-vendored `default` would still bring it back.

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

## Resolved — S sandbox and security

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

**Overtaken on 2026-09-08: `A13` is a deletion and it does take the bookshelf.**
The palette is now CodeBlock's own 105 nodes and none of them carries a formspec,
so after the deletion no node in the game has one and **the residue below —
a panel that still opens — disappears**. The fix stays: it is the mod's own
inventory guard and it is what holds the *player's* boundary, which no node
deletion touches. **`R6` becomes unrunnable**, its method naming
`default:bookshelf`; its pass at `c042364` stands as what was seen. The paragraph
above is kept because it is the reasoning that made the fix necessary, and it was
correct while the trim was the question.

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

**Note for any wider fix, and it was reversed on 2026-09-07.** `del_fields` on
`override_item` arrived in 5.9.0, and this note said removing a callback outright
was therefore unavailable because `game.conf` declared
`min_minetest_version = 5.4`. **`G6` raised that floor to 5.9**, so `del_fields`
*is* available now and a wider fix has an option it did not have when this was
written. Nothing has been rewritten on the strength of it: the fix in place
works, and the residue below is a metadata string `del_fields` does not reach
either. Recorded rather than deleted, because the constraint is quoted in `B48`
as well and a reader meeting it twice should meet the correction twice.

## Resolved — C compliance and packaging

**8 findings, all 8 resolved, and the `C` series has no open finding left.**
`C21` closed on 2026-09-09, the last of them.

| Id | Sev | Was | Fixed by | Where it stands |
|---|---|---|---|---|
| `C21` | low | a bundled submodule carried the version ceiling this game's own check forbids | adopting `vector3` `v2.0.2`, which declares `min_minetest_version = 5.3` and no ceiling | the pointer move to `fc8a5b8`, 2026-09-09; **no gate here ever read it**, so the evidence is the file and not a run |
| `C22` | low | three menu images shipped to every player with no licence stated anywhere | a new `menu/license.txt`, two media rows in `THIRD-PARTY-LICENSES.md`, and `media_license` in the generator | `48cc63e`; `menu/license.txt` confirmed shipped by `P2` there; **not enforced by any gate** |
| `C20` | medium | the ContentDB long description was `README.md` verbatim, breaking six of ContentDB's page rules | `CONTENTDB.md` written for its own reader, and the generator repointed at it | `9ad884c`; **unseen**, `P5` needs a release |
| `C15` | low | the release archive shipped `.claude/`, the record documents and the art sources | `.* export-ignore` plus rules by name | `8d18e8b`; confirmed by `P2` at `8b27f2f`, re-confirmed at `48cc63e` |
| `C5` | medium | the three `cc_*` mods had no licence file | a `license.txt` each, enforced by `check_game.sh` | — |
| `C4` | medium | licence metadata disagreed between the game and the mod inside it | unified on AGPL-3.0-only | — |
| `C3` | medium | bundled AGPL and MIT code shipped without its licence text | the text, or a `THIRD-PARTY-LICENSES.md` row, enforced by `check_game.sh` | — |
| `C2` | low | image URLs named `master` on a repository that has only `main` | repointed to `main` | the filing itself was wrong; see below |

`C1` is not in this document: it is the same defect in the mod's `mod.conf` and
belongs to the mod's audit.

- **C21 · low · resolved** — `mods/vector3/mod.conf` carried
  `max_minetest_version = 5.5` beside `min_minetest_version = 5.3`, **four minor
  versions** below the `min_minetest_version = 5.9` `G6` gave this game, so the
  game advertised a floor its own hard dependency advertised as out of range —
  the shape `C4` was filed for, and the same defect `C1` was in `game.conf`. Low
  because the engine reads only `depends` and `optional_depends` out of a
  `mod.conf` (5.17.0 reference), so it constrained what the *package page* claims
  and never what the engine would start. **Resolved 2026-09-09 by adopting
  `vector3` `v2.0.2`** — `mods/vector3` moved from `v1.5` (`16621648`) to
  `fc8a5b8` on the author's instruction, *"vector3 should be v2.0.2 now and
  should only state `min_minetest_version = 5.3` so it does not block
  anything"*, and the release's `mod.conf` is exactly that: `name`, `title`,
  `description`, `min_minetest_version = 5.3`, no ceiling. Nothing in this
  repository changed. `mods/codeblock/mod.conf` still says 5.4, which is the
  other half of the same picture and is upstream's call. The 5.7-to-5.9
  correction this finding took the day it was filed is under *the corrections*
  and in `ROADMAP.md` `G6` decision 4.

  **Keep — never hand-edit a submodule's `mod.conf`, and no gate here reads
  one.** Two rules came out of `C21` and both outlive it. First, the fix for a
  defect inside a pinned submodule is upstream or a pointer move: an edit made in
  the working copy is discarded, silently, by the next `git checkout` of a tag,
  and it fails nothing on the way out. Second, `check_game.sh`'s
  `max_minetest_version` guard (`scripts/check_game.sh:34`) is scoped to
  `game.conf` — it never saw this defect for the two days it stood and does not
  see it gone, which is why this finding's evidence is a file and a pointer
  rather than a green run. Widening the guard to every bundled `mod.conf` is a
  wanted check and a `TODO.md` line, and **not a finding**: nothing in committed
  code is wrong now.

- **C22 · low · resolved** — `menu/background.png`, `menu/header.png` and
  `menu/icon.png` reach every player and **no file anywhere stated a licence for
  them**: `THIRD-PARTY-LICENSES.md` had no media row and no mention of `menu/`,
  there was no `menu/license.txt`, the root `LICENSE` is the bare AGPL-3.0 text
  with no statement of what it covers, and `.cdb.json` carried
  `"license": "AGPL-3.0-only"` and no `media_license`. Filed 2026-09-07, turned up
  sideways by `G7` giving `cc_mapgen` two textures of its own *and* a *License of
  media* section with them — so the game named a licence for two 16×16 files and
  none for 655 kB of artwork every player sees before entering a world. That
  contrast was the finding; the root `LICENSE` plausibly covered the repository,
  so it was an unstated licence rather than a legal void, which is why it was low.
  Raised by `code-expert` as suspected and verified by reading all four files.
  **Fixed 2026-09-08** once the author decided the split — code AGPL-3.0-only,
  all of the game's own media CC BY-SA 4.0 — in four places: a new
  `menu/license.txt` covering the three PNGs and naming the three `.svg` sources
  as the same works under the same licence; `mods/cc_mapgen/license.txt`, whose
  *License of media* section had claimed the textures were "covered by the same
  license as the source code above" and now says explicitly that they are not;
  two media rows in `THIRD-PARTY-LICENSES.md`; and
  `"media_license": "CC-BY-SA-4.0"` in `scripts/gen_cdb_json.sh`, with
  `.cdb.json` regenerated. The decision and its grounds are `ROADMAP.md` `G7`,
  *The media licence*. **The closure condition is met.** It was written
  uncommitted, and held only once `menu/license.txt` was committed, since an
  untracked licence file ships to nobody — the mistake this project has made
  before (see *the corrections*). `P2` at `48cc63e` on 2026-09-08 listed the
  archive and found `menu/license.txt` beside the three PNGs and
  `mods/cc_mapgen/license.txt` beside its two textures, so the statement reaches
  a player. Nothing about this is conditional any more; what remains unenforced
  is `Keep` (3).

  **Keep — three things this fix does not do, and the third is the live one.**
  (1) The root `LICENSE` is still bare AGPL-3.0 with no scope statement, and that
  is deliberate: the AGPL text is meant to be distributed verbatim, so the scope
  line lives in `README.md`'s licence line instead — *code AGPL-3.0-only, media
  CC BY-SA 4.0*. (2) `menu/license.txt` must **not** gain an `export-ignore`
  rule: it is the only statement of the licence a player receives, and it has to
  travel beside the images it covers, which is `THIRD-PARTY-LICENSES.md`'s reason
  for shipping too. (3) **Nothing enforces any of it.** `check_game.sh` requires
  a `license.txt` or a `THIRD-PARTY-LICENSES.md` row per *mod* (`C3`, `C5`); no
  check reads a media file at all, so a texture or a menu image added with no
  licence line fails nothing, locally or in CI, and the omission is invisible
  until somebody reads the archive. That is `C15`'s standing hazard in a second
  form — the same silence over `.gitattributes` — and it is **not a finding**,
  because there is no defect in committed code: every media file the game ships
  is now covered. It is a wanted check, and it is a `TODO.md` line.

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

## Resolved — A architecture and performance

**6 findings, 3 resolved, 1 open and 2 won't fix.** `A7` is open and `A8` and
`A20` are won't fix; all three are in full above. `A13` and
`A19` are below in full, not compressed: `A13` closed at `50fd05f` on 2026-09-08
and its reasoning is still load-bearing — the three essential mapgen aliases and
the surface material it dragged in are what a future change would re-break — and
`A19` was filed, fixed and verified on 2026-09-09, with its own stated cause
corrected in the same pass and the wrong version kept beside it. **Both left the
resolved-and-unverified state on 2026-09-09**, on `R9` and on `L4`.

| Id | Sev | Was | Fixed by | Where it stands |
|---|---|---|---|---|
| `A14` | medium | CI conflated the component with the composite: the game's badge reported on the mod's internals and the mod had no CI at all | split along the component/composite line; the mod took its own `.luacheckrc`, specs and badge | — |
| `A13` | medium | `mods/default`, `mods/dye` and `mods/wool` were 9,744 lines vendored to supply 106 node definitions | all three deleted at `50fd05f`, once CodeBlock registered its own 105 nodes; `cc_mapgen` took the three essential mapgen aliases and the world's surface material | **verified in a world** — `W15`, `W16` and `R9` all pass on 2026-09-09. In full below |
| `A19` | medium | permanent noon reached the light level and the sky objects but not the sky's own colour, so the horizon and the fog still moved with the time of day — and with the player's yaw | one `set_sky{type = "plain", base_color = "#90d3f6"}` in `cc_day`, `plain` being the one sky type the engine excludes from the directional tint | `dd83b99`; **verified in a world** by `L4`, 2026-09-09. In full below |

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

### A13 · medium · resolved, `W15`, `W16` and `R9` all pass — `default` was 9,744 lines to supply 106 node definitions, and the answer was deletion

`mods/default` · `mods/dye` · `mods/wool` · `mods/cc_mapgen/init.lua` ·
`mods/cc_mapgen/mapgen_env.lua`

**Unblocked on 2026-09-08, and the deferral ended by being answered rather than
by anyone changing their mind.** CodeBlock at `fb75bc8` registers **its own 105
nodes** in `lib/nodes.lua` — 35 colours × solid/glass/lamp, `codeblock:<short>`,
`codeblock:<short>_glass`, `codeblock:<short>_lamp` — and
`mods/codeblock/mod.conf` reads `depends = vector3` only. Their finding is `F11`
and its reason is that `default` and `wool` are Minetest Game's and ship with
almost no other game, so borrowing a node, a texture or a sound from either put
the mod out of reach of most of ContentDB. The deferral's own words were *"CodeBlock
is expected to integrate the blocks it needs, at which point `default` is deleted
rather than trimmed"*. It happened, so the 9,744-lines-for-106-nodes framing below
is spent: **the work is deleting `mods/default`, `mods/dye` and `mods/wool`
outright**, and the palette is no longer a contract this repository has to honour.

**Resolved at `50fd05f`, 2026-09-08.** All three
directories are gone, `cc_mapgen` registers four nodes and the three mapgen
aliases, and the game's Lua went from 177 non-comment lines to 208 while roughly
9,700 vendored lines left the tree. **Neither gate runs a line of this game's
Lua**, so what was owed was evidence: `W15` (one layer of grass over dirt at 128)
and `W16` (no unknown node anywhere), and then `R9`.

**Verified in a world on 2026-09-09, and this leaves the
resolved-and-unverified state.** All three checks pass: `W15` and `W16` at
`50fd05f`, and `R9` across two sittings — its fifteen blocks first, then the two
corrected one-line programs of its misspelling step. So the author's earlier
same-day report — grass over dirt at the right height, dirt on a cut face, the
engine's own hotbar and hand in place of `default`'s — is backed by result lines,
and **every block a program can name resolves with `default`, `dye` and `wool`
gone**, which was the deletion's whole remaining risk. Two limits are carried in
`PLAYTEST.md` rather than restated here: `R9`'s misspelling step was written
against the wrong code path and had to be corrected before it could run at all,
and the default-coloured block the quiet path leaves behind was not read back.
**This finding does not narrow to `W11`.** `W11` judges the bedrock and barrier
redraw, which is `G7`'s subject and allocates no finding; nothing in it says
anything about the deletion. The roadmap entry is `G3`.

**Two consequences, and the first is the real cost of the deletion.**

- **The engine's essential mapgen aliases go with `default`.**
  `mods/default/mapgen.lua:7-9` is the only thing in the tree registering
  `mapgen_stone`, `mapgen_water_source` and `mapgen_river_water_source`, which
  `lua_api.md` lists as **essential for every non-V6 mapgen**. `cc_mapgen` has to
  supply all three. **Nothing in this record anticipated it** — the finding was
  written entirely about node definitions — and it is the thing a future reader
  would otherwise re-derive from a broken world. `mapgen_water_source` and
  `mapgen_river_water_source` alias to `air`: the surface stands at 128, far above
  `mgflat`'s water level, so no water is ever generated. `W16` is the check.
- **The world's surface material becomes the game's own**, on the author's
  instruction: `cc_mapgen:grass` one layer thick at `mgflat_ground_level` over
  `cc_mapgen:dirt`, which is what `mapgen_stone` aliases to. That is a decision and
  its record is `ROADMAP.md` `G3` decision 2, not this finding. `W15` is the check.

**The deletion had a fifth consequence nobody costed, and it has its own id —
`A20`, 2026-09-09.** `mods/default/tools.lua` overrode the hand with
`groupcaps`; it was the only thing in the tree that did, and with it gone the
engine's builtin hand has **empty groupcaps**, so nothing in the game is
hand-diggable at all. That does not change what a player can do — every node was
already undiggable — but it makes `PLAYTEST.md` `R1` unable to fail, and it is
why `R2`'s drop half stopped being runnable. Recorded here so the deletion is not
read as costless: `A20` holds the trace and the decision taken about it.

**Four other findings move with the deletion, and none of them reopens.**
`S8`'s residue — a bookshelf that still opens — goes with the node, and `R6`
becomes unrunnable. `B49`'s fix stops being exercised by anything, because nothing
left in the game registers an ABM or an `on_timer`, and `R7` becomes unrunnable
too. `B19`'s two `flowers:*` aliases lose the schematics that needed them, and
`B24`'s one-token fix is deleted along with the file it was in. Each says so where
it stands.

**The framing below is the finding as it stood while the trim was the question.
It is kept, not deleted, because two of its paragraphs are corrections and one is
a lesson this finding kept re-teaching.**

The palette referenced **122** nodes: 106 from `default`, 15 from `wool`, plus
`air`. Nothing else in `default` was reachable — digging is disabled for every
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

**`mapgen.lua` is safe to cut whatever is decided about the rest** — 2,492 lines,
dead whoever ends up owning the palette, since `cc_mapgen` disables decorations,
ores and biomes outright.

**Deferred on 2026-09-02, by the author, and the reason turned out to be the
right one — see the top of this finding, where it came true on 2026-09-08.**
`codeblock` is expected to integrate the blocks it needs, at which point the
game's vendored `default` is not trimmed but deleted. Doing the trim now means
hand-curating 9,744 lines of third-party code against a contract owned by the
other repository, and then mirroring every palette change the mod makes — the
coupling this project avoids everywhere else. The saving is size and boot noise,
not behaviour, so nothing a player meets is waiting on it. See `ROADMAP.md` under
*deliberately not doing* for what would change that.

### A19 · medium · resolved, `L4` passes — permanent noon did not reach the sky's own colour, so a day-night blend remained at the horizon

`mods/cc_day/init.lua`

**Fixed by one call, committed at `dd83b99`.** `player:set_sky({type = "plain",
base_color = "#90d3f6"})` inside `cc_day`'s existing `register_on_joinplayer`,
written and run in a world on 2026-09-09 and committed the same day. `#90d3f6` is
the engine's own
`day_horizon` default, so at true noon the horizon band and the fog are exactly
what they were and only the zenith changes, from `#61b5f5` to that same lighter
blue. No `sky_color`, no `fog_sun_tint`/`fog_moon_tint`/`fog_tint_type`, no
`clouds` field and no `fog` table. `cc_day` goes from 7 lines to 8.

**Closed by `PLAYTEST.md` `L4`, and that result line is the whole of the
evidence.** `L4` passed both halves at this tree, engine 5.17.0, 2026-09-09: the
sky and the fog do not move across `/time 0`, `5000`, `10000` and `22000`,
nothing changes as the player turns a full circle at each, indoors matches
outdoors, and **none of the three over-applied signals appeared** — so `#90d3f6`
stays and the trade is accepted as made. `L1`, `L2` and `L3` passed in the same
sitting behind it. Both gates were green on the commit and **neither runs a line
of this game's Lua**, which is why `L4` and not `dd83b99` is what closes this.

**Three limits of that closure, carried here rather than smoothed away.** The
report was the single word *pass* for a check whose method is four `/time`
positions — **including both blend peaks** — a full circle turned at each, and an
indoor comparison, so nothing was read back about any one of them. Each of the
three over-applied signals is a **sub-condition that fails quietly**: *shifts only
at 22000*, *shifts only as you turn*, and *grey only indoors* would each leave the
rest of the check passing, and none was described back. And the `L4` method is
the only thing in the project that asks about the horizon or the fog at all, so
there is no second check to corroborate it.

The defect: the game pinned the **light level** and removed the **sky objects**,
and left the sky's own **colour and fog** on the engine's day cycle, so a visible
blend remained at the horizon in a game whose premise is permanent noon. Filed
from `L3`'s partial, 2026-09-09, engine 5.17.0, at `50fd05f` with the working
tree's `mods/codeblock` at `fb75bc8`.

**The cause as first stated was wrong in mechanism, and the wrong version is
below rather than deleted.** Traced through the engine's `sky.cpp`, `sky.h`,
`game.cpp` and `clientpackethandler.cpp` at **both 5.9.0, this game's floor, and
5.17.0**, which are identical in this area:

- `override_day_night_ratio(1)` pins `time_brightness` to 1.0, and `Sky::update`
  selects dawn only for `time_brightness` in `[0.20, 0.35)` and night below
  `0.13`. The sky was therefore **permanently in the day branch**: `dawn_sky`,
  `dawn_horizon`, `night_sky`, `night_horizon` and `indoors` were never
  reachable, and pinning them would have fixed nothing.
- What moved is **`m_horizon_blend()`** (`sky.h`), a function of the raw time of
  day alone. It mixes a sun/moon `pointcolor` into the background by up to `0.5`
  and into the sky by up to `0.25`. It peaks at `/time 4800`, is `0.833` at
  `/time 5000`, and is flat zero from `/time 6000` to `/time 18000` — exactly the
  pair the author compared, and why this went unnoticed for so long.
- The blend is gated on the **client-side** `directional_colored_fog`, default
  on, which a game cannot switch off.
- `plain` is immune by construction and the engine says so:
  `handleClientEvent_SetSky` calls `setVisible(false)` and
  `setHorizonTint(bgcolor, bgcolor, "custom")` under its own comment *"Disable
  directional sun/moon tinting on plain or invalid skyboxes"*.

**What it cost a player, and it is more than the finding claimed.** A new world
with no saved time starts at `time_of_day = 5250` (`serverenvironment.cpp`) and
this game sets `time_speed = 0`, so **every fresh Codecube world has always sat
permanently at a horizon blend of 0.625** — a sunrise-tinted horizon was the
game's default look, not an artefact of typing `/time 5000`. And `pointcolor` is
mixed by player **yaw**, so the horizon also changed as a player turned on the
spot. Both stop with this change.

**What the fix costs.** A plain sky is one flat colour, so the day gradient is
gone, and the `indoors` grey shift goes with it: the sky and the fog no longer
change when a player stands inside something the drone built. `L4` carries the
over-applied signals that would say the trade went too far, and the lever is the
one hex constant.

**Keep — a `regular` sky cannot be made time-independent, so do not reinstate
`sky_color` (`A19`).** With custom tints set to one colour the horizon becomes
`mix(day_horizon, C, hb*0.5)` and the zenith `mix(day_sky, C, hb*0.25)`; one
constant cannot satisfy both, and the best available was a fixed horizon with the
zenith still drifting about 10/255. The author has **twice** declined recording a
residual, which rules that candidate out on evidence rather than on preference.
The four `set_stars`/`set_sun`/`set_moon`/`set_clouds` calls stay in `cc_day`
precisely so a future return to `"regular"` cannot silently restore the sky
objects.

**Keep — no setting was added, and that was deliberate (`A19`).**
`settingtypes.txt` and `minetest.conf` are untouched. The game already imposes
permanent noon with no setting, and a server owner handed a free `ColorSpec`
could break the very invariant this finding exists for.

**Keep — this was recorded as a shortfall in the game, not as a defect in the
check's wording, and that was a choice (`A19`).** Two readings were put to the
author on 2026-09-09 and both declined: **rewording `L1` and `L3` to expect a
residual horizon blend**, on the ground that `cc_day`'s job is only the light
level and the sky objects, and **recording the residual and moving on with no
finding**. The author ruled that the game *should* pin the sky colours. The "not
a defect at all" reading is the natural one — the light level is pinned and every
sky object is gone — so without this paragraph it gets re-derived and the finding
gets withdrawn by someone reasoning from the code alone.

**The cause as originally filed, kept because it is the natural reading and
someone will re-derive it.** *"`cc_day` calls `override_day_night_ratio`,
`set_stars`, `set_sun`, `set_moon` and `set_clouds`, and never `set_sky` — so the
client keeps deriving the horizon colour and the fog from the time of day.
`set_sky`'s `sky_color` table carries separate `day_horizon` and `dawn_horizon`
entries plus `fog_sun_tint` and `fog_moon_tint`; `/time 5000` is 0.208, near the
dawn blend, and `/time 10000` is 0.417, full day."* It was marked likely and not
demonstrated, and it was wrong on two counts: the dawn branch was unreachable
under a pinned ratio, and the blend that actually moved is not in `sky_color` at
all. The roadmap entry is `G4`.

## Verified, committed, claimed

**Verified:** `scripts/check_game.sh` passes, in this tree and inside a fresh
clone; luacheck is silent on the three `cc_*` mods; the `.claude/` size quoted in
`C15` (993 kB, measured here); `C20`'s counts, read out of `README.md` — nine
images, four `dp.png`, one `ds.png`, two links to the game's own ContentDB page.

**Verified from the outside, at `48cc63e`:** `P2` re-run on 2026-09-08 after
`G6`, `G7` and the media licence added five tracked files — 494 entries,
**1.95 MB zipped** by `git archive --format=zip`. Nothing hidden, no art source,
no `scripts/`, none of the six record documents; present and checked one by one:
the three `menu/*.png`, `menu/license.txt`, `mods/cc_mapgen/license.txt` with
`cc_mapgen_bedrock.png` and `cc_mapgen_barrier.png`, and
`THIRD-PARTY-LICENSES.md`. That is `C22`'s closure condition met and `C15`'s
archive half re-settled — **for that commit only**, since nothing in either CI
reads `.gitattributes`. The 1.93 → 1.95 MB step is **noted, not accounted for**:
the two textures and two licence files are a few kB between them, and the
remainder was not tracked down.

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
ways. `C21` is read straight out of a tracked file (`mods/vector3/mod.conf`) at
both pointers and is verified as *a fact about the metadata*; what it never told
anyone is whether it cost anything.

**Nothing in a world has been played against `vector3` `v2.0.2`, and that is what
the re-pin leaves open.** `C21`'s own claim is metadata and is settled by reading
the file; what is unproven is a **major version of a hard dependency** running
under the drone. `v2.0` made two breaking changes — writing to an exported
constant raises `read only`, and a bad argument raises `format error` where the
`from*` constructors used to return `nil` — and the adopted CodeBlock is written
for both, `snapshot_vector3` in `mods/codeblock/lib/sandbox.lua:123-148`
rebuilding the constants with the constructor precisely because 2.0 froze them.
The method surface is otherwise unchanged between `v1.5` and `v2.0.2`: same
names, same arity. **That is a reading of source and not a run.** `PLAYTEST.md`
gets no new entry for it — `ROADMAP.md` `G5` records why — and the game-side
evidence is `R4` and `R9` re-run at whatever commit carries the pointer; both
currently name `dd83b99`, which is before it. The `vector` library's own
semantics are the mod's `PLAYTEST.md` and not this one's.

**Committed and unproven, on branch `g6-world-limits`, tip `dd83b99`:** this
named `B48`'s group strip at `ec02760` and `B19` and `B24`. `B48` left the state on
2026-09-09 when `R8` passed; **`B19` and `B24` are the only two left in it**, and
both wait on `P3`. `G6` itself is no longer here: `f5f2385` carried `minetest.conf` at
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
branch; the newest run of any kind is `main` at `35fa2a1`, 2026-09-01.

**Verified — the whole of `G7`, committed at `d6e4a12` and run in a world at
`3479e25` on 2026-09-08.** All three changes landed in one commit: the translucent
barrier at the world's edge; the game's own two textures for both bound nodes, in
a new `mods/cc_mapgen/textures/`; and `mgflat_ground_level` at 128 with the
settings entry, the `minetest.conf` default and the forced override that carry it,
plus the `cc_security` fallback that moved with it. **Both gates were green on it**
— `check_game.sh` ending `all game integration checks passed`, luacheck on the
three `cc_*` mods printing nothing — and **neither runs a line of this game's
Lua**, so green said the game assembles and nothing more. `PLAYTEST.md`
`W10`–`W14` are the five checks and **all five passed**, reported by the author
from one sitting: the barrier reads as an edge and still stops you, the two
textures render and the floor shows no tiling grid, a new world stands you at `y`
about 128.5, an existing world's surface moves on reopening, and the rescue reads
the new depth with no 8 and no 9 anywhere. **Two limits of that evidence**: the
engine version was not given, and the report was one word per check rather than a
part-by-part account. **No finding is opened by any of the three**: `G6`'s wall was
correct and `W5` says so, and the one real defect the pass introduced was caught
before it was committed.

**One of those five no longer stands: `W11` is back to `unchecked`.** The bedrock
and barrier textures were redrawn on 2026-09-08 after the author rejected their
look, so its pass is a result carried across a change to the media it exercised,
and it had also passed against wording — *"black mottled rock"*, a seamlessness
credited to a *"wrapping blur"* — that the new textures cannot meet. `PLAYTEST.md`
holds the retired line and the reason. **Still no finding**: the rejection is of an
appearance and not of a defect, which is `G7`'s whole subject; the decision and
the construction that replaced the old one are `ROADMAP.md` `G7`, *The texture
rework*.

**`W4`, `W8` and `W9` are owed re-runs at `d6e4a12`.** All three pass at
`60259dd`, where `mgflat_ground_level` was 8, and all three exercise heights
`cc_security`'s rescue derives from that number. Their passes are not moved and
not backdated — they are what was seen at `60259dd` — but a result cannot survive
a change to the code it exercised, and this is a change to it. **`W14` discharges
none of the three**, and `PLAYTEST.md`'s *what needs action* table says why per
check: `W4`'s subject is air rather than stone under a removed floor tile, `W8`
requires the wall walk and the exposed floor plane to move nobody, and `W9` cases
1 and 3 — rescued once with no second teleport, and the no-op where only
`(x, 0, z)` changed — are untouched by it.

**Verified in a world — `G3`'s deletion, committed `50fd05f` on 2026-09-08 and
played on 2026-09-09.** The record
documents, `README.md`, `CONTENTDB.md`, `.cdb.json` and `CHANGELOG.md` landed in
the same commit as the code, which is the only arrangement in which the
player-facing prose is never wrong about the world. **All three of its checks now
pass**: `W15`, `W16` and `R9`, the last across two sittings after its misspelling
step was corrected. `A13` is the finding and `ROADMAP.md` `G3` the entry.

**Committed and part-proven — the texture rework, at `dd83b99` on 2026-09-09.**
Grass, dirt, bedrock and the barrier redrawn in a flat-base
plus sparse-specks style after the author rejected the first attempt's grain,
with `scripts/gen_textures.py` added to hold the palettes and the seeds. It is
**not a finding**: no committed code was defective. `W11` and `W15` are what judge
it; **`W15` passes and `W11` does not** — its earlier pass was retired rather than
carried across the change, and it was not run beside `W15`, so the bedrock and
barrier redraw is the one part of this change nobody has looked at.

**Verified in a world — `A19`'s `plain` sky, committed `dd83b99` on 2026-09-09.**
`L4` passed both halves at that tree, engine 5.17.0, and `L1`, `L2` and `L3`
passed behind it in the same sitting. Both gates were green on the commit and
neither runs a line of this game's Lua. **Three limits are in the finding**: a
one-word report over four `/time` positions and two halves, three over-applied
signals each of which fails quietly, and no second check that asks about the
horizon or the fog at all.

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

**Claimed and not verified — a comment in `mods/cc_security/init.lua:96-97`.** It
says that a player who falls through the floor does not keep falling: the engine
collides with unloaded space and zeroes their velocity, so they come to rest on
an invisible dark ledge. **That claim replaced a wrong one** — the comment
previously said such a player "never lands" — but the replacement was **taken on
trust from an earlier session's note and has never been checked**, neither
against the engine's source nor in a running world. `B50`'s fix and its reasoning
do not depend on it either way and are unaffected: the rescue fires on a player
outside the box whether they are falling or resting. Recorded here because a
comment stating a mechanism reads exactly like one that was verified, and this
one was not. It is a `TODO.md` line, not a finding — nothing is wrong with the
code, only with what is known about the sentence beside it.

**Still not checked:** `W11`, whose pass was retired with the textures it
described; `P3` (the boot log), `P4` (the main menu), `P5` (the ContentDB page,
which needs a release), and the boot half of `P1`, which is a fresh recursive
clone and is not discharged by the author's own checkout booting. **That is the
whole of the unchecked list**, and it has not been this short before.

**Results moved on 2026-09-09 over three sittings**, and `PLAYTEST.md`'s own
status table is where they are counted rather than here. `W15`, `W16`, `R8`
and `R3` first; then `R9` completed and `L3` composed, both having been `partial`
with one half unrun; then `R1`, `R2`, `L1`, `L2` and `L4`, with `R5` composing
from `R2` and `R3`. `R9`'s remaining half had been
unreachable as written: its misspelling step named a code path that cannot produce
the warning it asks for, corrected in `PLAYTEST.md` from the adopted mod's source.
**`R1` and `R2` were the document's priority and are discharged.** `R2`'s drop
half had been re-attempted earlier the same day with both lines commented out and
nothing diggable at all — no evidence either way, **diagnosed as `A20`** — and it
ran under that finding's temporary hand override at `dd83b99`, which is also what
made `R1` the **first falsifiable run of the digging restriction in the project**.
Both are limited by breadth rather than by setup: `R1`'s bare *pass* named none of
the seven subjects its method asks for, and `R2`'s named neither the hotbar slot
nor the dug position. **`R6` and `R7` leave this document's re-run lists
by becoming unrunnable** with `G3`'s deletion, not by being discharged.
**`W10` and `W12`–`W14` pass at `3479e25`**. **`W4`, `W8` and
`W9` are owed re-runs** at the current depth, and `W14` discharges none of them.
`P2` is owed a re-run whenever a tracked file is added, because nothing in either
CI reads `.gitattributes`. **`R4` is the last re-run for `B48`'s blast radius**,
`R1` and `R9` having been run and `R6` having become unrunnable: the `B48` change
rewrites
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

**`A19`'s mechanism is verified out of the engine source, and its fix is now
verified separately in a world.** `sky.cpp`, `sky.h`, `game.cpp` and
`clientpackethandler.cpp` were read at **5.9.0 and 5.17.0** — the dawn and night
branches unreachable under a pinned ratio, `m_horizon_blend` as the mover, the
`plain` path disabling the directional tint, and `time_of_day = 5250` as a new
world's start in `serverenvironment.cpp`. That is a strong reading of what the
client does and it is **not** an observation of a screen. What was observed is the
fix holding: `L4` at `dd83b99`, engine 5.17.0, 2026-09-09. **Nobody observed the
defect at `/time 22000`**, the other blend peak, so the mechanism's shape is still
read and only its absence is seen.

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

**One from 2026-09-09, and it is the same lesson at the sky.** `A19`'s stated
cause named `sky_color`'s `dawn_horizon` and the dawn blend; the engine source
says the dawn branch is unreachable under a pinned day-night ratio and the mover
is `m_horizon_blend`, which no colour table reaches. The wrong version is kept
inside the finding, marked as such, because it is what the API reference alone
suggests and the next reader will re-derive it. **It was marked "likely and not
demonstrated" when filed, and that marking is what made it cheap to correct.**

---

Revised 2026-09-09 at `c7c2c43`, on the author's decision about `A8`. **`A8` is
won't fix and the counts move to 22 findings, 19 resolved, 1 open and 2 won't
fix** — `A7` is the only open finding left. The author's words: *the case of
another mod in this game is not actual*. Nothing in `mods/` changed for it.
Recorded alongside the decision, from the offline 5.17.0 reference read the same
day and not from a run: `core.node_dig` is the one single-point alternative for
the digging job and was not exhaustively ruled out, and the walk's other four
jobs have no game-wide equivalent at all. Every existing evidence paragraph in
the finding stands, including the `last_mod`-untested-by-choice decision of
2026-09-02.

Revised 2026-09-09 at `c7c2c43`, with `mods/vector3` staged at `fc8a5b8`.
**`C21` is resolved and the counts move to 22 findings, 19 resolved, 2 open and
one won't fix** — `A7` and `A8` open, `A20` won't fix, and the `C` series is
closed. The change is a pointer and not a line of this repository: `mods/vector3`
from `v1.5` (`16621648`) to `v2.0.2` (`fc8a5b8`), whose `mod.conf` states
`min_minetest_version = 5.3` and no ceiling. `C21` moves from *Open findings* to
the resolved `C` series, compressed, keeping one `Keep` — never hand-edit a
submodule's `mod.conf`, and no gate here reads one. Both gates were green at
`c7c2c43` with the pointer staged, which says the game assembles; **no gate in
this repository ever saw `C21` and none sees it gone**, so the evidence is the
file. Two things the re-pin buys beyond the finding are in `CHANGELOG.md`, being
player-facing: a startup warning from the adopted CodeBlock about a `vector3`
older than 2.0.2, and with it the condition it warned about, and an unbounded
rejection-sampling loop in `v1.5`'s samplers that could hang the server. What it
does **not** buy is world evidence — nothing has been played against `v2.0.2`,
and *Verified, committed, claimed* says so rather than the record implying
otherwise. **One correction to the entry below**: it reads *"2 open"* and then
names three open findings, which the status table never agreed with. The count
was the typo and three was right at `dd83b99`.

Revised 2026-09-09 at `dd83b99`, tree clean. **The counts move to 22 findings,
18 resolved, 2 open and the first won't fix** — `A7` and `A8` open, `C21` open,
`A20` won't fix. Three states changed on evidence, all from one sitting at that
tree on engine 5.17.0: **`A19` is resolved and verified** by `L4`, **`A13` is
verified** by `R9`, and **`A20` is won't fix** — its condition real and permanent,
its fix declined by the author on the merits, and the obligation it created
discharged by `R1` running falsifiably under the temporary hand override. So the
unverified-in-a-world table drops from four findings to **two**, `B19` and `B24`,
both waiting on `P3`. `B48` was **not** reopened and gained one limit: `R8` was
not re-run with the override, so its pass still has two explanations. `B47` gained
a `Keep` — a `plain` sky draws no mesh, so `sunrise_visible = false` is
unobservable for good and `L3`'s retained 2026-09-01 `partial` is its only
evidence. Three counts corrected here: *twenty* findings to 22, the game's Lua
572 lines to 591, and the branch's 23 commits over `main` to **14**.

An entry for **`A20`'s filing** is missing from this log: it was filed on
2026-09-09 in the same pass that resolved `A19`, and the entry below counts 21
findings when the table already said 22. Recorded rather than back-written.

Revised 2026-09-09 at `50fd05f`, plus an uncommitted texture rework and an
uncommitted `cc_day` one-liner over it. **`A19` is resolved in the working tree
and the counts move to 21 findings, 18 resolved, 3 open** — `A7`, `A8` and `C21`
— and the
unverified-in-a-world table goes from four findings to **five**, `A19` being the
one with no commit to name. Its entry moved out of *open findings* into the `A`
series **in full**, its cause corrected and the wrong version kept beside it, and
it gained the two facts that raise what it cost: a fresh world's
`time_of_day = 5250`, and yaw feeding the blend. `PLAYTEST.md` gains `L4`, which
is what judges the fix; **no result line moved**, so `L3` stays `partial`.

Revised 2026-09-08 at `50fd05f`, plus an uncommitted texture rework over it.
**`A13` is resolved and the counts move to 20 findings, 17 resolved, 3 open** —
`A7`, `A8` and `C21`. `mods/default`, `mods/dye` and `mods/wool` are deleted,
`cc_mapgen` carries the three essential mapgen aliases and the world's surface
material, and the entry moved out of *open findings* into the `A` series **in
full rather than compressed**, because the aliases and the surface material are
what a future change would re-break. It is **unverified in a world**: `W15` and
`W16` are unrun, so the unverified-in-a-world table goes from three findings to
four. **No finding was filed for the texture rework** — the author rejected an
appearance, not a defect — and its record is `ROADMAP.md` `G7`, *The texture
rework*. `PLAYTEST.md`'s counts move to 33 entries, 22 pass, 2 partial, 0 fail,
9 unrun, because **`W11`'s pass was retired** with the textures it described.
**Two corrections about the remote**, both read here from git and the Actions API:
the branch is pushed except `50fd05f`, not unpushed, and CI's newest run is `main`
at `35fa2a1` rather than anything on `578b364`, which was never pushed.

Revised 2026-09-08 at `3479e25`, record-only over `48cc63e`, on `W10`–`W14`
passing. **No finding was filed, none changed state, and the counts are unchanged:
20 findings, 16 resolved, 4 open** — `A7`, `A8`, `A13` and `C21`. What moved is
evidence. `G7` goes from *committed and unproven* to **verified**, and
`PLAYTEST.md`'s counts to 30 entries, 23 pass, 2 partial, 0 fail, 5 unrun. **Two
things that did not close.** `W4`, `W8` and `W9` are still owed re-runs at the new
depth, because `W14` reaches none of their subjects — air rather than stone under
a removed floor tile, the wall walk and the exposed floor plane moving nobody, and
`W9`'s cases 1 and 3. And the boot is **narrower, not confirmed**: the five passes
prove the author's own checkout boots and enters a world, while `P1`'s boot half
is a *fresh recursive clone* whose submodule objects nobody has locally, and `P3`,
the boot log, is unrun. The engine version was not given on any of the five.

Revised 2026-09-08 at `48cc63e`, on `P2` being re-run. **No finding was filed,
none changed state, and the counts are unchanged: 20 findings, 16 resolved,
4 open** — `A7`, `A8`, `A13` and `C21`. What moved is evidence, not state.
**`C22`'s closure is no longer conditional**: it was written while
`menu/license.txt` sat untracked in the working tree, and `P2` at `48cc63e`
confirms by listing the archive that the file reaches a player, so the condition
the revision above held open is met. `C15`'s archive half is confirmed for that
commit and for no other — 494 entries, 1.95 MB zipped, every clause checked
rather than inferred — and the standing hazard is unchanged, because nothing in
either CI reads `.gitattributes`. `P2` is therefore recorded in `PLAYTEST.md` as a
**standing obligation** rather than a closed action: its own instructions say to
run it whenever a tracked file is added, and it has been needed twice in two
milestones. **Still no finding for the gap** — no committed code is defective —
and it stays a `TODO.md` line under `C22`'s `Keep`. `PLAYTEST.md`'s counts were
recomputed and held at that pass: 30 entries, 18 pass, 2 partial, 0 fail, 10
unchecked — **superseded on 2026-09-08 by `W10`–`W14` passing**, 23 pass and 5
unrun.

Revised 2026-09-08 at `6a0258a`, on the licence decision. **`C22` is resolved and
the counts move to 20 findings, 16 resolved, 4 open** — `A7`, `A8`, `A13` and
`C21`. The author chose code AGPL-3.0-only and all of the game's own media
CC BY-SA 4.0; `code-expert` wrote it into a new `menu/license.txt`,
`mods/cc_mapgen/license.txt`, `THIRD-PARTY-LICENSES.md` and
`scripts/gen_cdb_json.sh`, and `.cdb.json` was regenerated.
`CC-BY-SA-4.0` — hyphenated — is ContentDB's own spelling and was confirmed
against `https://content.luanti.org/api/licenses/` here as well as by
`code-expert`. The fix was in the working tree and uncommitted when this was
written, so the closure held only once `menu/license.txt` was tracked; it
committed in `48cc63e` and `P2` confirmed there that it reaches a player, so
**the condition is met**. **No finding was filed for
the gap the fix leaves** — no gate reads a media file, so a media file added with
no licence line fails nothing — because there is no defect in committed code;
it is in `C22`'s `Keep` and as a `TODO.md` line.

Revised 2026-09-08 at `d6e4a12`, on `G7` being committed and on this document
being reorganised. **No finding was filed, none changed state, and the counts are
unchanged: 20 findings, 15 resolved, 5 open** — `A7`, `A8`, `A13`, `C21`, `C22`.
Four things moved.

- **`G7` is committed.** Everything that read *written and gated, none of
  committed, released or seen* is now *committed and unproven at `d6e4a12`*. The
  five checks `W10`–`W14` were still `unchecked` at that pass; what they gained is
  a sha to be run against, and they passed against it on 2026-09-08. `W4`, `W8` and `W9` are now recorded as **owed re-runs** at
  `d6e4a12`, because `mgflat_ground_level` moved from 8 to 128 and all three
  exercise heights the rescue derives from it.
- **The document is grouped by state before series.** `## Status` at the top
  carries a series table with a total row and a `waiting on` table for everything
  not resolved, which is a view this audit never had — what would close each open
  finding was previously stated only inside each finding's prose. Open findings
  follow in full; resolved ones follow by series, each behind an index table.
  **No finding text was cut to do it**, and no `Keep` was touched.
- **A constraint quoted twice is corrected in both places.** `B48` and `S8` each
  ruled out `del_fields` on the ground that it arrived in 5.9.0 while `game.conf`
  declared `min_minetest_version = 5.4`. **`G6` raised that floor to 5.9**, so
  availability is no longer an objection anywhere in this document. `B48`'s
  reasoning survives on its second ground — `del_fields` deletes top-level fields,
  not keys inside `groups` — and `S8`'s does not, so `S8` now records that a wider
  fix has an option it did not have. Nothing was rewritten on the strength of it.
- **One claim is moved into *claimed* where it was reading as verified.** The
  comment at `mods/cc_security/init.lua:96-97` says the engine collides with
  unloaded space and leaves a fallen player on an invisible dark ledge. It
  replaced a wrong claim, and it was itself taken on trust and never checked
  against the engine source or in a world. `B50` does not depend on it.

**The `Keep` paragraphs were deliberately left in place rather than gathered into
a section of their own.** Every resolved finding here except `B19` and `B24`
carries one, so gathering them would have separated each piece of reasoning from
the finding it belongs to and left a list that goes stale silently. They are
identified by the `**Keep —` marker and are not enumerated anywhere.

**Earlier revisions, newest first.**

- **2026-09-07, on the wall becoming a translucent `cc_mapgen:barrier` above the
  `cc_mapgen:bedrock` floor.** No finding filed and no state changed: 19 findings,
  15 resolved, 4 open. The wall `G6` built was correct and `W5` proves it; what the
  author wanted changed is its appearance, which is a goal and not a defect, so its
  record is `ROADMAP.md` `G7` and `PLAYTEST.md` `W10`. `A13`'s **Keep** now names
  **two** textures the trim must preserve — `default_obsidian.png` and
  `default_obsidian_glass.png` — and says `default_obsidian_glass_detail.png` is
  *not* one, because the framed drawtype that would have used it was rejected.
- **2026-09-07 at `60259dd`, on the whole `W` group passing.** **`B50` moves to
  resolved**, closed by `W4`–`W9` rather than by a commit, and the `B` category has
  no open finding left: 19 findings, 15 resolved, 4 open. Route one, walking off the
  generated edge, had never been observed and rests on `W5`; route two had lost its
  evidence earlier the same day and was rewritten and re-run. `B50` stays in full
  for its **Keep** paragraphs, and one is added: refusing to backdate `W4` and `W8`
  bought results naming the code in the tree, and **no result in this project now
  names a tree instead of a commit**. Route one is closed by *the fix holding*
  rather than by the defect being reproduced — the weaker shape, and the only one
  available. `W9` moves from `f5f2385` to `60259dd` and from three cases to four,
  with `repair_spawn()` exercised only by case 4. `B48` stays resolved, unverified.
- **2026-09-07, on the rescue being reversed at `60259dd`.** No state change: 19
  findings, 14 resolved, 5 open. The reversal is the author's design decision after
  playing, recorded as `ROADMAP.md` `G6` decision 7, and it took `B50` from
  *verified for route two only* to **unverified on both routes**. The **Keep** about
  the repair going one node under the destination rather than filling the plane at
  `y = 0` is **reversed and kept as the reasoning that was outweighed**: from a
  shaft you can program your way out, from an endless fall you cannot. The `cc_*`
  line count corrected from 338 to **397** with comments, **160** without.
- **2026-09-07, on `G6` being committed and `W9` passing.** `B50`'s fix is
  `f5f2385`, with `B48`'s group strip split out ahead of it as `ec02760`; both gates
  were re-run after committing rather than before. The two routes mapped onto their
  checks: `W4`, `W8`, `W9` route two, `W5` and `W6` route one, `W7` neither. `W4`
  and `W8` **kept their missing sha rather than being backdated** onto `f5f2385`,
  because `repair_spawn()` landed on the path they exercise in between. `cc_*` line
  count corrected from 103 to **338**. Counts unchanged.
- **2026-09-07, on the first in-world evidence `G6` had.** The author played the
  uncommitted tree, so route two and the clamp became observed rather than inferred
  while route one and the wall stayed inferred. The same sitting found the rescue
  looping at the spawn column, which has **no id** — the clamp was not committed, so
  it is the change being wrong and its record is `ROADMAP.md` `G6`. Three **Keep**
  paragraphs added against `repair_spawn()`: why the repair goes under the
  destination, why `get_node_or_nil` and `load_area` are both required, and why the
  `walkable` tests are against `false` rather than truthiness. Counts unchanged.
- **2026-09-07, while `G6` was built.** `B50` widened to two routes — the generated
  edge, and a hole a program digs in the floor, which the wall does not close — with
  the author's ruling that `cc_security` clamps a player outside the box back to
  spawn. The engine floor corrected from 5.7 to **5.9** in `C21` and in `B50`'s
  **Keep**, on the shipped `lua_api` at three tags: `register_mapgen_script` is
  absent at 5.7.0 and 5.8.0 and present at 5.9.0, so `C21`'s gap is four minor
  versions and not three. `A13` gained the constraint that the trim must keep
  `default_obsidian.png`. Counts unchanged.
- **2026-09-07, while the world-limits feature was shaped.** `B50` and `C21` filed,
  both open with nothing written for them; `B50` **suspected from reading, not seen
  in a world**. Counts move to 19 findings, 14 resolved, 5 open.
- **2026-09-07 at `578b364` plus an uncommitted `cc_security` change.** `B48` moves
  to resolved-unverified, its open question settled from `core.get_dig_params`
  rather than from inference; `A8` records that its table walk widened; the `B`
  count corrected from 5 to 6 and a duplicated stale `### A8` heading removed.
- **2026-09-02, five times.** While scoping `G3`, which produced `B49` and deferred
  `A13`; at `377d1f9`, when `R7` confirmed the `B49` fix; when `A7` was routed
  upstream, the same pass correcting `A7`'s "identical arguments" and `A8`'s
  `last_mod`, which is a `game.conf` key and not a `mod.conf` one; at `6f7d118`,
  when `A8`'s callback half was fixed and `R5` was cut back to a regression check
  because nothing in the game competes for those globals; and at `7dc764f`, when
  `R2`'s drop half ran for the first time.
- **2026-09-01, five times in one day.** At `8b27f2f` for the packaging checks; at
  `7f649d8` for the first playtest; again for the `B47` and `S8` fixes it produced;
  again after re-running `L1` and `R6`, which closed `B47` and reopened `S8`; and at
  `c042364`, when `R6` and `R4` closed `S8` for good. `S8`, `B47`, `B48` and `B49`
  are the findings from that day, allocated against the mod's audit in the sibling
  checkout, which stood at `B46`, `S7`, `A16`, `C19` and `F8` — the game's `C20` is
  the highest `C`.
