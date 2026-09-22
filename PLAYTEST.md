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
| Entries | **36** — `P6` and `P7` added 2026-09-17, `L4` 2026-09-09 |
| Live checks | 34 — `R6` and `R7` are unrunnable, not live |
| Most recent result a `pass` | **29**, of which 2 are on entries that can never be re-run |
| `partial` | **1** — `P1` |
| `fail` | 0 |
| Unrun (`unchecked`) | **6** — `W11`, `P3`, `P4`, `P5`, `P6`, `P7` |
| Results retired | 3 — `W8` and `W9` at `f5f2385` on 2026-09-07, `W11` at `3479e25` on 2026-09-08 |
| Findings closed by a check | `B47`, `B48`, `B49`, `B50`, `S8` |
| A pass that proves nothing | **0** — `R1`'s run of 2026-09-09 carries the hand override and could have failed. `R8`'s pass still cannot *distinguish* its cause, which is a weaker thing and is recorded in its entry |
| Results that name no commit that carries the code | **0** — it was 3 on the morning of 2026-09-09, `L1`, `L2` and `L4` against `A19`'s then-uncommitted `set_sky` line. `dd83b99` committed that tree unchanged the same day and all three now name it |
| Passes composed from other entries rather than reported | **2** — `L3` and `R5`. Each entry says so in its own result line |

**Counted 2026-09-09 from the first `Result:` line of all 34 entries**, not
adjusted by hand: 29 pass, 1 partial, 0 fail, 4 unchecked. `P6` and `P7` were added on
2026-09-17 and are the 35th and 36th, both unchecked, which is the only change to
the counts since. Six results moved in
the third sitting of the day — `R1`, `R2`, `R9`, `L1`, `L2` and `L4` — and two
more were composed from them, `R5` and `L3`.

**Every 2026-09-09 result now names `dd83b99`.** That commit was made the same
day with `git add -A` over the tree all three sittings were played against, and
its only difference from that tree is two stray blank lines removed from
`mods/cc_security/init.lua`, leaving the file byte-identical to `50fd05f`. So the
shas above carry the exact bytes that were run. **One line deliberately does not
name it**: `L3`'s retained `partial`, which was taken in the first sitting before
`A19`'s `set_sky` line existed and whose whole subject is the sky, so it still
names `50fd05f` plus the texture rework. Every other 2026-09-09 result is about
`cc_mapgen`, `cc_security` or the mod, none of which that line touches.

**`G3` landed at `50fd05f` on 2026-09-08**, so `W15`, `W16` and `R9` have a commit
to be run against, and all three were run on 2026-09-09: **`W15`, `W16` and `R9`
all pass.** `R9` took two sittings — its fifteen blocks passed in the first, its
misspelling step was found to have been written against the wrong code path and
was corrected, and the two corrected one-line programs passed in the third.
**`R6` and `R7` are
unrunnable with it** — each names a node only `default` registered — and are kept
with their passes rather than deleted, because a deleted entry takes its evidence
and its reasoning with it. **Every `W` result is owed a re-run at
`50fd05f` or later** — the tip is `7609d09` — because `50fd05f` rewrites both
files the group exercises; the group's preamble says so once rather than the table
saying it eleven times.

**The newest commit any result names is `dd83b99`, and HEAD is ten commits
later, at `7609d09`.** Counted from the `Result:` lines on 2026-09-22, not
recalled. The tenth, `7609d09`, changes record documents and the `.cdb.json`
generator only; the nine before it touch **all four** of the game's own mods, both submodule
pointers and `minetest.conf`, so every claim below about behaviour is evidence
about a tree ten commits old. Nothing in this document has been run since
2026-09-09.

**The world was widened to `mapgen_limit = 4096` on 2026-09-17** (`ROADMAP.md`
`G6` decision 9) and **committed at `0a605a3` on 2026-09-22**, so every `W` result
was run in a world 2000 nodes on a side and
the game now makes one **8080** on a side, with the ceiling as far up as the wall
is out. It moves every edge: `W3`,
`W5`, `W6` and `W7` are owed re-runs and all four have had their methods
rewritten, because each named a coordinate or a distance. `W4`, `W8` and `W9` are
about depth and are untouched by it — their re-runs are the older depth ones and
are still owed.

**That set of four is complete for the code and incomplete for the wording.**
`0a605a3` changes two files the group reaches: `minetest.conf`, the setting
itself, and `mods/cc_mapgen/init.lua`, whose `or 1024` fallback moved to
`or 4096` — a line reached only when `mapgen_limit` is absent from
`core.settings`, which `minetest.conf` never lets happen, so no run exercises it
and it adds no fifth re-run. The earlier claim here that the widening *"changes no
code the group exercises"* was written while it was working-tree only and is
corrected. **`W12`** was stale in the same way and is now fixed: its *Pass* read
*"**World half-extent** at 1024"* against a `settingtypes.txt:27` declaring 4096,
so a runner would have failed a correct world. The wording now names 4096; its
subject is depth, so its pass at `3479e25` stands and no re-run is owed.
Corrected 2026-09-22, found in the same pass.

**Verified against the tree on 2026-09-22, and this is the whole of it.**
`mods/cc_day/init.lua` and `mods/cc_security/init.lua` both changed in the nine
commits since `dd83b99` and **both changes are comment-only** — read from
`git diff dd83b99..HEAD` — so neither owes anything. `mods/cc_gui/` is new at
`ba92d52`, 50 lines of Lua with no result of any kind: **`P6` is its only possible
evidence** and both gates together prove only that it assembles.

**`W11`'s pass was retired on 2026-09-08** because `cc_mapgen`'s bedrock and
barrier textures were redrawn after it, and because it had passed against wording
the textures can no longer meet. Its entry carries the retired line and why.

**Both pointers are now committed, and the re-runs below are genuinely owed.**
Checked on 2026-09-22 with `git submodule status` and `git diff dd83b99..HEAD`:
`mods/codeblock` is `09c708d`, moved from `fb75bc8` at `34b3820`, and
`mods/vector3` is `fc8a5b8` (`v2.0.2`), moved from `1662164` at `c2d2b5a`. **No
result in this document names either.** `R9`'s newest names `dd83b99`, which
precedes both; `R4`'s newest names `6f2409e`, older still. So `R4` and `R9` — the
game's whole share of that evidence — are owed re-runs on the record as well as in
the prose.

**`mods/vector3` was re-pinned to `v2.0.2` on 2026-09-09, and no result in this
document was run against it.** It is a **major version of a hard dependency**
under the drone, so `R4` and `R9` are owed a re-run at the commit that carries the
pointer; both name `dd83b99`, which is before it. **No entry was added for it**,
and the grounds are `ROADMAP.md` under *deliberately not doing*: what `v2.0`
changed is reached through `vector` in a player's program, and this document does
not re-check the drone, the editor, the sandbox or the API — that evidence is
`mods/codeblock/PLAYTEST.md`'s. `R4` and `R9` are the game's whole share.

**`mods/codeblock` was adopted at `09c708d` on 2026-09-17, and no result in this
document was run against it either.** Sixteen commits, including a substantially
rewritten `lib/sandbox.lua`, so the same two re-runs are owed for the same reason
and by the same argument: the sandbox and the API are the mod's to check, and
`R4` and `R9` are the game's share. **No entry was added.** The one thing the
move changes in this document's criteria is `L3`'s precondition — the mod's sky
block, its `codeblock_flat_sky` setting and the guard around it are deleted
upstream, so there is nothing left to be inert — which strengthens a pass already
taken and closes `A7`. Nothing else here is affected, and **CodeBlock's CI on
`09c708d` is unchecked** from this machine.

**What needs action**, and it is the list — `TODO.md` points here rather than
keeping a second copy.

