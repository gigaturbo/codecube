# Roadmap — Codecube

**What to do next for the game, and what has been agreed. The decisions below are
recorded nowhere else.** Git records what changed and `CHANGELOG.md` records what
shipped; neither records why a question is settled, so a scope decision, a
default chosen or an argument lost is kept here or it is re-litigated in three
months. This file cannot be reconstructed from the repository.

Codecube is a *game*: it bundles the CodeBlock mod, gives it a world worth
building in, and presents it to players. CodeBlock is the main project and keeps
its own roadmap in its own repository. This file covers only what the game owns:
its own mods, its settings and presentation, its packaging, and which CodeBlock
release it has adopted.

The reasoning behind every finding is in `AUDIT.md`; the manual checks are in
`PLAYTEST.md`; the author's inbox is `TODO.md`. `.reports/*.html` are gitignored
renderings of this file, the audit and the checklist.

Two numbering conventions, so a commit message always resolves:

- **Milestones here are lettered `G1`–`G7`.** They are not the mod's phases. The
  mod numbers its work `Phase 0`–`Phase 10` and those numbers appear in commit
  messages, so this file never says "Phase N" for anything of its own.
- **Finding ids are shared** with the mod's audit — a `B`, `S`, `C` or `A` number
  is allocated once across both, so it never means two things and is never
  renumbered. The 23 in `AUDIT.md` are the game's; the rest are the mod's, as
  is the `F` feature series.

Target is **v2.0.0**, chosen by the author on 2026-09-22 — major because several
changes break saved player programs, and 2 rather than 1 because `v1.0.0`,
`v1.0.1` and `v1.0.2` are already tagged and pushed. The mod's own **1.0.0 is a
different number**: the game at 2.0.0 adopts CodeBlock 1.0.0.

## Now

**The release is `v2.0.0` and `G8` is in it** — both decided 2026-09-22, and both
recorded under `G5` and `G8`. `v1.0.2` (`9d83f11`, 2022-07-07) is what a player
has installed today, so everything the changelog describes is measured against
it. What the two decisions leave is **`P2` and `P6`, now release blockers**: `P2`
because `cc_gui` added four tracked files to the archive, `P6` because nothing
automated reaches a formspec prepend and it is the only check that does.

**`release-check` answered no-go on 2026-09-22, and it is still no-go** — but two
of its four blockers are discharged, later the same day. **PR #1 was merged**,
`main` fast-forwarded `99117bf..49c7f75` and is in sync with `origin/main`, so
nothing exists only on this machine; and **CI is green on `49c7f75`** and on
`99117bf` before it, both jobs read individually. What still blocks: the
`codeblock` pointer is the untagged `09c708d`, `P2` and `P6` are unrun, and
**nothing has been played in a world** — the newest playtest result names
`dd83b99` and `cc_gui` has none. The ContentDB upload should still be treated as
manual until the webhook is checked from a machine that has `gh`. The gate run
also **corrected `CHANGELOG.md`**, which claimed the bundled mod had reached
1.0.0; no such CodeBlock release exists.

**The world was widened to `mapgen_limit = 4096` on 2026-09-17** — decision 9
under `G6`, reversing decision 5. The field is 8080 nodes on a side and the
ceiling rises with it, and the `W` group's methods were written for the 2000-node
world, so `W3`, `W5`, `W6` and `W7` are owed re-runs against edges nobody has
walked to.

**`G8` is written and committed** at `ba92d52`, opened 2026-09-17: nothing in the
game styled a formspec or the hotbar, because `G3`'s deletion took Minetest
Game's and nothing replaced it, so every form was the engine's semi-transparent
default (`B57`). `cc_gui` is the fourth mod and ships in `v2.0.0`. `B57` **stays
open** until `P6` runs — nothing automated reaches a prepend.

**Everything else that is left is checking.** `dd83b99`
committed `A19`'s `plain` sky and the texture rework, and six checks passed
against that tree on 2026-09-09 — `R1`, `R2`, `R9`, `L1`, `L2` and `L4` — which
closes `A19` on `L4` and `A13` on `R9`. **`G3` and `G4` are now done and
checked**, and every open item in this file is either the author's or a release's.

**`W11` is the cheapest evidence outstanding**: the redrawn bedrock and barrier,
whose earlier pass was retired with the textures it described, and the one
unjudged part of `G7`. Behind it, in the order they cost least: `R4`'s re-run for
`B48`'s blast radius — **now also carrying the `vector3` `v2.0.2` re-pin and the
`codeblock` `09c708d` adoption, with `R9` beside it**, since nothing has been
played against either — `P3` and
`P4`, `P1`'s boot half, and the `W4`, `W8` and `W9` re-runs at the new depth. `R6` and `R7` are **unrunnable**, their subjects
deleted. `PLAYTEST.md` holds the list; it is not restated here.

**`A20` is settled and is not work.** Filed 2026-09-09 from a read-only trace —
`G3` took the hand's `groupcaps` with `mods/default`, so nothing in the game is
hand-diggable — and closed the same day as **won't fix**: the author declined a
game hand definition, and the obligation the finding created is discharged
because `R1` ran falsifiably under the temporary hand override and passed, with
`R2`'s drop half beside it. What it leaves is a setup cost on `R1`, `R4` and `R8`
for ever, written into `PLAYTEST.md`'s `R` preamble. Do not re-propose the hand.

Then `G5`, and it is the only thing on this file's critical path: **a tagged**
CodeBlock release. The pointer moved to `09c708d` on 2026-09-17 and that closed
`A7` — the mod deleted its duplicate sky block outright — but `09c708d` is a bare
commit, so `G5`'s first line stays open until CodeBlock's `v1.0.0` exists. `C22` closed on 2026-09-08 and
**`C21` on 2026-09-09**, by re-pinning `mods/vector3` to `v2.0.2` — so the whole
`C` series is closed and the licence and metadata questions are answered. The
`TODO.md` *fog distance* line is the author's and stays open; `viewing_range` is
deliberately a courtesy. **`AUDIT.md` had nothing open for a few hours on
2026-09-17 and now has `B57`.**

## Milestones

In work order, which is why `G6` and `G7` sit before `G5`: letters are allocated
when a milestone opens and never reused, and `G5` is shipping, so it stays last
whatever is opened after it.

| Milestone | Goal | State | Written | Checked |
|---|---|---|---|---|
| `G1` | Ship an honest, installable package | done | 5/5 | — |
| `G2` | Check the game, not the mod | done | 4/4 | — |
| `G3` | Delete what the game vendors | **done on both counts** — committed `50fd05f`, `W15`, `W16` and `R9` all pass | 5/5 | 4/4 |
| `G4` | Make the game's own mods behave | **done on both counts** — `A19` committed `dd83b99` and `L4` passes; `A7` closed 2026-09-17 with the `09c708d` adoption | 6/6 | 5/5 |
| `G6` | Bound the world | **done on both counts** | 5/5 | 6/6 |
| `G7` | Make the world something to be in | done, the texture rework committed `dd83b99`; `W11` still owed | 3/3 | 4/5 |
| `G8` | Give the interface the game's own style | written, committed `ba92d52`; ships in `v2.0.0` | 3/3 | 0/1 |
| `G5` | Adopt a tagged CodeBlock release and ship `v2.0.0` | started; **still no-go** 2026-09-22 — the push and CI blockers are discharged, the untagged pointer and the unrun checks are not | 2/7 | — |

Findings by milestone: `G1` (`C1`, `C2`, `C3`, `C4`, `C5`, `C15`, `C20`); `G2`
(`A14`, `B20`); `G3` (`B49`, `A13`); `G4` (`B47`, `B48`, `S8`, `A7`, `A8`,
`A19`); `G5`
(`C21`, `C22`); `G6` (`B50`); `G7` (none — an appearance the author wanted
changed is not a defect); `G8` (`B57`, and it **is** a defect — a styling the
game used to have and lost, not a look nobody chose). `C22` was turned up sideways by `G7` and is scheduled
under `G5`, because it is what makes the package honest to ship. **`A20` belongs
to no milestone**: it is a consequence of `G3` that costs evidence rather than
behaviour, no item was written for it, and it is won't fix.

### G1. Ship an honest, installable package — done (5/5)

Mostly the game's share of the mod's Phase 1; `C15` and `C20` landed much later
and sit here as the same subject.