| Check | State | Why it needs action |
|---|---|---|
| `W3` | pass, **method stale** | it passed by teleporting "several thousand nodes" out, a distance that was outside the world at 1024 and is inside it again since the widening to 4096, **committed at `0a605a3`**. The pass stands as what was seen at `7f649d8`; the instruction carries a command now |
| `W5` | pass, **re-run owed** | the wall it saw stood at 1007. Since 2026-09-17 it stands at **4047**, in chunks nobody has emerged, and the method's *past 1000* reached nothing there. Rewritten with a command |
| `W6` | pass, **inverted, re-run owed** | **its pass condition inverted**: the drone must now name **4096**, which used to be the fail, and the recorded pass at `60259dd` names **1024**, which is now the failure. Verified 2026-09-22 — `minetest.conf` reads `mapgen_limit = 4096` at `0a605a3`. Until it is re-run this entry's own result reads as a fail against its own criterion |
| `W7` | pass, **method rewritten, re-run owed** | it compared a world at 4096 against a game at 1024, and 4096 is now the game's own value, so the old method proves nothing. Rewritten around a world at `2000` or `1024` |
| `W11` | **retired, unrun** | the bedrock and barrier textures were redrawn on 2026-09-08 in a flat-base-plus-specks style, and the old pass named a *"black mottled rock"* and a *"wrapping blur"* that no longer exist. **`W15` was run on 2026-09-09 without it**, so the bedrock and barrier redraws are now the only unjudged part of the texture rework, and the cheapest thing left in this group |
| `W12` | pass, **wording corrected 2026-09-22, nothing owed** | its subject is depth and nothing has moved it, so the pass at `3479e25` stands. Its *Pass* read *"**World half-extent** at 1024"* against a `settingtypes.txt:27` declaring **4096** since `0a605a3`, so a runner following it would have failed a correct world; the wording now names 4096. A defect in this entry rather than in the code, so no finding id |
| `W15` | **pass at `dd83b99`, 2026-09-09** | the grass-over-dirt surface and its two textures are judged. Nothing owed here; `W11`, which it was to be run beside, was not run |
| `W16` | **pass at `dd83b99`, 2026-09-09** | the three essential mapgen aliases resolve and nothing in the column is `unknown`. It does **not** discharge `P3`, which asks for a log with nothing in it at all rather than four strings absent |
| `R9` | **pass at `dd83b99`, 2026-09-09**, **re-run owed** | the re-run is for the `vector3` `v2.0.2` re-pin, committed at `c2d2b5a`, and the `codeblock` `09c708d` adoption, committed at `34b3820` — sixteen commits including a substantially rewritten `lib/sandbox.lua`. No result here names either pointer; `dd83b99` is before both. The two corrected one-line programs were run in the third sitting: `place(colors.vermilion)` warns once, carries on and leaves a default-coloured block, and `place('vermilion')` stops the program and places nothing. **What was not read back** is the default-coloured block itself, which is the quiet path's whole pass condition |
| `R6` | pass, **unrunnable** | `default:bookshelf` is deleted with `G3` and no node left carries a formspec. The pass at `c042364` stands; there is no way to run it again |
| `R7` | pass, **unrunnable** | its three cases and the ABMs they were about are all `default`'s. The pass at `d16f9bb` stands and is the only evidence the `action` replacement ever worked |
| `W4` | pass, **re-run owed** | passes at `60259dd`, where `mgflat_ground_level` was 8; `d6e4a12` moved it to 128. **`W14` does not discharge it**: `W4`'s subject is **air, not stone**, under a removed floor tile, and a program being unable to take the plane by accident — which `W14` never reaches |
| `W8` | pass, **re-run owed** | same depth change. **`W14` case 1 shares the setup and not the check**: `W8`'s pass includes walking the wall and standing on the exposed floor plane **unmoved**, which `W14` does not ask for |
| `W9` | pass, **re-run owed** | same depth change. **`W14` covers neither case 1** — the spawn-column shaft, rescued **once**, with no second teleport — **nor case 3**, the no-op where only `(x, 0, z)` may have changed |
| `L4` | **pass, both halves, at `dd83b99`, 2026-09-09** | nothing owed. The first run of the entry and **the whole of `A19`'s in-world evidence**: nothing moves across `/time 0`, `5000`, `10000` and `22000`, turning changes nothing, indoors matches outdoors, and none of the three over-applied signals appeared, so `#90d3f6` stays. The `set_sky` line was uncommitted when this ran and `dd83b99` carries it byte-identically, so **the owed re-run is dropped**. A bare *pass* covered four steps and two halves; nothing was read back |
| `L3` | **pass, composed, at `dd83b99`, 2026-09-09** | nothing owed. Composed from `L1` and `L2` passing in the same world with the mod's copy inert, plus `L4` closing the residual at the two times it was seen at; the precondition is read, not run — nothing set `codeblock_flat_sky` and the then-adopted `fb75bc8` guarded the mod's copy. **The precondition is stronger since 2026-09-17**: at `09c708d` the copy, the setting and the guard are deleted upstream, so there is nothing left to be inert. **The `sunrise_visible = false` half can never be re-established**: a `plain` sky draws no mesh, so that evidence is frozen in the retained `partial` |
| `L1` | **pass at `dd83b99`, 2026-09-09** | the owed re-run beside `L4` is done: full daylight and no sky objects under the `plain` sky. One limit stays — **the four-object half no longer distinguishes its cause**, because a `plain` sky draws no sky mesh at all; that the four calls do their own work now rests on the retained 2026-09-01 pass under a `"regular"` sky |
| `L2` | **pass at `dd83b99`, 2026-09-09** | the rejoin holds with `set_sky` as a sixth per-player call, which is the one this could have dropped. The **second-player half is still unexercised** — singleplayer only, since 2026-09-01 — and nothing here would catch a sky applied to whoever joined first |
| `R1` | **pass at `dd83b99`, 2026-09-09, and the first falsifiable run** | the priority of this document is discharged (`A20`). The temporary hand override was in place — corroborated by the working tree, which had both `cc_security` lines restored and the override gone — so the pass is a restriction refusing a hand that **could** have dug. **What is still owed is breadth**: a bare *pass* named none of the seven subjects the method asks for, and the entry's *Why* — a partial override pass covering a different set of nodes on every boot — is reached only by breadth |
| `R2` | **pass, both halves, at `dd83b99`, 2026-09-09** | **no longer blocked**: the drop half ran for the first time since `7dc764f` and the first time ever under the corrected method, and no item appeared. So `A20` is confirmed in a world rather than only traced, and the empty drop list reaching the captured handler is on the current tree. **What was not read back** is the pass observation itself — the hotbar's slot 3 and the dug position — which this method was corrected on 2026-09-09 to name |
| `R3` | **pass, re-run done 2026-09-09** | nothing owed. It was the knockback half of `R5`, and that half is now on the current tree |
| `R4` | pass at `6f2409e`, **re-run owed** | same blast radius as `R1`, and both pointer moves are now committed — `vector3` `fc8a5b8` (`v2.0.2`) at `c2d2b5a`, `codeblock` `09c708d` at `34b3820`, both confirmed against the tree on 2026-09-22. Its newest result names `6f2409e`, older than every other live result here, so it is the stalest entry in the document. Run it with `R9` |
| `R5` | **pass, composed, 2026-09-09** | nothing owed. Both halves are now on the same tree — `R3` re-run and `R2`'s drop half run under the hand override — which is exactly the composition the `partial` pre-authorised in writing. `A8`'s **`last_mod` half stays untested by choice**, as its own paragraph records: it needs a second mod assigning the same globals and none ships here |
| `R8` | **pass 2026-09-09**, with a second explanation | nothing owed. It is the whole of `B48`'s in-world evidence, and the `dig_immediate` case stays unreproducible — `G3` deleted the last such node. **The pass no longer distinguishes its cause** (`A20`): empty hand groupcaps suppress the crack overlay and the dig sound on their own. Only a run with the hand override would separate them, and nobody has done that |
| `P1` | **partial**, clone half **fetch-confirmed, boot half unrun** | the clone half passed at `8b27f2f` on `codeblock` `2647228`, and the pointer has moved twice since — to `fb75bc8` at `50fd05f`, then to `09c708d` at `34b3820`. **On 2026-09-22 a fresh recursive clone fetched both intended pointers by hash**: `git fetch origin 09c708d` and `git fetch origin fc8a5b8` each succeeded and `git cat-file -t` gave `commit`, so neither names an object nobody can fetch. That is **the reading half only, and less than the check asks for**: the clone's own submodules came up at `35fa2a1`, the previous release, because the candidate is unpushed, so no clone has yet *populated* at these pointers. The boot half has never been run, and a working checkout booting does not discharge it |
| `P2` | pass at `48cc63e`, **standing obligation** | re-run on 2026-09-08 and it stays here permanently: the entry says to run it **whenever a tracked file is added**, and nothing in either CI reads `.gitattributes` (`C15`, `C22`). Needed twice in two milestones — `G6`'s two files, then `G7`'s new directory, two textures and `menu/license.txt` |
| `P3` | unrun | the boot log, and the whole of `B19` and `B24`'s evidence — whose causes `G3` deletes, while adding three mapgen aliases whose absence shows up here |
| `P4` | unrun | the main menu shows the game's name, artwork and icon |
| `P5` | unrun | needs a release first — it is the ContentDB page as published |
| `P6` | **unrun, and now runnable** | the blocker is gone: `mods/cc_gui/` was committed at `ba92d52` — 50 lines of Lua, a `mod.conf`, a `license.txt` and three textures, confirmed against the tree on 2026-09-22. **No result of any kind exists for that mod**, and `P6` is `B57`'s only possible evidence; both gates together prove only that it assembles and lints. It is the only thing in this document that reaches a form at all, and nothing about a prepend is visible from the world, the menu or either gate. Run it before the release |

**Three sittings on 2026-09-09, and `P2` is in none of them** — it touches no
engine and needs no world, so it is run from a shell whenever a tracked file is
added.

- **`G4`'s is done.** `R8`, `R3`, `R1` and `R2` all passed on 2026-09-09, the last
  two off the one temporary hand override in the `R` preamble, which was the
  priority of the whole document and is now spent: `R1` is falsifiable and passed,
  `R2`'s drop half ran, and `R5` closes with it. **What is left of the `R` group is
  `R4`'s re-run** — the widening control, owed for `B48`'s blast radius over
  `groups` and now for the `vector3` re-pin, with **`R9`** beside it — and, if
  anyone wants it, a re-run of `R8` **with** the hand override,
  the only thing that would separate its two explanations.
- **`L`'s is done, and nothing in it is owed.** `L1`, `L2` and `L4` passed and
  `L3` composes from them, so `A19` has in-world evidence for the first time. All
  three were run against the uncommitted `set_sky` line and **`dd83b99` carries
  that tree unchanged**, so they name a sha and the re-run this group was owed on
  2026-09-09 is **dropped**: it would execute the same bytes. The only unexercised
  thing left in the group is `L2`'s **second player**, singleplayer-only since
  2026-09-01.
- **`G3`'s, and it is mostly done: `W15`, `W16` and `R9` all pass.** What is left
  of it is **`W11`** — which was to be run beside `W15` and was not, and is now
  the only unjudged part of the texture rework — `P3` beside `W16`, and the whole
  `W` group re-run.
- **`P6` can be run now.** It checks `B57`'s fix — the game's own formspec and
  hotbar styling — and the mod it needs, `cc_gui`, exists as of `ba92d52`.
  Nothing else in this document reaches a form at all, and `cc_gui` has **no
  in-world evidence whatever**.
- **What no sitting has touched:** `P3`, `P4`, `P6`, `P1`'s boot half, and the
  `W4`, `W8` and `W9` re-runs at the current depth. `P5` needs a release first.
  **No result names either current submodule pointer** — `vector3` `v2.0.2`
  (`fc8a5b8`) or `codeblock` `09c708d` — and none names any of the nine commits
  from `67f1feb` to `0a605a3`, nor `7609d09` after them.

**The boot gap is real and narrower than it was.** `W10` and `W12`–`W14` pass at
`3479e25`, record-only over `48cc63e`, and none of those observations is possible
without the game booting and a world being entered — so **the author's own
checkout boots**. What is still unrun is `P1`'s boot half, which is a **fresh
recursive clone** whose submodule objects nobody has locally, and that is the case
that catches a pointer nobody can fetch; and `P3`, the boot log. **No entry here
has criteria that the working-checkout boot alone satisfies**, and `P1` is
deliberately not widened to cover it: a clone that already holds the objects does
not test what `P1` exists for.

**The four surviving 2026-09-08 results name no engine version.** It was not
given, and every other result in this document carries one — including all of
2026-09-09's, which the author confirmed as 5.17.0. There were five; `W11`'s is
retired.

**A rule for a result run against an uncommitted tree, currently with no live
instance.** A result whose code is committed nowhere cannot be reproduced by
anyone, which is the one shape of result this document had no rule for. It arose
once, on 2026-09-09, when `L1`, `L2` and `L4` were run against `A19`'s `set_sky`
line while it was working-tree only. The rule: such a line **names the tree it was
run against and says the code is uncommitted**, and it is **not retired** — the
code has not changed, it has only not been written down. When the tree is
committed unchanged, the line is **re-pointed at that sha and no re-run is owed**,
because a re-run would execute identical bytes and could only produce identical
output; a re-run is owed when the code changed under a result, not when it was
merely written down. That is what happened at `dd83b99`, which committed the whole
tree of 2026-09-09 with `git add -A` and differs from it only by two stray blank
lines removed from `mods/cc_security/init.lua` — whitespace at file scope in a
file whose one executable difference from `50fd05f` had already been reverted.

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` settles the world's flags, its size and the nodes it is
made of, and `mapgen_env.lua` writes into each chunk on the emerge threads:
nothing below `y = 0`, a bedrock plane at `y = 0`, one layer of grass at the
surface, and a barrier wall at the outermost generated column. `cc_security` holds
the two that are about the player rather than the map — the clamp (`W8`) and the
place it puts them (`W9`). `W4`–`W9` and `W14` are `B50`; `W15` and `W16` are
`A13`.

**`G3` rewrote both of those files at `50fd05f`, so every result in this group is
owed a re-run at that commit or later — the tip is `7609d09`.** That is the rule about a result not surviving a
change to the code it exercised, applied to a whole group at once rather than per
check: the surface material changed, the fill node changed, and the mapgen aliases
the engine needs moved into `cc_mapgen`. The passes below stand as what was seen
at the commits they name.

Three facts about the world these checks run in, because each one changes a
method below.

- `mg_flags` carries `nobiomes`, so `mgflat` supplies no top node and no filler
  node. **Until `G3` the surface was `default:stone` the whole way down; since
  `G3` it is one layer of `cc_mapgen:grass` over `cc_mapgen:dirt`**, the grass
  written by `mapgen_env.lua` and the dirt by the engine through `cc_mapgen`'s
  `mapgen_stone` alias. There is still nothing else in the world until a program
  places it. Every method below that says "stone" is a method written before
  `G3`.
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
2026-09-02. **The distance in the old instruction has been stale twice** — it was
written at 4096, was outside the world at 1024, and is inside it again since the
2026-09-17 widening back to 4096. `/teleport 3000 130 3000` is well inside the
wall at 4047 and well outside anything a `W5` or `W7` run has emerged.

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

**How** — `/teleport 4040 130 0`, which is a few nodes inside the `+x` wall at
**4047** and above the surface, then walk into the edge. Look up along the face,
and walk some way along `z` with the wall beside you. **Rewritten 2026-09-17**:
the old instruction teleported past 1000, which since the widening to 4096 is
nowhere near an edge.

**Pass** — an unbroken face, from the floor up out of sight, standing at the same
`x` all along `z`, with no gap where one mapchunk meets the next. **`x` is 4047,
not 4096**: only whole mapchunks inside the limit are generated, and the wall
stands on the last of them. Not a wall that
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

**How** — ask the drone to move past 4096 on any horizontal axis.

**Pass** — it refuses with *"The drone cannot leave the world (4096 nodes)"*,
naming the number in `minetest.conf` and not the engine's own default. **The
number changed on 2026-09-17**, from 1024 to 4096, so the pass condition inverts:
4096 used to be the failure. One thing this does **not** settle is that the drone
and the wall stop in the same place — the drone reads the raw setting, 4096, and
the wall stands at 4047, so the drone may build in the 49 nodes between them
(`TODO.md`, upstream).

**The result below now reads as a fail against this entry's own criterion, and it
is not one.** Recorded 2026-09-22 from the tree, not run: `minetest.conf` at
`0a605a3` carries `mapgen_limit = 4096`, so the *"1024"* the pass names is the
number the *Pass* above declares a failure. The line is kept rather than retired
because it is honest evidence of the mechanism — the game's `minetest.conf`
reaching `core.settings` — under the setting it was taken at. **Nothing here has
been re-run, and until it is, this entry has no live evidence for the current
number.**

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

**How** — open a world whose `map_meta.txt` carries a **different**
`mapgen_limit` from the game's — `2000`, which is what `v1.0.2` created, or `1024`
from an unreleased checkout — and teleport out past that world's old edge with
`/teleport 3000 130 0`. **Rewritten 2026-09-17**: the old instruction used a world
at 4096 and expected 1024, and 4096 is now the game's own value, so as written it
proves nothing.

**Pass** — ground continues past the old edge and stops at **4047**. A world made
at 1024 also keeps its old barrier shell at about ±1000, standing inside the new
wall; that is expected. What this does **not** cover is under
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
black like in minecraft"*, `cc_mapgen` ships its own 16×16 textures instead of
borrowing `default_obsidian.png` and `default_obsidian_glass.png`, and on
2026-09-08 both were redrawn in the Soothing32 style — a flat base colour plus a
few sparse specks, not a noise field. **The look is the whole subject**, and only
a world says whether a near-black flat base with six specks in 256 pixels reads
as rock rather than as a flat fill.

**How** — have a program clear a shaft to the bedrock plane at `y = 0` and then
clear a **wide** expanse of it, twenty nodes on a side at least and more is
better. Stand on it, look straight down, then look **across it to its far edge at
a shallow angle** — tiling artefacts are far more visible there than from
directly above, so looking down at your feet and calling it clean is how this is
missed. Then go to the world's edge and look at the wall beside the floor where
the two meet.

**Pass**, and the first part is the one the redraw is for.

- **The floor reads as a near-black rock with a few flecks in it** — a flat base
  of `#28282D` with sparse single pixels and pairs of `#1C1C20` and `#3C3C44`,
  and nothing between them. Darker and less blue than the obsidian it replaced,
  so anyone who remembers the old floor can say which is which. **Fail: grain.**
  Per-pixel variation across the whole tile is the construction the author
  rejected on 2026-09-08 — *"soothing has less features, less grain and reduces
  palette"* — and a mottle that reads as static rather than as a few specks is a
  fail here however dark it is.
- **No tiling grid across the expanse, at any angle** — no repeating shape, no
  seam every sixteenth node, no line where one texture meets the next. Seamless
  is by construction rather than by treatment: every cell of a speck is placed
  modulo the tile, so a cluster running off one edge reappears on the opposite
  one. What a grid would mean now is that the committed PNG is not what
  `scripts/gen_textures.py` draws.
- **The floor and the wall read as one material**, dark and of a piece, rather
  than two nodes that happen to be adjacent. The barrier's border is a single
  tone, `#101010`, since 2026-09-08; it was two near-blacks eight steps apart,
  which is the same rejected construction at a separation nobody can see.

A regular grid on the *wall* is `W10`'s pass; a regular grid on the *floor* is a
fail here. The two are next to each other and easy to conflate.

Result: unchecked — **owed a re-run, and run it with `W15`**, whose textures were
redrawn in the same pass.

**A pass was retired here on 2026-09-08 rather than carried forward.** The author
ran this check at `3479e25`, record-only over `48cc63e`, on 2026-09-08 and
reported a pass of the whole entry: black mottled rock, no tiling grid at a
shallow angle, floor and wall one material. It was the first rendering of either
texture. The line is removed for two reasons and either would be enough — the
bedrock and barrier PNGs have both been redrawn since, so it is a result carried
across a change to the media it exercised; and it passed against wording this
entry no longer has, *"black mottled rock"* and a seamlessness attributed to a
*"wrapping blur"*, neither of which the textures are made of any more. A check
that passes on a criterion the code cannot meet is worse than an unrun one.

### W12 · A new world puts you 128 nodes above the floor

**Why** — no finding id. `mgflat_ground_level` goes from the engine's 8 to 128 —
declared in `settingtypes.txt`, defaulted in `minetest.conf`, and forced onto the
world by `cc_mapgen`. The bedrock plane stays at `y = 0`, so the number is how
much ground there is between the surface and the bottom of the world. **`W15` is
what that ground is made of; this check is only its height.**

**How** — create a **new** world with default settings, enter it, and read your
own position with `/status` or the debug display, `F5`. Have a program clear a
shaft and confirm the bottom of it is bedrock at `y = 0`. Then open Advanced
settings → Content: Games → Codecube.

**Pass** — you are standing at `y` about **128.5**, with solid ground all
the way down to the bedrock plane at `y = 0` — the floor did not move, the surface
did — and **Surface height** is offered at 128 beside **World half-extent** at
**4096**, which is a server owner's route to it and the reason it is a setting rather
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

### W15 · The surface is one layer of grass over dirt, at the right height [A13]

**Why** — `mg_flags` carries `nobiomes`, so the engine supplies neither a top node
nor a filler node: the grass layer exists only because `mapgen_env.lua` writes it,
and the dirt only because `cc_mapgen` aliases `mapgen_stone` to it. Both are new
with `G3` and each fails in a way the other hides — a missing alias gives a world
of unknown nodes with grass on top, a missing grass write gives a correct-looking
world of bare dirt. **One layer** is the specification: the author asked for
*"grass above, dirt under"*, not a layer of topsoil.

**How** — create a **new** world, then read node names rather than looking at
colours. The debug overlay (`F5`) names the node under the crosshair, and that is
the whole instrument.

1. Point at the ground at your feet and read the name. Then have the drone cut a
   step down beside you so the layers are exposed in a face you can point at:
   right-click with the **Drone placer**, and run

   ```lua
   for i = 1, 4 do
       move(1, 0, 0)
       for j = 1, i do
           move(0, -1, 0)
           place(air)
       end
       move(0, i, 0)
   end
   ```

   which leaves four holes, each one node deeper than the last. `move` takes
   `n_right, n_up, n_forward` relative to the drone. **There is no `remove` in
   the API at `fb75bc8`** — clearing a node is placing `air`, and `air` is a
   plain name rather than a category.
2. Point into each hole in turn and read the name at its bottom — the node one,
   two, three and four below the surface.
3. Step back ten nodes and look at the surface.

**Pass** — exactly **one** node of `cc_mapgen:grass` at
`y = mgflat_ground_level`, which is **128** by default, and `cc_mapgen:dirt` at
every `y` below it down to the bedrock plane. Two or more grass nodes deep, or
grass at 127 as well as 128, is the write covering a range instead of a layer.
`default:stone` or `default:dirt` anywhere means the deletion did not land.
**`unknown` or `ignore` in the column is `W16`, not this check** — but if you see
it, stop and run `W16` instead, because a missing `mapgen_stone` alias makes every
claim here meaningless.

**The look is a pass condition too, and it is the part no node name shows.** The
grass has to read as *green and light* from ten nodes away, which is what the
author asked for; a texture that reads as another grey floor is a fail. Both
textures are the Soothing32 style the author asked for on 2026-09-08 — a **flat
base colour with a few sparse specks**, grass `#9CC43C` with flecks of `#78A32F`,
`#5F913E` and `#4E8568`, dirt `#8B6547` with `#704E36` — so **grain is a fail**:
per-pixel variation across the tile is the construction that was rejected, and
*"less features, less grain and reduces palette"* is the directive verbatim. The
dirt is two colours as printed and that is deliberate, not a texture that failed
to draw. Look at the surface at a shallow angle and at a cut face, where the dirt
shows.

Result: pass — `dd83b99` · engine 5.17.0 · 2026-09-09 — reported by the author
from a sitting in a world, against the check as written, so the pass covers both
halves of the entry:
exactly **one** node of `cc_mapgen:grass` at `y = 128` with `cc_mapgen:dirt` at
every height below it, no `default:*` node and no `unknown` in the column — and
**the look**, the grass reading green and light from ten nodes away and both
textures reading as a flat base with a few sparse specks rather than as grain.
This is the first run of the surface `G3` introduced, and the first judgement of
either of the two new textures in a world. **Limits:** the report
was the single word *pass*, so no node name and no `y` value was read back to me,
and the pass is against the check as written rather than against values quoted.
**`W11` was not run with it** and stays retired and unrun, so the bedrock and
barrier redraws are still unjudged — this pass covers the grass and the dirt only.

### W16 · No node in the world is unknown, anywhere in the column [A13]

**Why** — `mods/default/mapgen.lua:7-9` was the only thing registering
`mapgen_stone`, `mapgen_water_source` and `mapgen_river_water_source`, and
`lua_api.md` lists all three as **essential for every non-V6 mapgen**. Deleting
`default` takes them, and `cc_mapgen` re-registers them. A missing one does not
stop the game booting: the engine resolves the alias to nothing and the mapgen
writes `unknown`, which renders as the unknown-node texture and behaves like a
solid block — a world that looks wrong and works, which is the failure this check
exists to catch before a player meets it. The water aliases are the ones nobody
will look at, because no water is ever generated at a surface height of 128.

**How** — create a **new** world and read the boot log first, then the world.

1. In the log for the world's creation, search for `Ignoring CONTENT_IGNORE`,
   `Failed to resolve`, `NodeResolver` and `unknown`. `P3` is the general boot-log
   check; this is the mapgen half of it and is worth doing in the same sitting.
2. Turn on the debug overlay (`F5`) and walk about twenty nodes, watching the
   node name under the crosshair change.
3. Have the drone clear a shaft from the surface to `y = 1`, climb or teleport
   into it, and read the wall of the shaft at three heights — near the surface,
   halfway, and one node above the bedrock.

**Pass** — no unresolved-alias or unknown-node line anywhere in the log, and no
node named `unknown` at any height in the shaft or on the surface. The
unknown-node texture is unmistakable once seen and easy to miss at a glance in a
uniform world, which is why the shaft is read at three heights rather than
sighted from above.

Result: pass — `dd83b99` · engine 5.17.0 · 2026-09-09 — reported by the author
from a sitting in a world, against the check as written: no unresolved-alias or
unknown-node line in
the log for the world's creation, and no node named `unknown` on the surface or at
any of the three heights in the shaft. So `cc_mapgen`'s three essential mapgen
aliases resolve, and deleting `default` did not take `mapgen_stone` with it — the
failure that would have given a world that looks wrong and works. **`P3` is not
discharged by this.** Step 1 here searches the log for four specific strings;
`P3` asks for **nothing at all**, red or yellow, from a cold start, and it is
still `unchecked`. **Limit:** the report was the single word *pass*, so no log
line was quoted back to me.

---

## L · Light

`mods/cc_day/init.lua` is one `on_joinplayer` calling six player methods. `L1`
and `L2` are the light level and the sky objects; `L3` is those two holding with
the mod's own copy inert; `L4` is the sky's own colour, which is the sixth call
and the newest.

### L1 · Permanent noon, no sky objects [A7]

**Why** — `override_day_night_ratio(1)` pins the light level and the other four
calls remove the sky objects. They are separate effects, so a partial result has
to say which of the two failed.

**How** — enter a world and look up. Advance time with `/time` and look again,
including `/time 5000`, which is dawn.

**Pass** — full daylight regardless of the time of day; no sun, no moon, no
stars, no clouds, and no sunrise or sunset glow. The **colour** of the sky, the
horizon band and the fog are `L4`'s and are not judged here — that division is
why the residual `A19` names came back as a partial rather than a fail.

Result: pass — `dd83b99` · engine 5.17.0 · 2026-09-09 — re-run beside `L4`
against the `plain` sky, which is what the 2026-09-08 owed re-run was for: full
daylight at every hour, and no sun, moon, stars, clouds, sunrise or sunset glow.
**Run against the working tree and committed unchanged as `dd83b99`** on the same
day — `player:set_sky({type = "plain", base_color = "#90d3f6"})` was uncommitted
when this was run and is in that commit byte-identically, so the sha above is
reproducible and **no re-run is owed**. **Limits.** The report was the single word
*pass*, so no time of day and no observation was read back; the pass is against
the check as written. And **the four-object half no longer distinguishes its
cause**: under a `plain` sky the client draws no sky mesh at all, so *no sun, no
moon, no stars, no sunrise* is what the sky type alone would produce, with or
without the four calls and `B47`'s `sunrise_visible = false`. That the four calls
do their own work rests on the 2026-09-01 pass below, taken under a `"regular"`
sky, which is why that line is kept. Same shape as `R8`'s second explanation.

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