- [x] Remove `max_minetest_version` from `game.conf`; `check_game.sh` now fails a
  reinstated one. (`C1` is the mod's counterpart)
- [x] Repoint image URLs from `master` to `main`. (`C2`)
- [x] Catalogue every bundled mod's licence in `THIRD-PARTY-LICENSES.md`, unify
  on AGPL-3.0-only, give the three `cc_*` mods their own. (`C3`, `C4`, `C5`)
- [x] Keep the release archive to what a player needs — 3.29 MB down to 1.93 MB
  zipped, verified by `P2`. `menu/*.png` stays; it is what the menu reads. (`C15`)
- [x] Write `CONTENTDB.md` for its own reader instead of shipping `README.md`
  verbatim, which broke six of ContentDB's page rules at once. (`C20`)

### G2. Check the game, not the mod — done (4/4)

A CI that checks what this repository alone can check. The game's share of the
mod's Phase 3.

- [x] Add `scripts/check_game.sh` and this repository's CI; the mod takes its own
  lint, specs and badge. (`A14`)
- [x] Delete the vendored WorldEdit fork, its arbitrary-code-execution module
  removed first, and the `formspecs` submodule. (`B20`)
- [x] Fix `gen_cdb_json.sh` producing different output by line ending.
- [x] Add `cc_mapgen` (flat clean world) and `cc_day` (permanent noon).

### G3. Delete what the game vendors — done, `50fd05f` (5/5), 4/4 checked

**The deferral ended, and the answer is deletion rather than trimming.**
CodeBlock at `fb75bc8` registers **its own 105 nodes** in `lib/nodes.lua` — 35
colours × solid/glass/lamp, `codeblock:<short>`, `codeblock:<short>_glass`,
`codeblock:<short>_lamp` — and `mods/codeblock/mod.conf` now reads
`depends = vector3` only. Their finding for it is `F11` and its reason is that
`default` and `wool` are Minetest Game's and ship with almost no other game. That
is exactly what `A13`'s deferral was waiting for, in as many words: *"CodeBlock is
expected to integrate the blocks it needs, at which point `default` is deleted
rather than trimmed."* So the 9,744-lines-for-106-nodes framing is spent, and what
is left is a removal plus two consequences.

The palette is no longer the game's contract at all: every block a program can
name is `codeblock:*`, so nothing here has to be kept in step with it.

**The 4/4 counts the four distinct checks these items name** — `R7`, `W15`, `W16`
and `R9` — all passing. `R7`'s pass is at `d16f9bb` and the check is now
**unrunnable**, its subjects deleted; that is what was seen and there is no way
to see it again.

- [x] Stop the world changing on its own — two `default` ABMs rewriting palette
  nodes, and ten saplings growing over what a program built. `R7` passes. (`B49`)
- [x] Delete `mods/default`, `mods/dye` and `mods/wool`. Committed `50fd05f`;
  `W15`, `W16` and `R9` all pass on 2026-09-09, so the drone against an
  all-`codeblock:*` palette is observed and this closes. (`A13`)
- [x] Register `mapgen_stone`, `mapgen_water_source` and
  `mapgen_river_water_source` in `cc_mapgen` — decision 1. `W16`.
- [x] Add `cc_mapgen:grass` and `cc_mapgen:dirt`, grass one layer thick at
  `mgflat_ground_level` and dirt below it — decision 2. `W15`.
- [x] Rewrite the `PLAYTEST.md` methods that name a `default` or `wool` node, and
  mark the two checks the deletion leaves unrunnable: `R1` and `R8` rewritten,
  `W15`, `W16` and `R9` added, `R6` and `R7` unrunnable.

**Two decisions, both 2026-09-08.**

1. **`cc_mapgen` supplies the three essential mapgen aliases**, because
   `mods/default/mapgen.lua:7-9` was the only thing in the tree registering them
   and `lua_api.md` lists all three as **essential for every non-V6 mapgen**.
   Nothing in the record anticipated this, and it is the real cost of the
   deletion. `mapgen_water_source` and `mapgen_river_water_source` alias to
   **`air`**: the surface stands at 128, far above `mgflat`'s water level, so no
   water is ever generated and there is nothing for a water node to be.
2. **The surface is grass over dirt, not stone.** Asked what the 128-node fill
   should be made of once `default:stone` was gone, the author answered *"a new
   grass-like block (green, light texture)"*, and asked whether that was the whole
   fill or a skin, *"grass above, dirt under"*. So `cc_mapgen:grass` is a **single
   top layer** at `mgflat_ground_level`, written by `mapgen_env.lua` because
   `mg_flags` carries `nobiomes` and the engine therefore has no top or filler
   node of its own, and `cc_mapgen:dirt` is the fill `mapgen_stone` aliases to.
   The bedrock floor at `y = 0` and the barrier wall are unchanged. This
   **reverses `G6` decision 1's "that fill is stone"** and the "no dirt and no
   grass until a program places some" claim that followed from it, which was true
   only while the world borrowed `default`'s nodes.

### G4. Make the game's own mods behave — done, `dd83b99` (6/6), 5/5 checked

The first playtest added three of these six and all three are fixed. **Reopened
on 2026-09-09 by `A19`, written, committed at `dd83b99` and checked the same
day**: one `set_sky` call declaring a `plain` sky, with `L4` passing on it. `A7`
**closed on 2026-09-17**, when the game adopted `codeblock` `09c708d` and the
duplicate was gone from the mod's source; its `L3` half was discharged on
2026-09-09, in the same sitting that found `A19`.

**The 5/5 counts the five written items' own checks**, one each: `B47` on `L1`,
`S8` on `R6` and `R4`, `A8` on `R2`, `B48` on `R8`, `A19` on `L4`. `A7` is the
sixth item, is written nowhere in this repository and is checkable here only
through `L3`, which passed before the removal it turns on. `R4`'s re-run for
`B48`'s blast radius is still owed and moves no fraction — it is a widening
control, not the check of an item.

- [x] `cc_day`: hide the sunrise texture too. `L1` passes. (`B47`)
- [x] Close the bookshelf, twice — the second fix denies every player-initiated
  inventory action. `R6` and `R4` both pass. (`S8`)
- [x] Stop `cc_security` clobbering two engine callbacks by direct assignment.
  Drops chain to the captured handler with an empty list; `R2` confirms it at
  `dd83b99`, both halves, its drop half run under `A20`'s hand override. The
  every-node table walk stays — decided 2026-09-09, and the finding is won't fix
  with no source change. `last_mod` stays untested by choice. (`A8`)
- [x] Strip six digging groups so the client stops predicting a dig. Committed
  `ec02760`; **`R8` passes** at `dd83b99`'s tree,
  engine 5.17.0, 2026-09-09: no cracking texture at any stage and no dig sound on
  a solid block, a glass one and `cc_mapgen:grass` with the barrier as control.
  Three limits on what that pass covers, in `R8`'s result line and `AUDIT.md`
  `B48`: the author's report was the single word *pass*, the instant-crack
  case is gone from the game for good, and **`R8` was not re-run with `A20`'s hand
  override**, so the pass does not separate the strip from the empty groupcaps.
  (`B48`)
- [x] Drop `cc_day`'s duplicate of a block `codeblock` already runs. **Done
  upstream and adopted 2026-09-17**: their `C18` finished as a **removal** at
  `3fa9d0c` and `6440ca0` — the block, the `codeblock_flat_sky` setting that had
  guarded it since `6fea453` and that setting's `settingtypes.txt` entry are all
  gone at `09c708d`. `cc_day` is the copy that survives and **not a line of this
  repository changed**, as predicted. `L3` passed on 2026-09-09, while the copy
  was merely inert; nothing has been played against `09c708d`. (`A7`)
- [x] `cc_day`: pin the sky's own colour and fog, so permanent noon reaches the
  horizon. One `set_sky{type = "plain", base_color = "#90d3f6"}`, committed
  `dd83b99`; **`L4` passes** on it, engine 5.17.0, 2026-09-09 — four `/time`
  positions including both blend peaks, a circle turned at each, indoors matching
  outdoors, and none of the three over-applied signals, so `#90d3f6` stays. Three
  limits are in `AUDIT.md` `A19`, and the first is that a one-word *pass* covered
  four steps and two halves. (`A19`)

**`A20` is won't fix, decided 2026-09-09 and recorded here so it is not
re-argued.** `A13`'s deletion took the hand's `groupcaps` with it, so nothing
in the game is hand-diggable and `PLAYTEST.md` `R1` **would have passed with
`cc_security` deleted outright**. Three things follow and none of them is work.
The credit above stands: `R2`'s drop half passed at `7dc764f` when `mods/default`
still supplied the hand, and **a run at its own commit is not retroactively
invalidated** — the same rule that retired `W8` and `W9` protects it. That
evidence is also **repeatable again**, because `R2` ran both halves at `dd83b99`
under the temporary hand override, which is what made `R1` falsifiable and is why
`R2` digging is now the in-world confirmation of `A20`'s diagnosis rather than a
trace of the engine's source. And `A20` never belonged to this item's fraction:
it costs evidence, not behaviour, and **no code change follows from it** — the
author declined the game's own hand definition, see *deliberately not doing*.
What is left is a setup, permanently: `R1`, `R4` and `R8` exercise nothing
without the override in `PLAYTEST.md`'s `R` preamble.

**The decision behind the `A19` item — 2026-09-09, and it was a choice between
three readings.** The author ran `L3` and its own half passed outright for the
first time; what remained was the distant horizon's luminosity changing between
`/time 5000` and `/time 10000` while the light level did not move. Put to them
explicitly, and **two alternatives were declined**: rewording `L1` and `L3` to
expect a residual horizon blend, on the ground that `cc_day`'s job is only the
light level and the sky objects; and recording the residual and moving on with no
finding at all. The ruling is that **the game should pin the sky colours**, so
this is a shortfall in `cc_day` and not a defect in a check's wording. Recorded
because *"not a defect at all"* is the natural reading — every sky object is gone
and the light is pinned — and someone reasoning from the code alone will
re-derive it and withdraw the finding.

**The approach taken, and the candidate ruled out on evidence, 2026-09-09.** A
`plain` sky, one line, `cc_day` from seven lines to eight. The other candidate —
pinning `sky_color`'s entries and keeping a `regular` gradient sky — is **ruled
out, not deferred**: the engine mixes a sun/moon tint into the horizon by up to
`0.5` and into the zenith by up to `0.25` on a curve of the time of day, gated on
a *client-side* setting a game cannot switch off, so one constant cannot hold
both still and the best available was a fixed horizon with the zenith still
drifting. The author has twice declined recording a residual, which is what
decides it. The paragraph this replaces counted six `sky_color` entries where
5.17.0 has ten and named pinning them as live; the mechanism and the correction
are `AUDIT.md` `A19`. **The cost is stated there too**: a plain sky is one flat
colour, so the day gradient and the `indoors` grey shift both go, and going back
to a gradient means the residual returns.

**Verification is `PLAYTEST.md` `L4`, written on 2026-09-09 for this fix and
passed the same day.** Neither `L1` nor `L3` asked about the horizon or the fog —
which is why the residual came back as a partial rather than a fail — so `L4` is
the only check in the project that reaches the subject, and there is nothing to
corroborate it with. The `TODO.md` *fog
distance* line was expected to ride on the same `set_sky` call and does not:
`fog_distance` is not a colour, it caps the client's viewing range, and that is
the author's decision rather than this item's.

### G6. Bound the world — done: 5/5 written at `60259dd`, 6/6 checked at 1024, four re-runs owed at 4096

**The first milestone here to be both**, and keeping the two states apart is the
point of this file. Shaped with the author on 2026-09-07 and built the same day.
`W4`–`W9` all pass at `60259dd`, which resolves `B50` on both of its routes. The
defect, the fix and its five **Keep** paragraphs are `AUDIT.md` `B50`. **The
default moved to 4096 on 2026-09-17** — decision 9 — which changes no code this
milestone wrote and does move every edge those checks were run against.

**The author's brief, verbatim, and it is what both `G6` and `G7` are built
against.** It was said in conversation when `G6` opened and written down only on
2026-09-07, by which time the conversation holding it had been compacted — see
decision 8.

> Start a new feature thinking : world limits.
> - They should stop the player to go further
> - They should be visible
> - They can be customized in the settings (map size)
> - World has a Floor no player can fall under, visible (blocks like "bedrock"?),
>   height of map configurable (mapgen?)

Four requirements: *stop the player* and *settings (map size)* are `G6`, done and
checked; *visible* and *configurable height* are `G7`, done and checked.
The *floor* being visible went the other way — see *deliberately not doing*.

- [x] Ship the bounded slab: a mapgen script clears everything below `y = 0`, lays
  the bedrock plane at `y = 0`, and fills the outermost generated columns to full
  height. `cc_mapgen` forces `mapgen_limit` onto the world with `override_meta`,
  because the engine stores it per world in `map_meta.txt`. (`B50`)
- [x] Default the world to **1024**. **Reversed on 2026-09-17 by decision 9**,
  which puts it back to 4096; the field was 2000 nodes on a side, not 2048.
- [x] Add a game-root `settingtypes.txt` declaring `mapgen_limit`. Extends `C7`
  rather than reversing it — see *deliberately not doing*.
- [x] Raise `min_minetest_version` 5.4 → **5.9**, the cost of the mapgen
  environment. **Recorded as 5.7 when decided, and wrong** — decision 4.
- [x] Clamp the player into the world box, in `cc_security` — the second route
  into `B50`, which neither the wall nor `diggable = false` touches. Committed
  `f5f2385`; where it puts the player was reversed at `60259dd` — decision 7.
  `W8` and `W9` pass there. (`B50`)

**Eight decisions, all 2026-09-07 — six while `G6` was shaped, the seventh after
playing it, the eighth about this record.**

1. **A thin slab, not a solid block.** Bedrock plane at `y = 0`, air below,
   `mgflat`'s ordinary fill above; keeping the fill and only adding walls
   generates thousands of nodes nobody reaches and leaves the floor invisible.
   That fill was **`default:stone`**, and **`G3` decision 2 replaced it** on
   2026-09-08 with `cc_mapgen:grass` over `cc_mapgen:dirt`. `mg_flags` carries
   `nobiomes` either way, so the engine supplies no top or filler node and
   `mapgen_env.lua` writes the grass layer by hand.
2. **One number, not two.** The world is ±N on every axis and N is
   `mapgen_limit`, because **CodeBlock already reads it** as the drone's bound. A
   second game-side number would let the drone build where the player cannot
   walk, and keeping the two in step would be a change in the other repository.
   Accepted cost: the world cannot be wide and shallow, since the floor is pinned
   at `y = 0`.
3. **A game-root `settingtypes.txt`**, for `mapgen_limit` only. A world size is
   the game's own subject, exactly like the light and the restrictions. **The
   file's ownership was settled on 2026-09-08 and it is `code-expert`'s**, in the
   same sense as `game.conf` and `minetest.conf`: it declares `mapgen_limit` and
   `mgflat_ground_level` and nothing else. It appeared in no agent's scope list
   because `G6` created it *after* those lists were written, so the gap was an
   omission and not an exclusion — `code-expert` raised it rather than granting
   itself the permission, which is the behaviour the split exists to produce.
   Written into `CLAUDE.md`'s agent table; `.claude/agents/project-manager.md`
   already named it in both of its lists.
4. **The mapgen environment, not the main thread**, and therefore
   `min_minetest_version` **5.9**. Taken as 5.7 on the author's instruction and
   **corrected the same day on evidence**: `register_mapgen_script` is absent from
   the shipped `lua_api` at 5.7.0 and 5.8.0 and present at 5.9.0, so below 5.9 the
   call is `nil` and the game does not start. Recorded rather than overwritten,
   because a number silently changed is one the next reader re-derives. `C21`'s
   gap widened with it, to four minor versions; the **gap** closed on 2026-09-09
   with the `vector3` re-pin, the **floor** did not.
5. **Default 1024.** 256 puts the walls inside `viewing_range = 300` so they are
   always in sight; 4096's walls are seven minutes' walk away and therefore
   theoretical. **Reversed on 2026-09-17 — decision 9.**
6. **Clamp the player, in `cc_security`.** `cc_mapgen:bedrock` is an ordinary node
   to a program, so `remove` deletes a floor tile and a player walks into unlit
   air below `y = 0`. Ruled by the author: one rule, in the mod whose job is
   already what a player may do. The rejected alternatives are under *deliberately
   not doing*.
7. **The rescue keeps the player where they were; spawn is only the fallback.**
   Asked for by the author after playing, verbatim: *"instead of returning to
   spawn point I just want the player to be placed at the same place but on a new
   block avoiding it to fall. Also, if the player would be blocked on stone, I
   need him teleported on the nearest block free above him."* Being sent to the
   origin because you fell into a hole beside what you were building is a
   punishment, and the drone is what dug the hole. **This reverses decision 6's
   destination, not decision 6.** One algorithm answers both halves: clamp the
   column inside the wall, make the floor whole under it, scan up for the first
   height where the player fits. Committed `60259dd`. The trade it accepts — you
   land at the bottom of your own shaft — is sound because **from a shaft you can
   point the drone at its wall and program your way out, and from an endless fall
   you cannot.** The scan gives up 64 nodes above `mgflat_ground_level`, so a
   solid 72-node pillar falls back to spawn; `W9` case 4 is its check.
8. **The unwritten brief gets no finding id.** A requirement that drove two
   milestones and existed only in a conversation is a real failure and exactly the
   one this record exists to prevent — but ids here are `B`, `S`, `C`, `A` and all
   four describe *the game*. This is a defect in the record, and the settled
   precedent points the same way: a wrong check is fixed in `PLAYTEST.md` and gets
   no id. The fix is the quotation above. **The guidance was already correct and
   simply not followed**, so nothing was added to `CLAUDE.md` for it. *What would
   change it:* the same failure recurring, which would make it a pattern.

**A ninth decision, 2026-09-17, and it reverses the fifth.**

9. **Default 4096, not 1024.** Asked for by the author. Decision 5 chose 1024 to
   keep the walls reachable; the world it produced was judged too small to build
   in, and a wall nobody walks to costs nothing. **Three consequences, none
   separable from it.** The field goes from 2000 to **8080 nodes on a side** —
   the wall stands at -4032 and 4047, not ±4096, because only whole mapchunks
   inside the limit are generated and the shortfall is one mapchunk however large
   the world is. `mapgen_limit` bounds the **vertical** axis too, so the buildable
   ceiling rises from about 1007 to about 4047 and the barrier runs that high in
   an edge chunk. And a world already played at 1024 keeps its old barrier shell
   as real nodes when the override moves its edge out — see *what ships broken*.
   Derived from the engine's `get_mapgen_edges` at 5.9.0 rather than from the API
   document, which says only *"a little short"*; `settingtypes.txt` carries the
   derivation. **No finding**: nothing in committed code was wrong.

### G7. Make the world something to be in — done, `d6e4a12` and `dd83b99`, 4/5 checked

Opened 2026-09-07 after `G6` closed, and **no finding is allocated for it**: the
wall `G6` built is a correct barrier and `W5` proves it stands. What the author
wanted changed is what it *looks* like, which is a new goal. Widened the same day
from one item to three, on the grounds that all three are appearance-and-feel,
none is a defect, and they are one tree that has to be checked together.
**`W10` and `W12`–`W14` pass at `3479e25` on 2026-09-08**, reported by the author
from one sitting; the engine version was not given, and the report was one word
per check rather than a part-by-part account. `W11` passed in that sitting too and
its pass was **retired** when the textures were redrawn — see *The texture
rework*.

- [x] Split the bounds in two: `cc_mapgen:bedrock` stays the floor at `y = 0`,
  including the outermost column at that layer so the wall stands on a one-node
  opaque skirt; a new `cc_mapgen:barrier` is the wall above it. `W10`.
- [x] Ship the game's own 16×16 textures for both nodes, in
  `mods/cc_mapgen/textures/`. Asked for by the author — the bedrock should be
  *"more black like in minecraft"*, and the borrowed obsidian is blue-tinted.
  Both were **redrawn on 2026-09-08**, so the six-grey mottle and the wrapping
  blur this line used to describe are gone; the construction that replaced them
  is *The texture rework* below. `W11` is the check and its pass is retired.
- [x] Raise `mgflat_ground_level` 8 → **128** and declare it as a setting,
  mirroring `mapgen_limit`. This is the fourth line of the brief. `W12`, `W13`,
  `W14`.

**The texture rework — decided 2026-09-08, after the author played `50fd05f`,
and committed at `dd83b99` on 2026-09-09** with `scripts/gen_textures.py` beside
the four PNGs. `W15` passes on the grass and dirt; **`W11` is the bedrock and
barrier and is the one thing in `G7` nobody has looked at**, its earlier pass
retired with the textures it described.
The world worked and the **look** was rejected. Given a Soothing32 screenshot, the
directive was verbatim: *"soothing has less features, less grain and reduces
palette. Adapt grass, dirt and bedrock."* So all three were redrawn, and the
barrier's border with them.

**The style is a flat base colour plus a handful of sparse discrete specks** —
three or four colours in a 16×16 tile, 95–96% of pixels identical, and **no
per-pixel jitter anywhere**. Seamlessness is by construction: every cell of a
speck is placed modulo the tile, and a speck is refused if it touches a non-base
pixel, so clusters cannot accumulate into patches. `cc_mapgen:dirt` declares two
accents and draws only one, so it is two realised colours against a declared
three — the arrangement the author approved, not an omission. The barrier's border
is now a **single tone**; it had been dithered between two near-blacks eight steps
apart, which is invisible at that separation and is the rejected construction in
miniature.

**Why the first attempt missed, and it is a design fact rather than a mistake to
log.** The three textures were **continuous value-noise fields** of the right
palette. Noise is precisely what is being rejected, so the temptation next
time — adding jitter, or raising the speck count until the specks meet — is
exactly the wrong move and turns the tile back into the thing that was thrown
out. *What would change it:* the author asking for a richer or more detailed
surface, which would be a new brief and not a refinement of this one.

**`scripts/gen_textures.py` draws all four**, and it is **neither a gate nor
something CI runs** — the PNGs are committed artefacts, `check_game.sh` does not
know about the script and luacheck does not read Python, so nothing fails if it is
never run again. It exists because the palettes and the seeds otherwise rot in a
comment and because the author iterated on this look three times in one sitting.
Two runs are byte-identical and regenerating leaves the committed PNGs unchanged,
verified 2026-09-08. `code-expert` had declined a generator earlier on the sound
ground that generating two of four textures would be asymmetric; that reason is
spent now three of four share one algorithm.

**Nothing here is a finding.** No defect was found in committed code — the
textures rendered, the world was correct, and what changed is an appearance the
author wanted different, which is `G7`'s whole subject. What it costs the record
is `W11`'s pass, retired, and a look criterion added to `W15`.

**Three things a later change would re-break.** The barrier's drawtype is plain
`glasslike` and must stay so — `glasslike_framed` draws its faces from a second
tile and leaves the wall all but invisible, and `glasslike_framed_optional`
follows a client-side setting this game cannot decide. `paramtype = "light"` and
`sunlight_propagates` come as a pair, because the engine derives
`light_propagates` from `paramtype`, which defaults to `"none"`; without them a
see-through wall casts a shadow band with no visible cause. And
`mgflat_ground_level` must be forced with `override_meta`, because
`MapgenFlatParams::writeParams` writes every `mgflat_*` key into a world's
`map_meta.txt` — without the force an existing world keeps its surface for ever.
`W10` catches the first two by sight; `W13` is the third, and `code-expert` calls
it the thing most likely to be wrong.

**One real defect was introduced and caught inside this change, and it gets no
id.** `cc_security` derived both its spawn fallback and its scan bound from
`(ground or 8)`, which became wrong the moment the default was 128 — a rescued
player would have gone to `y = 9`, inside 120 nodes of stone. Collapsed to a
single `or 128`. It was never committed, so it is the change being wrong and its
record is this line; `W14` is what would have caught it in a world. Third
application of the same rule; `AUDIT.md` names all three.

**The media licence — decided 2026-09-08 by the author, and it settles `C22`
too.** The game's **code stays AGPL-3.0-only and all of its own media is
CC BY-SA 4.0**: `G7`'s two `cc_mapgen` textures, which had shipped AGPL-3.0-only
to keep the game single-licence, and the three `menu/*.png` that had no stated
licence at all. One question, one answer, because the two are the same question
and the choice is the author's — it is about what other people may do with the
game's art. CC BY-SA 4.0 is the convention for Luanti game art and lets another
game reuse it under the same terms; the cost accepted is that the package is no
longer single-licence, so `THIRD-PARTY-LICENSES.md`'s `cc_*` row now has to
qualify code against media.

Three things a later change would get wrong. **The machine-readable spelling is
`CC-BY-SA-4.0`, hyphenated** — it is ContentDB's own name, listed with
`is_foss: true` at `https://content.luanti.org/api/licenses/`, and a name
ContentDB does not know is rejected at its end with nothing failing locally; the
long form is for prose only. **The root `LICENSE` stays bare** — see
*deliberately not doing*. And **nothing enforces any of it**: no check reads a
media file, so a texture or menu image added with no licence line fails no gate.
That is `AUDIT.md` `C22`'s `Keep`, and the wanted check is a `TODO.md` line.

### G8. Give the interface the game's own style — written, `ba92d52` (3/3), 0/1 checked

**A new milestone rather than a reopened `G7`.** `G7`'s goal is the *world* — the
ground, the wall, the depth — and it is done and 4/5 checked; this is the
*interface*, a new mod and a new subject, so it takes the next letter. `G5` stays
last because it is shipping.

The defect, the evidence and why no gate could see it are `AUDIT.md` `B57`;
`PLAYTEST.md` `P6` is the only check that reaches it, and it names the form to
open because a prepend is invisible outside one.

- [x] Add `cc_gui`: a formspec prepend and the two hotbar images, set per player
  from `register_on_joinplayer`. Committed `ba92d52`. (`B57`)
- [x] Draw the nine-slice panel and the hotbar textures in
  `scripts/gen_textures.py`, in `G7`'s flat-with-flecks style — three 64×64 PNGs,
  and `cc_gui` introduces no colour of its own. (`B57`)
- [x] Carry what a fourth mod drags — all `code-expert`'s: a `mod.conf`, its own
  `license.txt`, a `THIRD-PARTY-LICENSES.md` row, `check_game.sh`'s declared-mod
  count and `.gitattributes`. The media licence is **CC BY-SA 4.0**,
  machine-readable `CC-BY-SA-4.0`. `check_game.sh` needed no edit — it counts
  `mods/*/` rather than carrying a number — and the three PNGs need no
  `export-ignore` line, because they must ship. (`C22`, `C15`)

**`.gitattributes` is the reverse of the usual `C15` question here.** The new
PNGs must **ship**, so they need no `export-ignore` line; any art *source* added
beside them does. `P2` is what would catch either mistake and it is owed as soon
as the files are tracked.

**The author's three decisions, 2026-09-17.**

1. **Drawn in the game's own flat style** — colours plus a nine-slice panel and
   hotbar textures, from `scripts/gen_textures.py`, so the interface and the world
   read as one thing. Two alternatives were rejected; see *deliberately not doing*.
2. **A fourth mod, `cc_gui`**, self-enclosed and named for what it does, which is
   how the other three are arranged. Extending `cc_day` was rejected.
3. **No setting.** A server owner who wants another look sets a prepend from their
   own mod, which overrides this one.

**A fourth decision, 2026-09-22: `G8` ships with `v2.0.0`.** It was open until
then, under a rule that `G8` shipped only if committed and if `P2` and `P6` had
both run before the tag. The author has settled the question and **not the two
checks**: they are now **release blockers on `G5`** rather than a condition on
inclusion. `P2` because `cc_gui` adds four tracked files to the archive and
nothing in CI reads `.gitattributes` (`C15`); `P6` because a prepend is invisible
to both gates and it is the only check that reaches one — and `B57` stays open
until it runs. The argument that carried it: a visible regression every player
meets at the first form they open.

**It is billed as a player-facing change**, decided here 2026-09-22 rather than
left as one clause: `CONTENTDB.md` carries it in *Features* and in *Recent
changes*, `README.md` in its opening paragraph, and `CHANGELOG.md` under
*Changed*. A style every player meets before they write a line of code was
otherwise described nowhere a player reads.

### G5. Adopt a tagged CodeBlock release and ship v2.0.0 — started (2/7), no-go

The game's own last step, and it comes after the mod has a 1.0.0 to adopt. The
`release-codecube` skill owns the procedure and `release-check` gates it. **The
game's number and the mod's are not the same number**: the game ships `v2.0.0`
and the release it adopts is CodeBlock `1.0.0`.

**Two decisions, both the author's, both 2026-09-22.**

1. **The release is `v2.0.0`.** `v1.0.0`, `v1.0.1` and `v1.0.2` are tagged and
    pushed and `v1.0.2` is what ContentDB serves, so the `v1.0.0` this milestone
    was written to cut cannot happen; major because the release breaks saved
    player programs and existing worlds. It is written in `CHANGELOG.md`'s
    heading and here, and nowhere else — no file in the tree carries a version
    string, `game.conf` included.
2. **`dev_state` becomes `ACTIVELY_DEVELOPED`**, from `BETA`, matching
    CodeBlock's. The value is in `scripts/gen_cdb_json.sh` and reaches ContentDB
    through the generated `.cdb.json`; the live page keeps `BETA` until the next
    upload.

- [ ] Move `mods/codeblock` to a **tagged** release. **Still open after the
  2026-09-17 move to `09c708d`**, which is a bare commit: no CodeBlock `v1.0.0`
  exists yet,
  locally or on the remote. See *which release is adopted* below for why that
  move was taken anyway. **In the same piece of work, write the `CHANGELOG.md`
  *Changed* entry naming the release adopted**: it said the mod was adopted as a
  tagged release rather than followed commit by commit, and it was deleted on
  2026-09-09 because the pointer was a commit off `master`. It is true only once
  this line is done, so it is written then and not before — it was **not** written
  for `09c708d`. What `CHANGELOG.md` carries meanwhile, corrected 2026-09-22, is
  the true weaker statement: the bundled mod is a **development build** ahead of
  its newest release `v0.7.3`, and its changes break saved programs. Replace that
  sentence when the pointer names a tag.
- [x] State the licence for the game's media, in `menu/license.txt`,
  `mods/cc_mapgen/license.txt`, `THIRD-PARTY-LICENSES.md` and
  `scripts/gen_cdb_json.sh`. Decided 2026-09-08 — see *The media licence* under
  `G7`. (`C22`)
- [x] Re-pin `mods/vector3` to `v2.0.2` (`fc8a5b8`), from `v1.5`, on the author's
  instruction 2026-09-09 — the release states `min_minetest_version = 5.3` and no
  ceiling. (`C21`)
- [ ] Update `README.md`, `CHANGELOG.md` and `CONTENTDB.md` in the same commit,
  and regenerate `.cdb.json` — `check_game.sh` diffs it.
- [ ] Run `check_game.sh`, `P1`, **`P2` and `P6`**, tag `v2.0.0` on `main`,
  upload, then read the page in-game (`P5`). **`P2` and `P6` are blockers, not
  nice-to-haves** — they are what `G8`'s inclusion costs, and `P6` is the only
  thing that would close `B57`.
- [ ] Push, and get a CI run on the commit that is tagged. **Its substance is
  done and it stays open on its own wording**: `main` is pushed and **CI is green
  on `49c7f75`**, event `push`, 2026-09-22T13:27:15Z, both jobs `success` read
  individually. No tag exists, so no *tagged* commit has been built. It closes the
  moment `v2.0.0` is cut on `49c7f75` with nothing pushed after it; any further
  commit re-opens the gap it names.
- [ ] Merge to `main` and tag there. **Merge half done**: PR #1
  (`g6-world-limits` → `main`) merged on 2026-09-22 as `49c7f75`, local `main`
  fast-forwarded `99117bf..49c7f75` and is in sync with `origin/main`. The tag
  half is not done.

**`release-check` ran on 2026-09-22 against the working tree at `0a605a3` and
answered no-go.** Its blockers, recorded here because they are facts about this
release and not about any one finding:

- **Nothing was pushed** when the gate ran: `g6-world-limits` was 11 commits
  ahead of its remote, local `main` 10 ahead of `origin/main` at `35fa2a1`, and 7
  files uncommitted. **Discharged later the same day**: the 8 modified files were
  committed as `7609d09`, the branch was pushed (`5777dc0..7609d09`), and PR #1
  was merged as `49c7f75`, which `main` fast-forwarded to. `main` is in sync with
  `origin/main` and the tree is clean, so nothing that would be tagged exists only
  on this machine.
- **CI had never run on the release commit, and now has.** When the gate ran, no
  run existed for `0a605a3` or for any of the 9 commits after `dd83b99`; the
  newest codecube run of any kind was `main` at `35fa2a1`, 2026-09-01, and the
  branch push could not produce one because `.github/workflows/ci.yml` triggers
  on a push to `main`, a pull request or `workflow_dispatch`. **The merge produced
  both routes.** Green on `99117bf`, event `pull_request`, 2026-09-22T13:25:45Z,
  so the PR gated the merge; green on `49c7f75`, event `push`, branch `main`,
  2026-09-22T13:27:15Z. Both jobs — `game assembles` and `luacheck (game mods)` —
  read individually as `success` rather than trusting the run conclusion. **This
  proves the game assembles and nothing about how it behaves.**
- **Behaviour is unobserved at the release commit.** The newest `PLAYTEST.md`
  result names `dd83b99`, and `cc_gui` has no result at all — which is `P6`, the
  blocker above, seen from the evidence side.
- **The ContentDB upload webhook could not be checked**, because `gh` is not
  installed on this machine. **Treat the upload as manual** until someone
  confirms otherwise.

**Two gaps the same run closed, and both are worth keeping.** `luacheck`'s
`mods/cc_*/` glob now picks up `cc_gui` — 5 files, 0 warnings, 0 errors — so the
fourth mod is inside the lint scope the `TODO.md` line worries about. And from a
**clean clone**, `git fetch origin <hash>` succeeds for **both** submodule
pointers, `09c708d` and `fc8a5b8`, so no `reference is not a tree` awaits anyone.
That narrows `P1`'s clone half to the rest of a recursive clone and does not
discharge it.

**The merge changed what `P1` can reach, and nobody has run it.** When the gate
ran, a fresh recursive clone came up at `35fa2a1` — the previous release —
because the candidate was unpushed, so no clone could populate at the intended
pointers however the fetch behaved. Since `49c7f75` is on origin a fresh
recursive clone reaches the candidate and its two submodule pointers directly.
**That is a change in what the check can reach, not a run of it**: `P1` is still
`partial` and its boot half is still unrun.

## Which CodeBlock release is adopted

**`09c708d` since 2026-09-17, and it is a commit off `master`, not a tag.** The
policy is that the pointer names the release this game has *adopted*, so lagging
upstream is correct; this is a different thing — the pointer is **off the release
track**, not merely behind it. Upstream's newest tag is **`v0.7.3`**, on the
remote as well as locally, and **no CodeBlock `v1.0.0` exists yet**. Nothing is broken by
it: `09c708d` is on `origin/master` and fetchable, and both gates are green on it.
`G5`'s first line is where it goes back on the track. Read both numbers from
`git ls-tree HEAD mods/codeblock` and the submodule's own tags —
`git ls-remote --tags origin` inside it — **never from upstream's `HEAD`**.

**The two-step is the author's decision, taken 2026-09-17.** CodeBlock is at
`09c708d` and will be tagged CodeBlock `v1.0.0` and released soon, and the author wants the
two released together; adopting the bare commit now and re-pointing at the tag
when it exists was chosen over waiting. So the pointer is deliberately off the
release track for a shorter time, and `G5`'s first line and the `CHANGELOG.md`
entry it owes both stay open — that entry is true only once the pointer names a
tag.

**What the move bought, and what it did not.** `A7` is resolved by it: upstream
removed the duplicate sky block, its `codeblock_flat_sky` setting and that
setting's `settingtypes.txt` entry, so `cc_day` is the only thing in the package
setting the sky. Nothing else in this repository changed. **Nothing has been
played against `09c708d`** — `R4` and `R9` are the game's share and both name
`dd83b99` — and **CodeBlock's CI on `09c708d` is unchecked** from here; the two
repositories go red independently.

**Corrected 2026-09-09: this section named `2647228` for two passes and that
stopped being true at `50fd05f`**, which committed `fb75bc8` with the `G3`
deletion; the paragraph describing the pointer as a deliberately unstaged working
tree went with it. `P1`'s clone half passed on `2647228` at `8b27f2f` and **has
not been re-run across either move since**. The fetch itself is now settled
separately: `release-check` fetched **both** pointers by hash into a clean clone
on 2026-09-22 and both succeeded, so no `reference is not a tree` awaits anyone.
What `P1` still owes is the rest of a fresh recursive clone.

**Deleted from `CHANGELOG.md` on 2026-09-09:** a *Changed* entry claiming the mod
was already adopted as a tagged release rather than followed commit by commit.
The pointer above shows it had not happened, the file's boxes mean done or known
limitation and never pending, and it forbids an entry for work in progress. The
obligation to write that entry sits on `G5`'s first line, where it will be read
when the pointer names a tag.

**The other submodule is on a tag: `mods/vector3` at `v2.0.2` (`fc8a5b8`) since
2026-09-09**, moved from `v1.5` (`16621648`) on the author's instruction and
staged with the record edits that close `C21`. Upstream is
`github.com/gigaturbo/vector3`, and `v2.0.2` is its **newest tag** — read from
the tags API on 2026-09-09 — so this pointer is neither behind nor off the track. `P1`'s clone half has not been re-run since it
moved either, and it is the same gap as the paragraph above: nothing has confirmed
a fresh recursive clone can fetch **either** pointer.

## What ships broken

- **A rescued player is left standing in the shaft they fell down.** The design,
  not a defect — decision 7. Getting out needs a working program.
- **A player whose own column is solid for 72 nodes is still sent to spawn.**
  Accepted with decision 7; `W9` case 4 is its check.
- **A world played at `mapgen_limit = 1024` ends up with a wall inside a wall.**
  `cc_mapgen` forces the setting with `override_meta = true`, so opening such a
  world moves its edge out to 4096 and the engine generates to the new one, while
  the old barrier shell at about ±1000 stays in the map as real nodes. A program
  can clear it; a player cannot dig it. Nobody is trapped — the rescue reads the
  new edges. **It reaches no player**: 1024 was never released, so only an
  unreleased checkout produces such a world. Decision 9.
- **The wall exists only in chunks generated after `G6`.** It is written by the
  mapgen callback, so a pre-existing world is bounded only where it has not been
  visited. `W7` confirms the *limit* moves; the missing wall is what nothing
  covers.
- **An existing world's surface moves only where it has not been generated.** Same
  mechanism, from `G7`, and `G3`'s change of material rides on it: a world played
  at ground level 8, or one played on stone, gets a step where the old ground meets
  the new and keeps its old material behind it. `W13` is the nearest check.
- **No check reads a media file, so a texture or menu image added with no licence
  line fails nothing** — locally or in CI. `C22` closed the gap the game has;
  this is the silence that let it open, and it is `C15`'s hazard in a second
  form. Not a finding: nothing in committed code is wrong.
- **`mapgen_limit` appears twice in the advanced settings menu** — under Mapgen
  from builtin and under Content: Games → Codecube. Both write the same key, and
  since decision 9 both show 4096, so the duplication is now silent rather than
  contradictory. Inherent to decision 3; the alternative was not declaring it.
- **`R6` and `R7` become unrunnable with the deletion.** Both pass, and both name
  a node only `default` registered — a bookshelf and a dirt/grass/sapling patch.
  Their passes stand as what was seen; there is no way to re-run either. `S8`'s
  residue goes with the bookshelf and `B49`'s fix stops being exercised by
  anything. (`S8`, `B49`)
- **`.gitattributes` decides what reaches a player and no CI checks it.** `P2` is
  the only thing that would catch a file shipping by accident, and it has to be
  re-run every time a tracked file is added — `G6` added two and `G7` a directory
  and two more. (`C15`)
- **A bookshelf still opens and shows the player their own inventory.** Nothing
  can be moved and `R6` confirms it, but the formspec is metadata on the placed
  node, not a field `cc_security` can override away. **Gone with `G3`'s deletion
  at `50fd05f`**: no node in the game carries a formspec of its own, and `R6` is
  unrunnable for the same reason. (`S8`)
- **Nothing in the game is hand-diggable, so the digging restriction can only be
  checked with a setup.** `G3` deleted the only hand
  override in the tree and the engine's own hand has empty `groupcaps`, so
  `PLAYTEST.md` `R1` would pass with `cc_security` deleted outright. Not a defect
  a player meets — every node was already undiggable — and **`R1` has now been run
  falsifiably**, under the temporary hand override, and passed on 2026-09-09. What
  ships is the permanent cost: `R1`, `R4` and `R8` exercise nothing unless whoever
  runs them installs that override first. The game is **deliberately not**
  shipping a hand definition, and the finding is **won't fix**, not open. (`A20`)
- **The dig-animation strip's fastest case can never be checked again, and its
  pass has two explanations.** The fix
  itself is seen: `R8` passes on 2026-09-09. But **no `dig_immediate` node is
  left in the game after `G3`**, so the instant-crack case — the one a partial
  group strip would still show — is unreproducible for good. And `R8` was **not**
  re-run with `A20`'s hand override, which is the only thing that would separate
  the strip from the empty groupcaps; nobody has done it. Not a defect; a
  permanent gap and an unresolved one in the evidence. (`B48`, `A20`)
- **`sunrise_visible = false` is no longer observable in any world.** `A19`'s
  `plain` sky draws no sky mesh at all, so there is nothing for a sunrise glow to
  be painted on and no future run can distinguish the fix working from the sky
  type hiding it. Its only evidence is `L1`'s pass at `b9bf82b` and `L3`'s
  retained 2026-09-01 `partial`, both under a `"regular"` sky, which is why that
  line is kept. Not a defect; the call stays in `cc_day` so a return to
  `"regular"` cannot silently restore the glow. (`B47`, `A19`)
- **Untested by choice: that `last_mod` is honoured at all.** Confirming it needs
  a second mod assigning the same globals and none ships. Decided 2026-09-02;
  recorded so it does not read as an oversight. (`A8`)
- The game has no test suite and nothing automated reaches its behaviour. What is
  proven is what `PLAYTEST.md` records as run, and no more.
- Everything in the mod's "what ships broken" list ships in the game too.

## Deliberately not doing

Each entry names what would change it. An omission with no recorded reason gets
proposed again.

### Scope — what is the mod's, not the game's

- **Trimming vendored `default` down to the palette — this entry is spent and is
  kept only as the record of why it stood.** It was declined 2026-09-02 and
  re-declined 2026-09-07, both times because CodeBlock was expected to take the
  blocks, and its *what would change it* line read "CodeBlock deciding **not** to
  take the blocks". **CodeBlock took them** (`F11`, at `fb75bc8`), so the question
  is closed the other way and the work is a deletion under `G3` rather than an
  omission here. (`A13`)
- **Setting `codeblock_flat_sky = true` in the game's `minetest.conf` — this
  entry is spent and is kept only as the record of why it stood.** Declined
  2026-09-08 against upstream's own instruction: both CodeBlock's `ROADMAP.md`
  and its `CHANGELOG.md` told a game bundling it to set the flag, and doing so
  would have restored the exact duplicate `A7` existed to remove, in the version
  lacking `B47`'s `sunrise_visible = false`. **There is no such setting at
  `09c708d`** — upstream removed the block, the flag and its `settingtypes.txt`
  entry — so the question is closed the other way and `A7` is resolved. What
  survives is the rule behind it, in `AUDIT.md` `A7`'s **Keep**: `cc_day` is the
  only thing that sets the sky. (`A7`)
- **A `PLAYTEST.md` entry for the `vector3` `v2.0.2` re-pin.** Decided
  2026-09-09. A major version of a hard dependency wants world evidence, but the
  two things `v2.0` changed — a frozen constant raising `read only`, and a bad
  argument raising `format error` where a `from*` constructor returned `nil` —
  are reached through `vector` in a player's program, and this document's
  checklist *"does not re-check the drone, the editor, the sandbox or the API"*
  in its own words. That evidence is the mod's `PLAYTEST.md`. The game's share is
  already written: `R4`, *the drone can still build*, and `R9`, *the drone places
  and removes CodeBlock's own blocks* — both owed a re-run at the commit that
  carries the pointer, which is the whole of the cost. *What would change it:* a
  break that shows in the world rather than in a program. (`C21`)
- **A `settingtypes.txt` entry for anything the drone does.** Every drone setting
  is CodeBlock's, and CodeBlock is its own ContentDB package. `G6` adds a
  game-root file for `mapgen_limit` **only**, which extends this rather than
  reversing it: a world size is the game's own subject. (`C7`)
- **Asking CodeBlock to refuse writes to `cc_mapgen:bedrock`.** Declined *for
  now*, 2026-09-07, on timing rather than principle — nothing would land until a
  release is adopted, and `G6` would ship with the hole. **It remains the cleaner
  boundary** and is a deferred option, not a novelty to re-propose.
- **Allocating a `B`/`S`/`C`/`A` id here for a defect in CodeBlock.** Reading the
  mod turned up two real ones on 2026-09-07; ids are shared across the two
  records, so allocating one here would put the mod's work in the game's counts.
  They are `TODO.md` lines to raise upstream. *What would change it:* a defect in
  the *game* caused by the mod's behaviour.
- **Duplicating CodeBlock's lint and tests here.** It has its own repo, CI and
  `.luacheckrc`. The two go red independently — check the repository you changed.
- **Restyling or linting `default`, `dye` and `wool`.** Vendored from Minetest
  Game; CI lints only the three `cc_*` mods. **Moot since `50fd05f`** — all three
  are deleted and the `.luacheckrc` excludes went with them.
- **Bumping the submodule on every mod commit.** The pointer names the release
  this game has adopted. Moving it is a decision, taken with the documentation
  update that goes with it.

### The shape of the world

- **Shipping the game's own hand definition.** Declined by the author on
  2026-09-09, on the day `A20` was filed, and **not to be re-litigated**. Since
  `G3` deleted `mods/default/tools.lua` the engine's builtin hand has empty
  `groupcaps`, so **no node in the game is hand-diggable at all** and a left-click
  gives no crack, no sound and no message. Three grounds. That silence is *truer*
  feedback than the animation it replaced — a crack that plays and then refuses is
  precisely what `B48` was filed to remove, and registering a hand would restore
  the feedback **and** the misleading crack. Nothing a player can reach is worse
  than before, because every node was already undiggable. And the cost is
  accepted **and now paid once**: `PLAYTEST.md` `R1` and `R2`'s drop half need a
  **temporary** hand override to be runnable, written into that document's `R`
  preamble as setup rather than into the game, and both passed under it at
  `dd83b99` on 2026-09-09. `A20` is **won't fix** on the strength of this
  decision. *What would change it:* the author wanting a
  left-click to say something, at which point `B48` returns and `cc_security`'s
  group strip is the only thing holding it. (`A20`, `B48`)
- **Lowering `mgflat_ground_level` so the bedrock floor is visible.** Put to the
  author on 2026-09-07 as `G6`'s one open question, and **answered the same day by
  the number moving the other way**: they asked for 128, so the plane is a hundred
  and twenty-eight nodes down instead of eight — more out of sight, not less. A
  world you dig deep into was wanted more than a floor you can look at. *What
  would change it:* the author saying the floor should be seen. They have not been
  asked since choosing 128, so this is inferred from an instruction rather than
  stated, and it is the weaker kind of decision.
- **Lowering 128 to save generated volume.** A cost of sixteen times the solid
  volume was raised in conversation and **is not real**:
  `MapgenFlat::generateTerrain` writes every node of a mapchunk whatever the
  ground level is, so emerge time is identical, and the blocks between `y = 0` and
  128 were already generated and stored as uniform air. Uniform air and uniform
  stone both compress to tens of bytes. Recorded so it is not re-raised.
- **Making the bedrock floor's `y` configurable.** Not proposed and not built. The
  floor stays pinned at `y = 0` by decision 2; what `G7` makes configurable is the
  *surface* above it, which is the same freedom by the other end and costs no
  second number.
- **A noise-textured ground.** Declined 2026-09-08 after the author played
  `50fd05f`: grass, dirt and bedrock were drawn as continuous value-noise fields
  of the right palette and rejected as grain. The style that replaced them, and
  what would change it, are *The texture rework* under `G7`.
- **A gradient sky, and an `indoors` shift with it.** Ruled out 2026-09-09 on
  evidence, not taste: a `regular` sky's horizon and zenith are both mixed with a
  time-of-day tint no game-side colour can cancel, so keeping the gradient means
  keeping a residual blend, and the author has twice declined recording one.
  `cc_day` declares a `plain` sky, which is one flat colour for the sky and the
  fog together — so the day gradient is gone and so is the grey shift a player
  used to see when standing inside a structure. *What would change it:* the
  engine gating `directional_colored_fog` server-side, or the author preferring a
  gradient with a drifting horizon. The lever meanwhile is one hex constant.
  (`A19`)
- **A setting for the sky's colour.** Not added with `A19`'s fix, 2026-09-09. The
  game already imposes permanent noon with no setting, and a server owner handed
  a free `ColorSpec` could break the invariant the fix exists for.
- **A ceiling on the world.** Rejected 2026-09-07: the player has no `fly`
  privilege and cannot reach one, so it would be scenery rather than a limit.
- **Separate width and depth.** Rejected 2026-09-07 — decision 2. One number, and
  it is `mapgen_limit`, because the drone already reads that setting.

### The interface

All three were decided with `G8`, on 2026-09-17. (`B57`)

- **Colours only, with no texture files.** Rejected: a prepend's `bgcolor` and
  `listcolors` alone give a flat rectangle, which reads as a default that happens
  to be opaque rather than as something drawn. The world already has a drawn style
  (`G7`) and the point of the change is that the two match. The cost accepted is
  two more PNGs in the archive, a licence row and a `P2` re-run. *What would
  change it:* the author preferring no new media in the release archive.
- **Reproducing Minetest Game's old look** — `bgcolor[#080808BB;true]`,
  `listcolors[#00000069;…]` and `gui_formbg.png`, which is what `50fd05f^` holds
  and is the obvious thing to copy back. Rejected because it imports another
  game's visual language into one that has since chosen its own. Recorded because
  restoring the deleted bytes is the cheapest fix and the wrong one.
- **A setting for the interface style.** Rejected: a setting no code path depends
  on is one maintained for nobody — the principle that removed
  `codeblock_flat_sky` upstream and closed `A7`. A server owner who wants another
  look **sets a prepend from their own mod**, which overrides this one, so nothing
  is locked. *What would change it:* a server owner needing it off without writing
  a mod.

### How the bounds are implemented

- **Replacing `cc_security`'s every-node `on_mods_loaded` walk with something
  narrower.** Decided by the author on 2026-09-09, in their words: *the case of
  another mod in this game is not actual*. `A8` is won't fix and no source
  changed. Two supporting facts, read from the offline 5.17.0 reference the same
  day and not from a run: `core.node_dig` is the one single-point alternative and
  covers only digging — a node declaring its own `on_dig` bypasses it and the
  client-side dig prediction still needs `B48`'s per-node group strip — and the
  walk's other four jobs have no game-wide equivalent at all. *What would change
  it:* the game gaining a second mod that registers nodes. (`A8`)
- **Shipping `G6`'s `on_generated` on the main thread and moving it later.** The
  ordinary-environment callback is documented as *"Not recommended; … blocks the
  main thread and is prone to introduce noticeable latency/lag"* — unacceptable in
  a game whose drone writes millions of nodes, and shipping it there first would
  write the callback twice. Consequence accepted honestly:
  `mods/codeblock/mod.conf` still declares 5.4, so the game and the mod it bundles
  disagree by five minor versions. **The game's is binding for the game package;
  whether the mod follows is upstream's call.**
- **Guarding the mapgen call so the game still installs below 5.9.** Declined
  2026-09-07: `if minetest.register_mapgen_script then` would let it install from
  5.4 up, but below 5.9 it would **silently ship an unbounded world** — no floor,
  no wall, `B50`'s endless fall, nothing telling the player why. Refusing to start
  is better than working wrongly. Raising a clear error naming the version was
  declined too: the engine's own refusal already names it.
- **Clamping the player's `y` back to the floor plane instead of to spawn.**
  Rejected 2026-09-07 with decision 6 — a bare `y` clamp puts the player straight
  back into the hole and oscillates. **Still rejected, and decision 7 is not it**:
  `60259dd` keeps the column but makes the floor whole and scans *up*, so there is
  nothing left to oscillate against.
- **Recording the program-made hole as a known limit instead of fixing it.**
  Declined 2026-09-07: the stated requirement is a world you cannot fall out of,
  and the failure is silent and unrecoverable — no damage, no `fly`, no way back.
- **Protecting the spawn column from the drone — this entry was removed on
  2026-09-07 and stays removed.** It argued that a program could build a solid
  node at spawn and the clamp would seal a rescued player inside it, and that
  closing it bought a rule the engine does not keep on its own respawns. The
  counter-argument was accepted: `cc_security`'s *"only ever denies"* property is
  about the player's hands, not the map, and it is already spent the moment the
  clamp writes bedrock. Since `60259dd` the clearing happens only on the spawn
  fallback, because the ordinary path moves the player *up* instead and destroys
  nothing a program placed.

### Licensing

- **Putting a scope statement in the root `LICENSE`.** Declined 2026-09-08 with
  the media decision: the AGPL-3.0 text is meant to be distributed verbatim, so a
  line saying what it covers here would be an edit to a licence document. The
  scope lives in `README.md`'s licence line — *code AGPL-3.0-only, media
  CC BY-SA 4.0* — in `THIRD-PARTY-LICENSES.md`, and in each `license.txt`.
  *What would change it:* a separate `NOTICE`-style file, which nobody has asked
  for. (`C22`)
- **An `export-ignore` line for `menu/license.txt`.** Never: it is the only
  statement of the licence a player receives and has to travel beside the images
  it covers, exactly as `THIRD-PARTY-LICENSES.md` does. `git check-attr`
  confirmed it is not excluded. (`C22`)

### Evidence and the record

- **Backdating a playtest result onto a later commit.** Decided 2026-09-07 and
  **applied against this project's own record the same day**: `W8` and `W9` had
  *passed* at `f5f2385`, decision 7 changed the code both were about, and both
  passes were removed rather than kept. The general rule: **a result carried
  across any change to the code it exercised is not evidence**, which is what `R6`
  cost this project once already. The rule costs something only when it is applied
  to a result you would rather keep.
- **Splitting this file's decision log out into a `DECISIONS.md`.** Put to the
  author three times and never answered, so on 2026-09-07 it is **treated as
  declined by silence** and is not to be proposed again. *What would change it:*
  the author saying so.
- **Waiting for a release before the changelog records a milestone.** Decided
  2026-09-07: the entry is written in the same branch as the code, so it lands
  exactly when the code lands and cannot outlive it if the branch is dropped.
  `v2.0.0` is an unreleased heading that accumulates.
- **Keeping any agent guidance outside the repository.** Decided 2026-09-01 with
  the three-agent split. The reference documentation is copied in for the same
  reason: a fresh clone carries it.

### Conventions

- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias for
  `core`, with no deprecation warning and no removal date.
- **Reusing the mod's phase numbers.** They are quoted in commit messages;
  lettered milestones here cannot be mistaken for them.

---

2026-09-22 · codecube `49c7f75`, on branch **`main`**, tree clean and **in sync
with `origin/main`** — PR #1 (`g6-world-limits` → `main`) was merged as
`49c7f75` and local `main` fast-forwarded `99117bf..49c7f75`.

**This pass records the merge and the CI runs it produced, and nothing else.**
`G5`'s *nothing is pushed* blocker is **fully discharged** and its *CI* blocker
with it: green on `99117bf` (`pull_request`) and on `49c7f75` (`push`, `main`),
both jobs read individually. `G5` stays **2/7** and **no-go** — the pointer is
still the untagged `09c708d`, `P2` and `P6` are unrun, nothing has been played in
a world, and no tag has been cut. Green CI proves the game assembles.

**The previous pass records `release-check`'s no-go of 2026-09-22 and one correction to
`CHANGELOG.md`.** The changelog said the bundled mod had *reached 1.0.0*; no such
CodeBlock release exists — the pointer is `09c708d`, untagged, `git describe`
gives `v0.7.3-155-g09c708d` and upstream's newest tag is `v0.7.3` — so it now
says the true weaker thing, that the mod is a development build ahead of `v0.7.3`
whose changes break saved programs. `G5` goes from 2/5 to **2/7** with the push
and the CI run written as items, and its four blockers and the two gaps the run
closed are on the milestone. `PLAYTEST.md` was not touched in this pass and
nothing moved off `unchecked`. That pass left this file at **1184 lines** against its own "under
roughly 150", up from 1129; it is **1218** here.

**The pass before that, at `0a605a3` too, records three decisions of 2026-09-22 and wrote no code**: the
release is `v2.0.0`, `G8` ships in it, and `dev_state` becomes
`ACTIVELY_DEVELOPED`. `G8` also went from 0/3 to **3/3 written** — that was
already true at `ba92d52` and this file had not caught up. Nothing moved off
`unchecked` in `PLAYTEST.md` and `B57` stays open; the two checks the `G8`
decision does not discharge, `P2` and `P6`, are now blockers on `G5`.

The paragraph below describes the state two passes ago.

2026-09-17 · codecube `34b3820`, on branch **`g6-world-limits`**, tree clean at
the start of that pass — `09c708d` is committed at `34b3820`, which the previous
footer described as an uncommitted working tree.

**This pass opened `G8` and filed `B57`, and no code exists for either yet.**
Nothing in the game styles a formspec or the hotbar: `A13`'s deletion at
`50fd05f` took `mods/default`'s `set_formspec_prepend` and its two
`hud_set_hotbar_*` images and nothing replaced them, so every form a player opens
— the editor included, through a prepend that reaches a mod this game does not
own — is the engine's semi-transparent default. The three decisions are on the
`G8` entry, the rejected alternatives under *the interface*, the reasoning in
`AUDIT.md` `B57`, and `PLAYTEST.md` `P6` is the only check that reaches it. No
gate can see any of it: `check_game.sh` says the game assembles.

The paragraph below describes the state before this pass.

2026-09-17 · codecube `c2d2b5a`, with
`mods/codeblock` moved to `09c708d` in the working tree and **not yet
committed**; nothing else is in the tree. **The branch is pushed except its last
five commits**: `origin/g6-world-limits` is at `5777dc0`, so `50fd05f`,
`dd83b99`, `67f1feb`, `c7c2c43` and `c2d2b5a` are local-only. **The branch
carries 17 commits over `main`** — `git rev-list --count main..HEAD`, with `main`
at `578b364`; it was 14 at `dd83b99` and 23 was written here wrongly for two
passes before that. **No commit on the
branch has a CI run**; the newest run of any kind is `main` at `35fa2a1`,
success, 2026-09-01, re-read from the Actions API on 2026-09-09. Both facts
corrected here on 2026-09-08 — this file said the
branch was unpushed and that the latest run was on `578b364`, which was never
pushed. `codeblock` `09c708d` in the working tree, a commit off `master` and not
a tag; `fb75bc8` in `c2d2b5a` and every commit back to `50fd05f`. `vector3`
`fc8a5b8` — `v2.0.2`, committed at `c2d2b5a`.

**This pass is the `codeblock` adoption and the record edits that close `A7`, and
no code changed for it.** The pointer moved sixteen commits, `fb75bc8` →
`09c708d`, on the author's decision of 2026-09-17 to adopt the bare commit now
and re-point to CodeBlock `v1.0.0` once it is tagged — see *which release is adopted*.
Upstream's `C18` finished as a **removal**: `codeblock_flat_sky`, its
`settingtypes.txt` entry and the five sky overrides are gone at `09c708d`, so
`A7` is resolved and `AUDIT.md` has **nothing open** for the first time. Both
gates were re-run green after the bump — `check_game.sh` ending `all game
integration checks passed`, luacheck silent — which says the game assembles and
nothing more: **nothing here runs a line of the mod's Lua**, no result in
`PLAYTEST.md` names `09c708d`, and CodeBlock's own CI on it could not be read
from this machine and is **unchecked**. The move also carries `F17`, the mod's
CI and documentation work, and replaced screenshots — all the mod's to describe,
and none of it reaches the game's release archive, which excludes submodule
contents.

**The `vector3` pass, 2026-09-09: the re-pin and the record edits that close `C21`, and no
code changed for it.** The pointer moved from `v1.5` (`16621648`) to `v2.0.2`
(`fc8a5b8`) on the author's instruction, *"vector3 should be v2.0.2 now and
should only state `min_minetest_version = 5.3` so it does not block anything"* —
and the release's `mod.conf` is exactly that, with no ceiling. Both gates were
green at `c7c2c43` with the pointer staged: `check_game.sh` ending `all game
integration checks passed` with five mods declared, every hard dependency
present, `mods/vector3` carrying its own licence and `.cdb.json` matching
`CONTENTDB.md`, and luacheck silent. **Neither gate ever read the defect and
neither reads the fix** — the `max_minetest_version` guard is scoped to
`game.conf` — so green means the game assembles and nothing more. **Nothing has
been played against `v2.0.2`**: `R4` and `R9` are the game-side evidence and both
name `dd83b99`, which is before the pointer.

**`dd83b99` is `A19`'s `set_sky` line, the four redrawn textures with
`scripts/gen_textures.py`, and every record edit of 2026-09-09.** Both gates were
green immediately before it — `check_game.sh` ending `all game integration checks
passed` with `.cdb.json` matching `CONTENTDB.md`, and luacheck silent — and
neither runs a line of this game's Lua. `git status` is clean on it, including
`mods/codeblock`.

**Six checks passed against that tree, engine 5.17.0, 2026-09-09** — `R1`, `R2`,
`R9`, `L1`, `L2` and `L4`, each reported as the single word *pass*. `L4` closes
`A19` and `R9` closes `A13`, so **`G3` and `G4` are done and checked**; `R1` is
the first falsifiable run of the digging restriction in the project and `R2`'s
drop half its first since `7dc764f`, both off one temporary hand override. The
`R` setup is corroborated by the tree: `cc_security` in `dd83b99` is
byte-identical to `50fd05f`, both restrictions restored and the override gone.
**A one-word report is the standing limit on all six**, and `AUDIT.md` carries it
per finding.

**`L3` passed on 2026-09-09, engine 5.17.0** — no sun, no moon, no stars, no
sunrise, with `codeblock.config.flat_sky` off, and a rejoin in the same sitting.
That discharges `A7`'s game-side half and `L2`'s. The sitting also produced
**`A19`**, the residual horizon blend, and the decision to treat it as a
shortfall in `cc_day` rather than as a defect in `L1`/`L3`'s wording — under
`G4`. Its stated cause was **wrong in mechanism and corrected in the same pass**;
`AUDIT.md` `A19` keeps the wrong version beside the right one.

**`A20` was filed and closed as won't fix on 2026-09-09**, from a read-only trace
of the engine at **both 5.9.0 and 5.17.0** and of `mods/codeblock` at `fb75bc8`:
the hand has empty `groupcaps` since `G3`, so nothing in the game is
hand-diggable. **No code changed for it, then or now** — the author declined the
game's own hand definition the same day — and `R2` digging under the override is
the in-world confirmation the trace lacked.

**The media licence change is committed**, at `48cc63e` — a new
`menu/license.txt`, `mods/cc_mapgen/license.txt`, `THIRD-PARTY-LICENSES.md`,
`scripts/gen_cdb_json.sh`, the regenerated `.cdb.json` and
`scripts/gen_reports.py`. The previous pass, written over an uncommitted tree,
said `C22`'s closure held only once `menu/license.txt` was tracked; it is tracked,
and `P2` at `48cc63e` confirms by listing the archive that it reaches a player, so
**the condition is met**.

**`G6` is done on both counts and `G7` is 4/5 checked.** `W10` and `W12`–`W14`
pass at `3479e25`, so how deep the world is and where a rescue puts anybody are
observed rather than inferred from two gates that run no line of this game's Lua.
Three things did not close: `W11`'s pass is retired with the textures it
described, `W4`, `W8` and `W9` are still owed re-runs at the new depth, and the
boot is **narrower rather than confirmed** — `P1`'s boot half is a fresh recursive
clone and `P3` is unrun.

The game's own Lua is **209 lines** across four files — `cc_day` 8, `cc_mapgen`
51 + 49, `cc_security` 101 — counting neither blanks nor comments, and **597
lines in all**, recounted 2026-09-17 over the working tree at the `09c708d`
adoption; at `dd83b99` they were 209 and 591, at `50fd05f` 208 and 572. At
`5777dc0` the same counts were
177 and 464. **Three corrections to the counts:** the 464 was off
by one (2026-09-08), `cc_day/init.lua` having lacked the trailing newline
`.editorconfig` requires; **579 was written for `50fd05f` and it is 572**
(2026-09-17), an earlier correction having moved a right number to a wrong one;
and the total stood at `dd83b99`'s 591 while six further lines of comment landed.
`A19` is what moved 208 to 209, and the whole of 572 to 591 is comment: one
`set_sky` call in `cc_day` and eleven lines of comment beside it, plus seven the
texture rework added to `cc_mapgen/init.lua`.

That pass left this file at **1045 lines**, up from 953. It added the `G8` section, its three
*deliberately not doing* entries under a new *the interface* heading, a table
row, and this footer's own paragraph — a milestone opening is the one thing that
legitimately grows this file, and none of the 92 lines is reasoning that belongs
in `AUDIT.md`. The pass before it rewrote *which release is adopted* around
`09c708d`, closed `A7`'s `G4` line, spent the `codeblock_flat_sky` entry under
*deliberately not doing* and added a footer paragraph. The one before that
added `C21`'s closure, the `vector3`
pointer, one *deliberately not doing* entry for the playtest decision and its own
footer paragraph, and removed the `vector3` *ships broken* line. The pass
before it added `A20`'s terminal state, `A19`'s
in-world evidence and one *ships broken* line, and removed another — the six
passes let *Now* shrink and nothing else. It got there by moving reasoning to `AUDIT.md` under its finding id
and settled questions into *deliberately not doing*, not by deleting either — and
it grew again here, because a decision was taken and this is where a decision is
recorded. The remaining excess is the decision log, which is this file's second job
and the one nothing else does; the `DECISIONS.md` split that would fix it stays
closed, declined by silence.