Result: pass — `dd83b99` · engine 5.17.0 · 2026-09-09 — re-run beside `L1` and
`L4`: the flat sky and the pinned light level survive a rejoin. Run against the
working tree, which was committed unchanged as `dd83b99` the same day, so the sha
carries the code and no re-run is owed. This matters more than a repeat of 2026-09-01
looks, because `set_sky` is a **sixth** per-player call in the same
`on_joinplayer` and a per-player sky is exactly what a rejoin drops. **Limits.**
The single word *pass* was reported. The **second-player half is still not
exercised** — singleplayer only, as in 2026-09-01 — so nothing here would catch a
sky applied to whoever joined first.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — survives a rejoin.
The second-player half was not exercised: singleplayer only.

### L3 · Permanent noon still holds when only `cc_day` is setting the sky [A7]

**Why** — `codeblock` used to register its own `on_joinplayer` calling the same
five methods, so `cc_day` being sufficient **on its own** was never observed. The
mod's copy went behind `codeblock.config.flat_sky` at their `6fea453` and was
**removed outright** at their `3fa9d0c` and `6440ca0`, adopted here as `09c708d`
on 2026-09-17. So on the adopted release `cc_day` is the only thing setting the
sky, and this check is what says that is enough.

**How** — nothing in this repository changes for it, so first read the adopted
mod: `grep -rn "set_sky\|set_sun\|set_moon\|set_stars\|set_clouds\|flat_sky"
mods/codeblock` must find **nothing**, which is what `09c708d` and later give. On
a release between `6fea453` and the removal, the weaker precondition applies
instead — the guard present and `grep -rn flat_sky minetest.conf settingtypes.txt`
finding nothing, with the setting shown off under Mods → codeblock. Then re-run
`L1` and `L2`, looking at **dawn and dusk in particular**: the one field that
distinguished the two copies is `sunrise_visible = false`, which only `cc_day`
has.

**Pass** — `L1` and `L2` both still pass with nothing but `cc_day` setting the
sky, dawn and dusk included. A sunrise glow appearing is the *opposite* of what a
failure here would have looked like: on a release that still has the copy it
would mean the mod's is running after all, so check the mod rather than `cc_day`.
On a release that has the guard, setting `codeblock_flat_sky = true` to "help" is
the thing not to do — it restores the duplicate in the version that lacks `B47`'s
fix, which is why `ROADMAP.md` records declining it.

Result: pass — `dd83b99` · engine 5.17.0 ·
2026-09-09 — **composed from three reported runs in one sitting, not separately
reported**, and that is the one weakness of this line. This entry's *How* is *"re-run
`L1` and `L2`"* with the mod's copy inert and nothing else, and **both were run
and both passed** in the world above; the residual that held it `partial` is what
`L4` passed on at `/time 5000` and `/time 10000`, the two times the residual was
seen at. The precondition is **read, not run**: nothing in this repository sets
`codeblock_flat_sky` — `grep -rn flat_sky minetest.conf settingtypes.txt
game.conf` finds nothing, checked 2026-09-09 — and the `mods/codeblock` adopted
**when this ran** was `fb75bc8`, whose `lib/register.lua:246` carries the
`if codeblock.config.flat_sky then` guard. **The pointer moved to `09c708d` on
2026-09-17, where the guard, the setting and the mod's five sky calls are all
gone**; that strengthens the precondition and does not disturb the run, which
happened under the guard. So `cc_day` **on its own** is
sufficient for the flat sky, the four sky objects and the pinned light level,
across a rejoin, which is the whole reason this entry exists.

**Two limits, and either is a reason to re-run it as itself.** The author did not
report `L3`, so no advanced-settings menu was looked at and no `y`-value or chat
line was read back; if the composition above is wrong about what was in the
world, this line is wrong with it. And the **`sunrise_visible = false` half can
never be re-established** — under a `plain` sky the client draws no sky mesh, so
the field `cc_day` alone carries is no longer observable; that half's only
evidence is the `partial` below, taken under a `"regular"` sky, and that is why
the line is kept rather than replaced. (`git submodule status` describes
`fb75bc8` as `v0.4.0-208-gfb75bc8` where the line below says
`v0.7.3-139-gfb75bc8`; same commit, a different set of tags fetched, and neither
describe changes which code was adopted.)

Previously partial — `50fd05f` plus the texture rework, **before `A19`'s
`set_sky` line**, so this one line names a tree that is *not* `dd83b99`'s code ·
engine 5.17.0 · 2026-09-09 — **the sky-object half passes; the "regardless
of the time of day" half does not.** With the mod's copy inert — the adopted
`mods/codeblock` is `fb75bc8` (`v0.7.3-139-gfb75bc8`), whose `lib/register.lua:246`
carries the `if codeblock.config.flat_sky then` guard, and nothing in this
repository sets `codeblock_flat_sky` — the author reports **no sun, no moon, no
stars and no sunrise**, in their words *"in codeblock it is disabled"*. That is
the first observation that `cc_day` is sufficient **on its own** for all four,
which is the whole reason this entry exists, and it includes the one field only
`cc_day` has, `sunrise_visible = false`. **`L2`'s half is covered too**: the
sitting included leaving the world and rejoining, and the flat sky held across it,
so "it survives a rejoin with the mod's copy inert" is run. The second-player half
of `L2` remains as `L2` records it — singleplayer only.

**The residual is the sole remaining gap, and it is a shortfall in the game rather
than in this entry's wording.** The author reports *"only luminosity far away
(horizon) changes a bit between time 10000 and time 5000"*, so something on screen
still tracks the time of day, and `L1`'s pass condition — *full daylight
regardless of the time of day* — is not met. The author's decision on 2026-09-09
is that **the game should pin the sky colours**, so neither `L1`'s nor this
entry's pass condition is being loosened to expect a residual blend: this stays
`partial` until the fix lands, and then it is re-run. The author's *"only"* puts
the change at the distant horizon, so nothing reported suggests the **light level**
moved — no darkening of the ground, of a built wall or of the drone's work — and
`override_day_night_ratio(1)` is what holds that.

**A likely cause, not a demonstrated one.** `override_day_night_ratio` is
documented at 5.17.0 as *"controlling sunlight to a specific amount"* and nothing
more; the sky's own colours and its fog belong to `set_sky`, whose `sky_color`
table carries **separate** `day_horizon` and `dawn_horizon` entries and a
`fog_sun_tint`. `cc_day` calls no `set_sky` at all, so the client keeps deriving
the horizon and the fog from the time of day, and `/time 5000` (0.208) sits near
enough to dawn to carry some of that blend while `/time 10000` (0.417) is full
day. That is consistent with the API and with what was seen and is **not proved** —
pinning `sky_color`'s entries, or a `plain` sky, is what would both settle it and
fix it, and the re-run of this entry is what would confirm it.

**Corrected 2026-09-09, and only the cause**: the dawn branch is unreachable
under a pinned day-night ratio and the mover is `m_horizon_blend`, which
`sky_color` does not reach. The observation above stands. `AUDIT.md` `A19`.

### L4 · The sky's own colour and the fog do not move with the time of day, or with where you look [A19]

**Why** — `override_day_night_ratio(1)` pins the light level and nothing else;
the sky's colour and the fog were the engine's, mixed with a sun tint on a curve
of the time of day and by the player's **yaw**. `cc_day` now declares a `plain`
sky, which is the one type the engine excludes from that mix — at the cost of the
gradient. So this check has two jobs: that the shift is gone, and that what
replaced it is worth looking at. **A fresh world will look plainly bluer than it
used to, and that is the fix working**, not a regression: a new world starts at
`time_of_day = 5250` with `time_speed = 0`, so the old sunrise tint was the
game's default look rather than something `/time` had to be typed for.

**How** — enter a world and stand somewhere with a long view: the top of a tall
build, or facing the barrier across open ground.

1. `/time 5000`, then `/time 10000`. Look at the horizon band, the haze over
   distant ground, and the sky overhead at each.
2. `/time 0`, then `/time 22000`. The blend peaks at **4800 and 19200**, so 5000
   is near one peak only; these two exercise the other side, and the branch that
   used to choose night colours.
3. **Turn a full circle** at each of the four times.
4. Have the drone build something you can stand inside — a room with a roof —
   walk in, then walk out.

**Pass** — nothing on screen changes across all four times: the horizon band, the
haze over distant terrain and the sky overhead are one unchanging colour, and the
light level does not move either. Turning changes nothing — **a sky that shifts
as you turn means the `plain` type did not take**, because yaw fed the old blend
and nothing else did. Inside the structure and outside it are the same colour;
under the old sky the inside went grey.

**Pass, second half, and it is a judgement rather than a measurement:** the flat
sky has to be worth its cost. **Over-applied** reads as a flat pale ceiling with
no depth, a terrain-to-sky transition that looks like haze rather than distance,
and a view past the translucent barrier that reads as a wall of colour rather
than open space. If that is what you see, the lever is one hex constant in
`cc_day`: a deeper blue such as `#7ac4f5` reads more like sky, at the cost of
deepening the distant fog with it, since a plain sky uses one colour for both.
**Going back to a gradient is not available** — the residual returns with it
(`ROADMAP.md`, *deliberately not doing*).

One note for whoever writes the result line: under a `plain` sky the client draws
no sky mesh at all, so `L3`'s *"no sun, no moon, no stars, no sunrise"* now
passes for **two** reasons. The four original calls stay in `cc_day` precisely so
a future return to `"regular"` cannot silently restore them.

Result: pass, both halves — `dd83b99` · engine 5.17.0 ·
2026-09-09 — **the first run of this entry and the whole of `A19`'s in-world
evidence.** Reported by the author from a sitting in a world, against the check as
written, so the pass covers all four steps: the horizon band, the haze over
distant terrain and the sky overhead are one unchanging colour across `/time 0`,
`5000`, `10000` and `22000` — which takes in both blend peaks, 4800 and 19200 —
turning a full circle changes nothing, so the `plain` type took, and inside a
drone-built room reads the same as outside rather than going grey. The light level
does not move either. **The second half is a judgement and it went the author's
way**: none of the three over-applied signals is reported, so `#90d3f6` stays and
the one hex constant is not moved.

**The code under test was uncommitted when this ran and is committed now.**
`player:set_sky({type = "plain", base_color = "#90d3f6"})` was working-tree only
in `mods/cc_day/init.lua`; `dd83b99` was made the same day with `git add -A` over
that tree and carries the line byte-identically, so the sha above is reproducible
and **no re-run is owed**. The rule is that a result does not survive a change to
the code it exercised, and nothing changed: a re-run would execute the same bytes
and could only produce the same output.

**Limits.** The report was the single word *pass* for an entry with four steps and
two halves, so **nothing was read back**: not which of the four times were typed,
not whether the circle was turned at all four rather than at one, not whether the
room was built and walked into. Each of those is a sub-condition that fails
quietly — a sky that shifts only at `22000`, or only as you turn, or only indoors,
is exactly what one time and one heading would miss — and the pass rests on the
runner having followed the steps. The three over-applied signals are the same:
their absence is inferred from a bare *pass*, not from a described view.

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

**Making the two digging checks able to fail — the setup `R1` and `R2` share
(`A20`).** Since `50fd05f` the engine's builtin hand has **empty `groupcaps`**:
`mods/default/tools.lua` was the only hand override in the tree and `G3` deleted
it, so **no node in this game is hand-diggable, with or without `cc_security`**.
Neither `R1` nor `R2`'s drop half can fail as written, and `R1` would pass with
`cc_security` deleted outright. Both are run from one sitting with the setup
below, which is **three things to undo, not two**. It is written once here rather
than twice in the entries.

**The order matters, because the two checks want different states.** `R1` wants a
hand that *could* dig meeting a restriction that is still on; `R2`'s drop half
wants that hand meeting a restriction that is off. So the hand override goes in
first, `R1` is run against it, and only then are the two `cc_security` lines
commented out for `R2`.

1. Add a hand override at file scope in `mods/cc_security/init.lua`. **Run once,
   on 2026-09-09, and it works** — it is what made `R1` falsifiable and reached
   `R2`'s drop half in the same sitting:

   ```lua
   minetest.override_item("", {tool_capabilities = {full_punch_interval = 1, max_drop_level = 0,
       groupcaps = {oddly_breakable_by_hand = {times = {[1]=0.5,[2]=0.5,[3]=0.5}, uses = 0}}}})
   ```

   Overriding `""` is documented — `lua_api.md` 5.17.0 lines 2324-2327 — and
   works at 5.9.0, this game's floor.
2. Fully restart the server. Then **select an empty hotbar slot, 3 to 8, before
   punching anything.** `codeblock:poser` and `codeblock:setter` are put in slots
   1 and 2 on join and both are `usable`, so with either wielded a left-click
   **runs your program instead of digging** and nothing happens — which reads
   exactly like a pass. This trap is independent of everything else here. **`R1`
   is run at this point**, and this is the only state in which it can fail.
3. Then, for `R2`'s drop half only, comment out **two** lines in the same file's
   `override_item` call — `diggable = false` and `groups = groups`. **Before
   restarting, count the comment markers: there must be two.** With only the first
   commented out the groups are still stripped, so no node has a groupcap even
   this hand can beat, and what you see is *"cannot dig"* rather than a failure.
   Restart again.

**Undo all three afterwards** — the hand override and the two comments — and
check `git diff mods/cc_security/init.lua` is empty before finishing. **Three
things to undo, and the count is the safeguard**, exactly as the two-comment count
is.

**That final `git diff` earned itself on the first run.** After the 2026-09-09
sitting all three were undone and the file still differed: **two blank lines were
left at file scope** where the hand override had sat. Harmless — luacheck was
silent either way — but it is the same residue a *half*-undone override would
leave, and the only thing that distinguishes the two is reading the diff. The
blank lines were removed and the file is byte-identical to `50fd05f`, which is
how it is committed at `dd83b99`. Read the
diff; do not assume the undo was complete because you remember doing it.

Chosen on 2026-09-09 over a `core.dig_node` chat command, which was considered
and declined: this setup reaches `R1`'s real subject, a hand that *could* dig,
and `R2`'s drop half in the same sitting, where a scripted `dig_node` reaches only
the second.

### R1 · Nothing is diggable [A20]

**Why** — the override pass runs once at `on_mods_loaded` over
`minetest.registered_nodes`, so a node registered later — by another mod, or by a
node the game adds later — is not covered. And since `B48` an inner `pairs` over every
node's `groups` runs in the same loop: if it errors on any single node,
`register_on_mods_loaded` aborts and **every node after that point keeps
`diggable = true`**. Table iteration order is not stable, so a partial failure hits
a different set of nodes on every boot and one punch on one wall would miss it.

**And since `50fd05f` this check cannot fail at all without the shared setup
above** — the hand has empty `groupcaps`, so **`R1` would pass with `cc_security`
deleted outright** (`A20`). A restriction check that cannot fail is exactly what
this document exists to prevent, so the run that counts is the one with the
temporary hand override in place; a run without it says only that a hand which
could not dig anything did not dig anything.

**How** — apply steps 1 and 2 of the shared setup above and **not step 3**: the
hand override added, the server restarted, an **empty hotbar slot (3-8)**
selected, and `cc_security`'s two lines left exactly as they are. Then punch and
hold on the ground, on the surface layer, on a wall the drone
built, and on **one of each of CodeBlock's three variants** — a solid block, a
glass and a lamp, since they carry different `oddly_breakable_by_hand` levels.
Include the barrier at the world's edge. Try a colour the drone can place but you
have not seen before, and try it in a fresh world rather than the one already
open. Remove the hand override afterwards.

**Pass** — nothing breaks, anywhere, on any node, **with the hand override in
place**: that is the restriction refusing a hand that could otherwise dig, and it
is the only version of this check that is evidence. A run with no hand override is
not a result — nothing was exercised, because nothing could have been dug. If a
node does break, the override pass covered fewer nodes than it should and the
finding is `A8`'s walk, not this setup.

**Method rewritten again 2026-09-09 for `A20`, and this is the bigger casualty of
`G3`.** The *Why* above rested on a partial override pass leaving nodes with
`diggable = true`; a node in that state is **still not diggable by hand** since
`50fd05f`, so the whole check had become unfalsifiable and the 2026-09-01 pass
below says nothing about today's code beyond it not crashing. The hand override is
what restores the check; the change is to this document and it carries no id of
its own — `A20` is the defect in committed code that made it necessary.

**Method rewritten 2026-09-08 for `G3`.** It said *"including one from `wool` and
one from `default`"*; both mods are deleted, so every node a program can place is
`codeblock:*` and the ground is `cc_mapgen`'s. The pass below was against the old
set of nodes and is owed a re-run for that reason as well as for `B48`.

Result: pass — `dd83b99` · engine 5.17.0 ·
2026-09-09 — **the first run of this check that could have failed**, and that is
the whole of what makes it worth more than the line below. The temporary hand
override from this group's preamble was in place, so the punch came from a hand
with a usable `oddly_breakable_by_hand` groupcap, and **nothing broke**. That is
`cc_security`'s override pass refusing a hand that could otherwise dig, which is
the claim this entry has been unable to make since `50fd05f` (`A20`).

**The setup is corroborated by the working tree and not only by the report.**
Before anything was recorded, `mods/cc_security/init.lua` was inspected: `groups =
groups` and `diggable = false` were **restored**, the `override_item("", …)` hand
override was **gone**, and two stray blank lines sat at file scope exactly where
it had been. So all three things were really added and really undone — this is
not a report against an unmodified tree, which is the failure mode that would make
a *pass* here worthless a second time. The blank lines have since been removed and
`cc_security` is byte-identical to `50fd05f` and committed that way at
`dd83b99`, with luacheck silent.

**Limits, and they are the whole of the entry's breadth.** The report was the
single word *pass*, so **none of the subjects was read back**: not the ground, not
the surface layer, not a drone-built wall, not one of each of CodeBlock's three
variants — the solid, the glass and the lamp carry different
`oddly_breakable_by_hand` levels and are the reason the entry names three — not
the barrier at the world's edge, not a colour the author had not seen before, and
not whether a **fresh** world was used as well as the one already open. The
entry's *Why* is a partial override pass leaving a different set of nodes
`diggable` on every boot, and only breadth of subject reaches that; one punch on
one wall passes this line as written. Nor was the empty-hotbar-slot trap read back
— with `codeblock:poser` or `codeblock:setter` wielded a left-click runs the
program instead of digging and reads exactly like a pass.

Previously pass, with two things it turned up — `7f649d8` · engine 5.17.0 ·
2026-09-01 — **superseded, and kept because it is where `B48` and `S8` were
found.** It predates `G3` on both sides: the nodes it punched are deleted, and
`mods/default/tools.lua` still gave the hand its groupcaps, so it was *not* an
unfalsifiable run at the time — the wool observation below is a node the client
believed a hand could break. What the status table has been counting is narrower
than "proves nothing": it is that **re-running the check as it then stood, on
today's code, could not fail**, so this line says nothing about the current tree.
Nothing breaks, anywhere, on any node tried. The rule holds. But:

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
`/giveme` put an item in an inventory, a different path; privileges do not help,
because `diggable = false` is a node property, *"if false, can never be dug"*, so
`node_dig` refuses before drops are computed however privileged the player; and
the drone writes with `set_node` and `VoxelManip` (`lib/commands.lua`,
`lib/shapes.lua`), neither of which computes drops, so `R4` does not exercise this
either.

**Corrected 2026-09-09: this said *"nothing exposes `core.dig_node`"*, and the
engine does expose it.** `core.dig_node(pos[, digger])` — `lua_api.md` 5.17.0
line 6964 — and the `digger` argument is honoured from 5.9.0 onward via the
`node_interaction_actor` feature flag (line 6223), which is exactly this game's
floor. So a chat command calling it was a real route to the drop half and is
recorded as **considered and declined** the same day, in favour of the hand
override in the group preamble: `dig_node` reaches the drop chain but never `R1`'s
subject, and the override reaches both in one sitting. The correction is kept
rather than deleted because the wrong claim is what made the drop half look
unreachable by any means.

**How** — open the inventory. Then, to reach the drop half, apply **all three**
steps of the shared setup in this group's preamble: the hand override, an empty
hotbar slot (3-8) selected, and the two `cc_security` lines commented out. Dig a
node by hand, then **undo all three**. Nothing less reaches this half — with the
lines commented out and no hand override the hand still has no groupcap to dig
with, which is what the 2026-09-09 re-attempt hit.

Commenting out both lines is not cheating the check: an uncovered node is exactly
the situation the guard exists for, and the hand override only supplies the
capable hand `mods/default` used to.

**Pass** — the inventory formspec is blank; the node dug with the setup in place
disappears and **no item appears**. The observation is that **nothing appears in
the hotbar and no item entity appears at the dug position** — not "open the
inventory", which was this entry's old wording and is the wrong place to look:
builtin's `handle_node_drops` does `inv:add_item("main", item)`
(`item.lua:465-491`), the guard from `S8` is a
`register_allow_player_inventory_action` and does not see a Lua-side `add_item`,
and the first free `main` slot is **slot 3**, which is in the hotbar and visible
without opening anything. `creative_mode = true` does not make this pass for free
either: there is **no creative-mode gate on drops** anywhere in builtin's
`node_dig`. `handle_node_drops` passes an empty list to whatever it captured, so
nothing is ever handed out. (`A8`)

Result: pass, both halves — `dd83b99` ·
engine 5.17.0 · 2026-09-09 — **no longer blocked, and the drop half is now
repeatable in a way it was not this morning.** The first run of this entry since
`7dc764f` on 2026-09-02, and the first ever under the corrected method: all three
steps of the group's shared setup in place — the hand override, an empty hotbar
slot, and **both** `cc_security` lines commented out — a node dug by hand
disappeared and **no item appeared**. So `previous_drops` is not `nil`, the chain
fires, and the empty list reaches the captured handler (`A8`). The inventory half
passes with it: the formspec is blank.

**Which half the pass covers, and why the drop half is the one that counts.** The
inventory-formspec half has passed since 2026-09-01 and could be re-observed by
opening a panel; the drop half is what has been unrunnable all day. The setup that
reaches it is corroborated by the working tree rather than by the report alone —
before anything was recorded, `mods/cc_security/init.lua` had `groups = groups`
and `diggable = false` **restored**, the hand override **gone**, and two stray
blank lines at file scope where it had sat. Both comments were therefore really
made and really undone, which is also the two-comment count the method warns
about being met. The blank lines have since been removed; `cc_security` is
byte-identical to `50fd05f` — as committed at `dd83b99` — and luacheck is
silent.

**Limits.** The report was the single word *pass*, so **the pass observation
itself was not read back**: the entry asks for the **hotbar** — slot 3, the first
free `main` slot — and the **dug position**, and neither was described. That
matters more here than in most entries, because this method was corrected on
2026-09-09 away from *"open the inventory"*, and a runner working from memory of
the old wording would look in the wrong place and see nothing either way. Nor was
it said which node was dug.

Previously pass, both halves — `7dc764f` · engine 5.17.0 · 2026-09-02 — the
inventory formspec is blank, and **the drop half ran for the first time**: with
`diggable = false` commented out and the server restarted, a node dug by hand
disappeared and no item appeared, on the ground or in the inventory. The line was
reverted afterwards. So `previous_drops` is not `nil`, the chain fires, and the
empty list reaches the captured handler — the one thing `A8` changed that could
have failed silently. What this still does not establish is that no inventory is
*reachable*: `R1` found a bookshelf's own formspec shows the player's `main` list
(`S8`).

**A re-attempt on 2026-09-09 could not dig anything at all, and it was not a
method slip.** At `dd83b99`'s code, on engine 5.17.0, the author commented out
**both**
lines and **did fully restart the server**, and still could not dig — confirmed
with them directly. So the two-comment trap is **not** the explanation for this
run: the setup was right and something else refused. **No evidence was produced
either way** — this is not a `fail`, not a `partial` and not a regression, and the
2026-09-02 pass above is untouched, because a run that exercises nothing cannot
contradict one that did. The comment count is still written into the shared setup,
because it remains a real trap that someone will hit — just not the one hit here.

**Diagnosed on 2026-09-09, and it was the third hypothesis: the engine's default
hand has no usable groupcap since `G3` deleted `mods/default/tools.lua`.** Traced
read-only through the engine at both 5.9.0 and 5.17.0 and through the adopted
`mods/codeblock` at `fb75bc8`, and **not run in a world** — the finding is `A20`,
which holds the trace. Two layers refuse, and either alone explains the sitting:
the builtin hand's `groupcaps` are empty, so `getDigParams` returns
`diggable = false` and no dig packet is ever sent; and slot 1 holds
`codeblock:poser`, which is `usable`, so a left-click sends `INTERACT_USE` and
runs the program instead of pointing at the node. The other two hypotheses are
**ruled out**: `codeblock` protects nothing — no `is_protected`, no `can_dig`, no
`on_dig` — and nothing in `cc_security` refuses a dig independently of `diggable`
and the groups. So the drop half **was impossible as written**, which makes it a
defect in this document; it is fixed above by the shared setup rather than by any
change to the game.

**Closed out the same day: the diagnosis was right and the fix works.** The drop
half ran and passed at `dd83b99`, with the hand override in place — see the top result — so the refusal was the hand's empty
`groupcaps` and nothing else, and `A20` is confirmed in a world rather than only
traced. The two paragraphs above are kept rather than compressed away, because
what they record is a **run that produced no evidence**, which is the case this
document is most likely to meet again and hardest to recognise while it is
happening: correct setup, a confident report, and nothing exercised.

Previously pass on the inventory half only — `7f649d8` · engine 5.17.0 ·
2026-09-01 — nothing was dug, because nothing could be.

### R3 · No knockback

**Why** — `calculate_knockback` is replaced to return 0.

**How** — take a hit, from another player or from anything that would push you.

**Pass** — you are not moved.

Result: pass — `dd83b99` · engine 5.17.0 ·
2026-09-09 — no knockback, re-run at the current tree. This is the thirty seconds
the *what needs action* table had been holding `R5` open for.

Previously pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — no knockback.

### R4 · The drone can still build [R1 must not have broken it]

**Why** — the widening control. `diggable = false` is a property of the node for
a *player's* tool and the drone writes the map directly, so it must be unaffected;
this is the check that says a restriction has not been made so broad it disables
the point of the game. It also guards the `B48` loop, where six groups have just
vanished from under whatever might have been reading them.

**How** — run `stairs.lua`, then a program that places and one that removes
blocks. Run it in the same session as `R8`.

**Pass** — the drone places and removes normally.

**Re-run owed, recorded 2026-09-22 and not run.** Both submodule pointers under
the drone have moved and are committed: `vector3` to `fc8a5b8` (`v2.0.2`) at
`c2d2b5a`, a **major version of a hard dependency**, and `codeblock` to `09c708d`
at `34b3820`, sixteen commits including a substantially rewritten
`lib/sandbox.lua`. The newest result below names `6f2409e`, which is **before
both** and is the oldest commit any live result in this document names. Run it
with `R9`.

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

Result: pass, both halves — `dd83b99` ·
engine 5.17.0 · 2026-09-09 — **composed from two reported runs, not separately
reported**, which the entry pre-authorised in writing: its *How* is *"re-run `R3`,
and run `R2` by its drop method"* and nothing else, and the `partial` below said
in as many words that this becomes a pass the moment `R2`'s drop half runs at the
current tree. Both halves are now on the same tree — `R3` passed on 2026-09-09,
nothing pushes you; `R2`'s drop half passed on 2026-09-09 under the hand override,
no item appears. So `previous_drops` is the engine default, the chain fires, the
empty list reaches it, and the one thing `A8` changed that could have failed
silently did not. **Limits.** Nobody reported running `R5` as itself, so this line
is only as good as the two it composes and inherits both their limits — chiefly
that `R2`'s pass observation, the hotbar and the dug position, was not read back.
And `A8`'s **`last_mod` half remains untested by choice**, exactly as the
paragraph above records: it needs a second mod that assigns the same globals and
none ships here.

Previously partial — `7dc764f` · engine 5.17.0 · 2026-09-02 — **the half that
could have broken is done.** `R2`'s drop method passed: the chain fires, hands an empty
list to the captured handler, and nothing drops. `R3` was not re-run on current
code, so the knockback half is still resting on its 2026-09-01 pass. The risk
there is small — `A8` left `calculate_knockback` byte-identical and nothing
competes for it — but small is not none, and thirty seconds closes it.

**The gap that line names was closed on 2026-09-09 and another opened in its
place, so this stays `partial` and no result is moved.** `R3` was re-run at
`dd83b99` and passed, so the knockback half no longer rests on 2026-09-01. But `R2`'s drop half was re-attempted the same day and
**exercised nothing** — correctly set up, both lines commented out and the server
restarted, and still nothing could be dug — so that half's evidence is still the
2026-09-02 pass at `7dc764f`. Nobody ran `R5` itself today; this note records what
the two halves stand on, and the entry is a pass the moment `R2`'s drop half runs
at the current tree.

**That re-run is no longer blocked, 2026-09-09.** The refusal is diagnosed as
`A20` — the hand has had no groupcaps since `G3` — and `R2`'s method now carries
the temporary hand override that reaches the chain. `A8`'s drop half therefore
still rests on `7dc764f`, and the run that would move it is one sitting away
rather than waiting on a diagnosis.

**That sitting happened, later the same day.** `R2`'s drop half ran under the hand
override and passed at `dd83b99`, so `A8`'s drop half no longer rests on `7dc764f` and this entry is the composed pass at the
top. The two paragraphs above are kept because they are the record of how the half
came to be blocked and unblocked in one day.

### R6 · A bookshelf opens nothing you can use [S8]

**Unrunnable since `G3`, 2026-09-08, and kept rather than deleted.** The check
names `default:bookshelf` and `A13`'s deletion removes the mod that registered
it; **no node left in the game carries a formspec of its own**, so there is
nothing to open and no way to re-run this. The pass below stands as what was seen
at `c042364`. `S8`'s fix is unaffected — it is the guard on the *player's* own
inventory, which `R9` exercises from the other side — and `S8`'s residue, a panel
that still opens, goes with the node. Nothing replaces this entry: the hazard it
covered no longer exists.

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

**Unrunnable since `G3`, 2026-09-08, and kept rather than deleted.** All three
cases name a `default` node — `dirt`, `dirt_with_grass`, `grass_3`, a sapling —
and `A13`'s deletion removes the mod that registered them **and the six ABMs and
ten `on_timer`s this check was about**. Nothing left in the game registers either,
so `B49`'s fix walks empty sets and there is no behaviour left to observe. The
pass below stands as what was seen at `d16f9bb`, and it is the only evidence there
will ever be that mutating an ABM's `action` works — worth keeping for that
reason, since the technique is undocumented and another game may need it.
`cc_mapgen:grass` is not a spreading node and has no timer, so the defect cannot
return through the new surface.

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

1. A **solid** CodeBlock block, any colour — `place('red')`. Carries
   `oddly_breakable_by_hand = 2`, the shallowest hand level in the game, so it is
   the case a partial strip shows first.
2. A **glass** block — `place('red_glass')`. `oddly_breakable_by_hand = 3`, which
   is what `wool` was, and glass is where a crack overlay is easiest to see
   through the node.
3. `cc_mapgen:grass`, the ground you are standing on, and the barrier at the
   world's edge. Neither carries any group at all, so neither ever cracked and
   neither must start. The control: ground that now behaves differently means
   something other than the digging groups was touched.

Then confirm the strip did not cost anything else — every block must still show
its colour, glass must still be see-through and a lamp must still light, because
the fix keeps every non-dig group deliberately. Run `R4` and `R9` in the same
session; this change edits the loop both guard.

**Subjects rewritten 2026-09-08 for `G3`.** They were `wool`, `default:leaves`
and `default:stone`, all deleted with `A13`. Two things are lost with them and are
recorded rather than smoothed over: **there is no `dig_immediate` node left in the
game**, so the instant-crack case — the fastest one, and the one a partial strip
would still show — cannot be reproduced at all; and the hand's groupcaps no longer
come from `mods/default/tools.lua` but from the engine's default item, so what the
client predicts is a different calculation from the one the finding was diagnosed
against. `B48` records both.

**Pass** — on all three, **no cracking texture appears at any stage**, not stage
one and not a single frame, and **no dig sound plays**. A block that does not
break while the first crack stage still flashes is the whole defect reading as a
pass, and only holding the punch and watching the face catches it; a solid block
that stops cracking while the glass still flashes means the group list is
incomplete, not that the fix works. The nodes are also still there afterwards,
which is `R1`'s claim and not this one.

Result: pass — `dd83b99` · engine 5.17.0 ·
2026-09-09 — **no cracking texture at any stage and no dig sound, on all three
subjects.** This is the first in-world judgement of `B48`'s fix, and the whole of
its evidence: until now the claim that the client stops predicting a dig rested on
reading the `groups` rebuild in `cc_security`'s override pass. **Limits.** The
report was the single word *pass*, so nothing was read back about which subject
was watched, for how long, or whether the solid and the glass were compared
against each other — the pass is against the check as written, whose steps ask for
a full two seconds each with sound on. And the **instant-crack case is
unreproducible**: `G3` deleted the last `dig_immediate` node, so the fastest case,
the one a partial strip would still show, is gone from the game and no run can
recover it. `B48` records that.

**That pass has a second explanation, found on 2026-09-09 and recorded here
rather than allowed to be re-derived.** The hand has had **empty `groupcaps`**
since `G3` (`A20`), and the client suppresses the crack overlay outright for a
node no hand can dig — `// Don't show cracks if not diggable`,
`game.cpp:3330-3331` at 5.17.0 — with the dig sound gated the same way. So a
blank screen and silence are what the empty groupcaps alone would produce, with or
without the group strip this check exists for. **The pass stands and `B48` stays
closed**: the fix is correct and nothing observed contradicts it. What this check
can no longer do is *distinguish* the two causes, and it will not be able to until
the game has a hand definition — which it is deliberately not getting. Run with
the hand override from this group's preamble, this check would separate them; it
was not run that way and nobody has done so.

### R9 · The drone places and removes CodeBlock's own blocks, and nothing else exists [A13]

**Why** — the palette is entirely `codeblock:*` after `G3`, so **every block a
program can name is a node registered by the mod rather than by a vendored
one**, and that has never been played. Two ways it fails quietly: a program naming
a colour that no longer resolves places the default block instead — the mod warns
in chat once and carries on, so a wrong-coloured build looks like a working one —
and `cc_security`'s override pass now runs over the mod's 105 nodes, which is
where a `groups` rebuild would break the mod's own colour or light. `R4` says the
drone still builds; this says it builds *the right blocks*, out of the only set
there is.

**How** — in a **new** world, run a program that touches all three variants and
then takes them away again:

```lua
local names = {'red', 'green', 'blue', 'white', 'black'}
for i, n in ipairs(names) do
    move(1, 0, 0)
    place(n)
    move(0, 1, 0)
    place(n .. '_glass')
    move(0, 1, 0)
    place(n .. '_lamp')
    move(0, -2, 0)
end
```

Look at the result, then run it again with every `place` argument replaced by
`air`. Watch the chat while it runs. Then run **two separate one-line programs**
for a name that does not exist, because they reach two different code paths and
only the first is the quiet failure this check exists for.

```lua
place(colors.vermilion)   -- the quiet path: a table lookup that misses
```

```lua
place('vermilion')        -- the loud path: a string that is not a block
```

**The two are not interchangeable, and the step above said the wrong one until
2026-09-09.** This was corrected by reading the adopted `mods/codeblock` at
`fb75bc8` (`v0.7.3-139-gfb75bc8`), so it is checked against that release and no
other — **and `lib/sandbox.lua` changed substantially at `09c708d`, adopted
2026-09-17**, so re-read the two line references below before running this step:

- `lib/sandbox.lua:159` defines `unknown_block`, and `:332` installs it as the
  miss handler on every block category — the three are `colors`, `glass` and
  `lamps`. So the *"no block named"* warning fires on a **lookup into a
  category**, `colors.vermilion`, which reads as `nil` and lets `place` fall back
  to the drone's default block. That is the silent wrong-colour build.
- `place('vermilion')` never reaches that handler. The string goes straight to
  `lib/commands.lua:110`, `if not real_block then error(S('Cannot place this
  block'), 4) end` — French *"Impossible de placer ce bloc"* — which is a **hard
  error that stops the program**. The same message is raised from `:581` when a
  program sets a bad default block.

**The warning is said once per run.** `warned` is an upvalue of the environment
`getScriptEnv` builds fresh for each run, so a second misspelling in the same
program is silent **by design** and must not be read as a failure here. Put each
misspelling in its own run.

**Pass** — fifteen blocks in five colours and three materials: the solids show
their colour, the glass is see-through and tinted, and **each lamp lights its
surroundings**, which is the variant most likely to be broken by a `groups`
rewrite. The second run leaves nothing behind. No chat warning at all during the
first two runs — a *"no block named"* warning means a name the palette no longer
carries, and the block placed will be the default one rather than nothing, so the
build still looks plausible. The deliberate `vermilion` **must** produce that
warning: a run with no warning means the misspelling report is not working and the
first two runs proved less than they appear to. The two misspelling runs have
**different** pass conditions and both are required:

- `place(colors.vermilion)` — the chat says *"no block named 'vermilion', the
  default block is used instead"*, **the program carries on**, and a block of the
  drone's default colour is left behind. That block being there is the point: it
  is what a wrong-coloured build looks like from the inside.
- `place('vermilion')` — the program **stops** with *"Cannot place this block"* /
  *"Impossible de placer ce bloc"*, and **nothing is placed**. A fallback block
  appearing here instead would mean a misspelt string silently builds something,
  which is the defect the hard error prevents.

No `default:*` or `wool:*` node can be named at all.

Result: pass — `dd83b99` · engine 5.17.0 ·
2026-09-09 — **the quiet path is run and this clears to a full pass**, the second
sitting of the day on the same tree. The `partial` below named exactly one thing
owed — *"two one-line programs, `place(colors.vermilion)` and
`place('vermilion')`, per the corrected method. Nothing else in this entry is
owed"* — so a *pass* reported against this entry cannot be a pass of the cheap
half: the fifteen blocks were already passed below and were not what was
outstanding. That asymmetry is why a bare word clears this entry and does not
clear `L4` or `R1`, whose several parts are all live at once.

**What the two paths now stand on.** `place(colors.vermilion)` — the quiet path,
`lib/sandbox.lua:159` and `:332` at `fb75bc8` — warns *"no block named
'vermilion'"* once, the program carries on, and a **default-coloured block** is
left behind, which is what a wrong-coloured build looks like from the inside and
is the failure mode `A13`'s palette change could have introduced silently.
`place('vermilion')` — the loud path, `lib/commands.lua:110` — **stops the
program** with *"Impossible de placer ce bloc"* and places nothing; that half was
already observed in the first sitting and is pinned as a pass condition of its
own. **The warning is said once per run by design** — `warned` is a per-run
upvalue of the environment `getScriptEnv` builds — so a second misspelling going
silent is not a failure here, and putting each misspelling in its own run is what
the method asks for.

**Limits.** The report was the single word *pass*, so **the distinguishing
artefact was not read back**: nobody described the chat warning, and nobody
described the default-coloured block being left where `colors.vermilion` was
placed. That block is the pass condition, not the warning — a run that saw the
warning and no block would be a different outcome and would read the same in a
one-word report. Nor was it confirmed the two programs were run separately rather
than as one. The paragraphs below belong to the superseded `partial` and are kept
because they hold why the step was wrong before it was corrected.

Previously partial — `dd83b99` · engine 5.17.0 · 2026-09-09 — **the fifteen
blocks pass and the quiet-fallback step has still never
been run.** What was established: fifteen blocks in five colours and three
materials, the solids showing their colour, the glass see-through and tinted, each
lamp lighting its surroundings — the variant a `groups` rewrite would break first —
and the `air` run leaving nothing behind. So `cc_security`'s override pass runs
over the mod's 105 nodes without costing colour or light, and the palette a program
can name is entirely `codeblock:*`. That is the first time any of it has been
played.

**Why `partial` and not a pass with a gap named.** The entry's *Why* gives **two**
quiet failure modes and the misspelling fallback is one of them — a wrong-coloured
build that looks like a working one. The author's `place('vermilion')` produced the
hard error *"Impossible de placer ce bloc"*, which is `lib/commands.lua:110` and
**not** the warning this check asks for, so the quiet path was never exercised and
the step as written could not exercise it. An unrun half reads as `partial` in this
document — the same rule `W8` and `L3` are recorded under — and calling it a pass
would put the entry's headline claim above its evidence. The **loud** path is now
observed and is pinned as a pass condition of its own above, because a misspelt
string stopping the program is desirable behaviour worth keeping.

**What to re-run**, and it is two one-line programs: `place(colors.vermilion)` and
`place('vermilion')`, per the corrected method. Nothing else in this entry is
owed. — **Run in the second sitting of 2026-09-09 and passed; see the top
result.** This paragraph is what makes that pass readable as covering the quiet
path and nothing less.

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

**Not a result, and deliberately not recorded as one: both current pointers are
fetchable, read on 2026-09-22.** From a fresh recursive clone, `git fetch origin
09c708d` in `mods/codeblock` and `git fetch origin fc8a5b8` in `mods/vector3` each
succeeded, and `git cat-file -t` gave `commit` for both — so neither of the
pointers this game intends to ship names an object nobody can fetch, which is the
single failure this entry exists for. **It is strictly less than the check.** The
clone's own submodules populated at `35fa2a1`, the previous release, because the
candidate commit is unpushed, so no clone has yet *checked out* these pointers by
`--recurse-submodules`, and the boot half has still never been run. The `partial`
above stands unchanged.

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

**`G3` changes what a clean log means here, 2026-09-08.** Both of the seven
messages' causes are deleted with `mods/default`, so a re-appearance of either is
now impossible rather than merely unexpected — which makes this check cheaper and
narrower. What replaces them is the other direction: `cc_mapgen` now registers
`mapgen_stone` and two water aliases, and a missing or misspelt one **is** a
resolver error of exactly this shape. `W16` is written around it and this check is
its log half; run the two together.

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

### P6 · Every form and the hotbar wear the game's own style [B57]

**Why** — a formspec prepend is invisible outside a form, so nothing about this
can be seen from the world, from the menu or from either gate. The forms a player
actually opens belong to **CodeBlock**, which sets no styling of its own, so this
is also the check that the game's prepend reaches a mod it does not own — the
mechanism that carried `mods/default`'s styling before `50fd05f` and `B57` after
it. The hotbar is the same subject by a different call and is on screen from the
first second.

**How**, in a new world — look at the hotbar as soon as you spawn. Then run
`/codeblock tools`, which is the only way to be given them here — the mod stopped
putting them in the hotbar on join and `cc_security` blanks the inventory
formspec, so the creative inventory does not open (`P7`). Holding the **Drone
setter** (`codeblock:setter`):

1. **right-click** with it, which opens the file editor;
2. **left-click** with it, which opens the drone panel.

Open each against two backgrounds — facing the grass, then facing the sky — and
compare the same view with the form closed.

**Pass** — the hotbar draws the game's own frame and its own selection marker,
not the engine's default; both forms draw an opaque panel in the flat
grass-and-bedrock palette, with the same panel on both. Two near misses. A panel
that merely looks darker over grass than over sky is the engine's semi-transparent
default and is a **fail** — that is what the two backgrounds are for. And styling
that appears on one of the two forms and not the other is a `no_prepend[]` inside
that form, which is the mod's to change, not a failure of the prepend.

Result: unchecked

### P7 · A new player can get the drone tools at all

**Why** — the two tools are the whole of the game's interface to the drone, and
**nothing in this game gives them out.** CodeBlock stopped putting them in the
hotbar on join, and `cc_security` blanks the player's inventory formspec, so the
creative inventory cannot be opened either. That leaves `/codeblock tools` as the
only route, and it is a route a new player has to be told about — which is why
both `README.md` and `CONTENTDB.md` now open with it. A new world that hands a
player nothing they can use is the worst failure this package can have and no
gate reaches it.

**How**, in a new singleplayer world, as the first thing done in it:

1. Look at the hotbar on spawning, and press `i`.
2. Run `/codeblock tools`.
3. Right click a block with the **Drone placer**.

**Pass** — step 1 finds an empty hotbar and **no inventory menu opening at all**,
step 2 puts the Drone placer and the Drone setter in the hotbar, and step 3 opens
the program list. A near miss: the tools already being in the hotbar at step 1
means something gives them out after all, which is a **pass of the game** and a
defect in this entry and in both documents — report it rather than recording a
fail.

Result: unchecked

---

## Revisions

Newest first.

- **2026-09-22, at `0a605a3`: what the nine commits since `dd83b99` owe, verified
  against the tree.** Nothing was run in a world, **no `Result:` line was changed
  and nothing moved off `unchecked`**; the counts stay at **36 entries, 29 pass, 1
  partial, 0 fail, 6 unrun**. The newest commit any result names is `dd83b99` and
  HEAD is nine commits later, so every claim here is about a tree nine commits
  old. What the nine change, read from `git diff dd83b99..HEAD` rather than
  assumed: `minetest.conf`'s `mapgen_limit` 1024 → 4096 and
  `mods/cc_mapgen/init.lua`'s matching fallback, which is unreachable while the
  conf is read and so adds no re-run; `mods/cc_gui/` **new** at `ba92d52`, with no
  in-world evidence of any kind, so **`P6` is now runnable and is `B57`'s only
  evidence**; both submodule pointers, `vector3` → `fc8a5b8` (`v2.0.2`) at
  `c2d2b5a` and `codeblock` → `09c708d` at `34b3820`, which no result names, so
  `R4` and `R9`'s re-runs are owed on the record; and `mods/cc_day/init.lua` and
  `mods/cc_security/init.lua` **comment-only**, confirmed by reading the diff, so
  neither owes anything. `W3`, `W5`, `W6` and `W7` remain the set the widening
  touches, and it is complete for the code: `W6`'s recorded pass names **1024**,
  which its own *Pass* now declares the failure, and that is noted in the entry
  rather than retired. `W4`, `W8` and `W9` are still owed the older **depth**
  re-runs. **`W12` is a fifth entry affected and not by a re-run**: its *Pass*
  named *"World half-extent at 1024"* against a `settingtypes.txt` that declares
  4096 — a defect in the entry, not in the code, so no finding id. Found and
  corrected to 4096 in this same pass, on 2026-09-22; the pass at `3479e25`
  stands and no re-run is owed. `P1` gains
  the reading half at the current pointers: a fresh recursive clone fetched
  `09c708d` and `fc8a5b8` by hash, `cat-file -t` → `commit`, but populated at
  `35fa2a1` because the candidate is unpushed, so the `partial` stands and the
  boot half is still unrun.
- **2026-09-17, over `7f3a39b`, with the configuration change uncommitted in the
  working tree: the world widened to 4096, four `W` methods
  rewritten, and `P7` added.** Nothing was run and **no `Result:` line was
  changed**; the counts go to **36 entries, 29 pass, 1 partial, 0 fail, 6 unrun**.
  The default `mapgen_limit` went from 1024 to 4096 (`ROADMAP.md` `G6` decision
  9), which moves the wall from 1007 to **4047**, the field from 2000 to **8080**
  nodes on a side, and the buildable ceiling with it. Every `W` method that named
  a coordinate or a distance was written for the old world: `W3`'s stale note is
  stale in the other direction and now carries a command, `W5` teleported *past
  1000* and now names 4040, `W6`'s pass condition **inverts** — 4096 was the fail
  and is now the pass — and `W7` compared a world at 4096 against a game at 1024,
  which the widening makes vacuous, so it is rewritten around a world at `2000`
  or `1024`. All four keep their passes, which stand as what was seen under the
  old setting, and all four are owed re-runs. `W6` also gained the one thing it
  does not settle: the drone reads the raw setting and the wall is 49 nodes short
  of it. **`P7` is new and is the first entry about a player getting the tools at
  all** — nothing in this game gives them out, the mod stopped doing it and
  `cc_security` blanks the inventory formspec, so `/codeblock tools` is the only
  route and it had never been checked or documented. `P6`'s *How* carried the
  false premise and is corrected with it.
- **2026-09-17, over `34b3820`: `P6` added for `B57`, and nothing was run.** No
  `Result:` line was changed and nothing moved off `unchecked`; the counts go to
  **35 entries, 29 pass, 1 partial, 0 fail, 5 unrun**. `P6` is the first entry in
  this document that reaches a **formspec**, which nothing here had ever covered:
  a prepend is invisible outside a form, so the check names the two forms to open
  and the gesture that opens each — the Drone setter, `codeblock:setter`,
  right-click for the file editor and left-click for the drone panel. It is `P`
  rather than a new group because it is the game presenting itself, which is
  `P4`'s subject too. **It cannot be run until `cc_gui` exists** (`ROADMAP.md`
  `G8`).
- **2026-09-17, over `c2d2b5a` with `mods/codeblock` moved to `09c708d` in the
  working tree and uncommitted: the same two re-runs owed again, and `L3`'s
  precondition rewritten.** Nothing was run and **no `Result:` line was changed**;
  the counts are unchanged at 34 entries, 29 pass, 1 partial, 0 fail, 4 unrun.
  `R4` and `R9` are owed a re-run for a sixteen-commit adoption that includes a
  substantially rewritten `lib/sandbox.lua`, on the same argument as the `vector3`
  re-pin — the sandbox is the mod's to check and these two are the game's share —
  so **no entry was added**. `L3`'s *Why*, *How* and *Pass* now name the
  **removal** upstream (`3fa9d0c`, `6440ca0`) rather than the guard: at `09c708d`
  there is no `flat_sky` in any Lua, `.txt` or `.conf` and no sky call left in
  `lib/`, so the check's precondition is read by grepping the adopted mod for any
  sky call at all, with the older guard wording kept for a release between
  `6fea453` and the removal. The pass itself stands untouched and its result line
  says which pointer it ran under; that closes `A7`. `P1`'s row is marked **clone
  half stale** for the second pointer move in a row — `09c708d` is on
  `origin/master` and fetchable, read on 2026-09-17, which is not the same as a
  fresh recursive clone having done it.
- **2026-09-09, `c7c2c43` with `mods/vector3` staged at `fc8a5b8`: two re-runs
  owed for the `vector3` `v2.0.2` re-pin, and no entry added.** Nothing was run
  and **no `Result:` line was changed**. `R4` and `R9` are the game's share of a
  major version of a hard dependency, and both name `dd83b99`, which is before
  the pointer moved; `R9`'s row went from *nothing owed* to *re-run owed* for
  that reason alone. The decision **not** to add an entry is recorded in
  `ROADMAP.md` under *deliberately not doing*: what `v2.0` changed — a frozen
  constant raising `read only`, a bad argument raising `format error` — is
  reached through `vector` in a player's program, and this document does not
  re-check the drone, the editor, the sandbox or the API. The entry count stays
  at 34.
- **2026-09-09, `dd83b99`: every result of the day re-pointed at the commit, and
  the `L` group's owed re-runs dropped.** Nothing was run and no outcome changed.
  `dd83b99` commits the tree all three sittings were played against with
  `git add -A`, and its only difference from that tree is two stray blank lines
  removed from `mods/cc_security/init.lua`, leaving the file byte-identical to
  `50fd05f`. So every 2026-09-09 result line, and the prose in the `R` group that
  named the tree, now names the sha instead of *`50fd05f` plus the uncommitted
  texture rework*. **The three `L` re-runs are dropped rather than carried**: a
  re-run is owed when the code changed under a result, and here the code was only
  written down — the same bytes would run. The *results that name no commit*
  row goes to **0**, and the recording rule in *Where it stands* is kept as a rule
  with **no live instance**. **One line deliberately keeps the old tree**: `L3`'s
  retained `partial`, taken in the first sitting before the `set_sky` line existed
  and entirely about the sky, so `dd83b99` is not the code it exercised.
- **2026-09-09, `dd83b99`, third sitting — the largest batch this document has
  taken.** Six results moved and two more composed from them, so the counts go to
  **29 pass, 1 partial, 0 fail and 4 unrun**, recounted from the first `Result:`
  line of all 34 entries rather than adjusted by hand. `R1` **pass, and the first
  run of it that could have failed**: the hand override from the `R` preamble was
  in place, which the working tree corroborates — both `cc_security` lines
  restored, the override gone, two stray blank lines where it had sat — so this is
  not a report against an unmodified tree, and the *pass that proves nothing* row
  goes to **0**. `R2` **pass, both halves**, the drop half for the first time
  since `7dc764f` and the first ever under the corrected method, which confirms
  `A20` in a world rather than only traced and closes out the morning's
  unexplained refusal; the two paragraphs recording that refusal are **kept**,
  because a correctly set-up run that produces no evidence is the hardest case
  here to recognise while it is happening. `R9` **clears to a full pass**: the
  entry named exactly two one-line programs as owed, so a bare *pass* cannot be a
  pass of the fifteen blocks that had already passed — an asymmetry that does not
  hold for `L4` or `R1`, whose parts are all live at once, and the reason those two
  carry longer limits. `L1`, `L2` and `L4` **pass**, the first in-world judgement
  of `A19`, `L4` on its first run and covering both blend peaks; none of the
  three named a commit that carried the code when they were written, and the rule
  for that shape of result is written into *Where it stands* rather than left to
  the next reader. **The commit landed the same day** and all three now name
  `dd83b99` — see the entry above this one.
  `L1` gains a second limit of the same kind as `R8`'s: a `plain` sky draws no sky
  mesh, so *no sun, no moon, no stars, no sunrise* no longer distinguishes the four
  calls from the sky type, and the 2026-09-01 pass under a `"regular"` sky is kept
  as the only evidence that can. **`L3` and `R5` move to pass by composition**, not
  by report — `R5` because its `partial` said in writing that it becomes a pass
  when `R2`'s drop half runs at the current tree, and `L3` because its whole *How*
  is *re-run `L1` and `L2`* and both were run in that world, with its residual
  closed by `L4` at the two times it was seen at and its precondition **read**:
  nothing sets `codeblock_flat_sky` and the adopted `fb75bc8` still guards the
  mod's copy. Both lines say they are composed, and both are the author's to
  reverse. No result was moved on reading alone.
- **2026-09-09, record-only over `50fd05f`: `R2`'s refusal diagnosed as `A20`,
  and `R1` turns out to be the bigger casualty.** No result moved and nothing was
  run — the diagnosis is read from the engine source at **both 5.9.0 and 5.17.0**
  and from `mods/codeblock` at `fb75bc8`, and **nothing in it is verified in a
  world**. The hand has had **empty `groupcaps`** since `G3` deleted
  `mods/default/tools.lua`, so no node in the game is hand-diggable: `R1` **would
  pass with `cc_security` deleted outright** and `R2`'s drop half was impossible
  as written. The fix is to this document, not to the game — a **shared temporary
  setup** in the `R` preamble, written once for both checks: a hand override, an
  **empty hotbar slot (3-8)** because `codeblock:poser` in slot 1 makes a
  left-click run the program instead of digging, and then the two comments for
  `R2` only. **Three things to undo.** `R1` gains `[A20]`, the *why it cannot
  fail* paragraph and a pass condition that requires the override; `R2`'s pass
  observation moves from *"open the inventory"* to **the hotbar and the dug
  position** — the first free `main` slot is slot 3 and there is no creative-mode
  gate on drops — and its *Why* is **corrected**: it said *"nothing exposes
  `core.dig_node`"* and the engine does, `lua_api.md` 5.17.0 line 6964, with
  `digger` honoured from 5.9.0; that route was considered and declined in favour
  of the hand override. `R8`'s pass gains its **second explanation** and stands.
  `R5` is no longer *blocked*, only owed. Counts unchanged: 34 entries, 5 unrun,
  and one pass — `R1`'s — that proves nothing.
- **2026-09-09, record-only over `50fd05f`: `L4` added for `A19`'s fix.** No
  result moved and nothing was run — the fix is one `set_sky` line in the working
  tree, uncommitted at the time and committed later the same day as `dd83b99`. `L4` exists because **neither `L1` nor `L3` asked about the
  horizon or the fog**, which is why the residual came back as a partial rather
  than a fail, and that gap is now closed in the criteria rather than left to the
  runner. `L1`'s Pass gained one line handing the sky's *colour* to `L4`, and
  `L1` is marked owed a re-run beside it: its subject did not change but the sky
  it passed against did. `L3`'s hypothesis paragraph carries a one-line
  correction — the mover is `m_horizon_blend`, not `sky_color`'s dawn entries —
  and its **observation and its `partial` are untouched**. Counts: 34 entries, 5
  unrun.
- **2026-09-09, `dd83b99`, second sitting.**
  `R3` and `R8` **pass** and `R9` is **partial**, so the counts move to **25 pass,
  4 partial and 4 unrun**. `R8` is the first and whole of `B48`'s in-world
  evidence. `R3` is a re-run, which puts `R5`'s knockback half on the current tree
  and moves what holds `R5` open to its other half. **`R9`'s misspelling step was
  written against the wrong code path**, found by reading the adopted mod at
  `fb75bc8`: the *"no block named"* warning the entry demands is installed as the
  miss handler on a block **category**, so it fires on `colors.vermilion` and
  never on `place('vermilion')`, which raises a hard error from
  `lib/commands.lua:110` instead. The step is corrected into two one-line
  programs with **different** pass conditions, the hard error is pinned as a pass
  condition of its own now that it has been seen, and the warning being said
  **once per run** — `warned` is a per-run upvalue — is written down so a silent
  second misspelling is not read as a failure. `R9` is `partial` because the
  quiet fallback is one of the two failure modes its own *Why* names and it has
  still never been exercised. **A re-attempt at `R2`'s drop half exercised nothing
  and is recorded as a note, not a result line**: both lines were commented out
  and the server was restarted — confirmed with the author — and nothing could be
  dug anyway, so it was an **unexplained refusal** at the time of this pass —
  diagnosed later the same day as `A20`, see the entry above — and not the
  two-line trap the method's prose warns of. Its 2026-09-02 pass is untouched,
  because a run that exercises nothing cannot contradict one that did. The method
  is now numbered steps with a count of comment markers, kept because that trap is
  real, and is otherwise **not rewritten until the cause is known** — if the
  engine's default hand has no usable groupcap since `G3`, the drop half is
  impossible as written rather than fragile, which would be a defect in this
  document.
- **2026-09-09, `dd83b99`, first sitting.**
  `W15` and `W16`
  **pass** and `L3` is **partial**, so the counts moved to **24 pass, 3 partial and
  6 unrun**. `W15` is the first judgement of the `G3` surface and of two of the
  four new textures; `W16` is the first evidence that the mapgen aliases `default`
  used to register resolve from `cc_mapgen`, and it is written down as **not**
  discharging `P3`. `L3` is deliberately not a `pass`: the four sky objects are
  gone with the mod's copy inert and the rejoin held, which is what the entry
  existed for, but the distant horizon's luminosity still moves between
  `/time 5000` and `/time 10000`, which `L1`'s *full daylight regardless of the
  time of day* does not allow and which `override_day_night_ratio` does not
  govern. **That residual is the entry's sole remaining gap, and the author
  settled it the same day as a shortfall in the game rather than a defect in this
  document** — so neither `L1`'s nor `L3`'s pass condition was loosened to expect
  it, `cc_day` is to pin the sky colours, and `L3` stays `partial` until that
  lands and it is re-run. The residual's cause is recorded as **likely and
  unproved**, with the fix and the proof being the same experiment.
- **2026-09-08, `50fd05f` plus an uncommitted texture rework.** `W11`'s pass
  **retired**, so the counts move to **22 pass and 9 unrun**: the bedrock and
  barrier PNGs were redrawn after it, and it had passed on wording the textures
  cannot meet — *"black mottled rock"* and a seamlessness credited to a *"wrapping
  blur"*. Both are gone from the entry, replaced by the flat-base-plus-specks
  construction with its palette, and **grain is now written in as a fail** in both
  `W11` and `W15`. `W15` gains the look as a pass condition beside the geometry,
  because that is what the author judges on. `G3` having landed at `50fd05f` is
  written through the status table, the action table and the `W` preamble, all of
  which still said the code was not in the tree. No `Result:` line was moved
  **to** a pass.
- **2026-09-08, `5777dc0`, ahead of `G3`'s code.** `W15`, `W16` and `R9` added
  for `A13`'s deletion — the new surface, the mapgen aliases `default` used to
  register, and the drone against a palette that is entirely `codeblock:*` — all
  three `unchecked` with **no commit to name**, because the code is being written
  and nothing is committed. `R1`'s method and `R8`'s three subjects rewritten,
  their nodes being deleted. **`R6` and `R7` marked unrunnable and kept**: each
  names a node only `default` registered, and deleting the entries would take
  their passes and their reasoning with them. `L3` rewritten — `A7` was settled
  upstream by a setting off by default, not by the removal this document
  predicted, and the check now says the game must not set it. The `W` preamble
  carries the group-wide re-run owed once `G3` lands, rather than eleven table
  rows saying it. No `Result:` line was changed.
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
