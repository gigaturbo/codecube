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
  renumbered. The twenty in `AUDIT.md` are the game's; the rest are the mod's, as
  is the `F` feature series.

Target is **v1.0.0**, major because several changes break saved player programs.

## Now

**Play the game.** Everything outstanding is *checking*, not building: ten of the
thirty checks in `PLAYTEST.md` have never been run and six passes are owed
re-runs. Two sittings cover all of it — `G7`'s world (`W13` and `W14` first, then
`W10`–`W12` and the `W4`/`W8`/`W9` re-runs the new depth made owed) and `G4`'s
restrictions (`R8` with `R1`, `R4`, `R6` and `P3` beside it). `PLAYTEST.md` holds
the list; it is not restated here.

Nothing else can move without the author: `A7`'s edit is upstream, `A13` waits on
a decision in `codeblock`, and `C21` is a submodule's metadata. `C22` closed on
2026-09-08 — the licence question is answered.

## Milestones

In work order, which is why `G6` and `G7` sit before `G5`: letters are allocated
when a milestone opens and never reused, and `G5` is shipping, so it stays last
whatever is opened after it.

| Milestone | Goal | State | Written | Checked |
|---|---|---|---|---|
| `G1` | Ship an honest, installable package | done | 5/5 | — |
| `G2` | Check the game, not the mod | done | 4/4 | — |
| `G3` | Trim what the game vendors | one part done, the rest deferred | 1/2 | 1/1 |
| `G4` | Make the game's own mods behave | done here; the fifth item is `G5`'s | 4/5 | 3/4 |
| `G6` | Bound the world | **done on both counts** | 5/5 | 6/6 |
| `G7` | Make the world something to be in | committed, unchecked | 3/3 | 0/5 |
| `G5` | Adopt CodeBlock 1.0.0 and ship | started | 1/5 | — |

Findings by milestone: `G1` (`C1`, `C2`, `C3`, `C4`, `C5`, `C15`, `C20`); `G2`
(`A14`, `B20`); `G3` (`B49`, `A13`); `G4` (`B47`, `B48`, `S8`, `A7`, `A8`); `G5`
(`C21`, `C22`); `G6` (`B50`); `G7` (none — an appearance the author wanted
changed is not a defect). `C22` was turned up sideways by `G7` and is scheduled
under `G5`, because it is what makes the package honest to ship.

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

### G3. Trim what the game vendors — one part done, the rest deferred (1/2)

Scoped 2026-09-02, and the scoping is what changed it: reading `default` against
the palette turned up a behaviour defect nobody had looked for and made the case
for the trim weaker, not stronger. The palette is **122 nodes — 106 from
`default`, 15 from `wool`, plus `air`**, corrected from 124 and 108 while
scoping; all 106 are in `nodes.lua`, so the removable set is whole files.

- [x] Stop the world changing on its own — two `default` ABMs rewriting palette
  nodes, and ten saplings growing over what a program built. `R7` passes. (`B49`)
- [ ] Trim vendored `default` itself. **Deferred, not pending**; grounds under
  *deliberately not doing*. It carries nothing: `B19` and `B24` were closed
  directly rather than left waiting behind it. (`A13`)

### G4. Make the game's own mods behave — done here (4/5)

The first playtest added three of these five and all three are fixed. **Nothing
left here can be acted on**: the one open item is `A7`, whose edit is upstream and
whose game-side half is `G5`'s. What is outstanding is *checking*.

- [x] `cc_day`: hide the sunrise texture too. `L1` passes. (`B47`)
- [x] Close the bookshelf, twice — the second fix denies every player-initiated
  inventory action. `R6` and `R4` both pass. (`S8`)
- [x] Stop `cc_security` clobbering two engine callbacks by direct assignment.
  Drops chain to the captured handler with an empty list; `R2` confirms it. The
  finding stays open for the every-node table walk. (`A8`)
- [x] Strip six digging groups so the client stops predicting a dig. Committed
  `ec02760`, **unverified** — `R8` closes it. (`B48`)
- [ ] Drop `cc_day`'s duplicate of a block `codeblock` already runs. **The edit is
  upstream** and nothing in this repository changes; the game's half is adopting
  the release and running `L3`. Untidiness only. (`A7`)

### G6. Bound the world — done: 5/5 written at `60259dd`, 6/6 checked

**The first milestone here to be both**, and keeping the two states apart is the
point of this file. Shaped with the author on 2026-09-07 and built the same day.
`W4`–`W9` all pass at `60259dd`, which resolves `B50` on both of its routes. The
defect, the fix and its five **Keep** paragraphs are `AUDIT.md` `B50`.

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
checked; *visible* and *configurable height* are `G7`, committed and unchecked.
The *floor* being visible went the other way — see *deliberately not doing*.

- [x] Ship the bounded slab: a mapgen script clears everything below `y = 0`, lays
  the bedrock plane at `y = 0`, and fills the outermost generated columns to full
  height. `cc_mapgen` forces `mapgen_limit` onto the world with `override_meta`,
  because the engine stores it per world in `map_meta.txt`. (`B50`)
- [x] Default the world to **1024**, a 2048×2048 field, down from 4096.
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
   That fill is **stone**: `mg_flags` carries `nobiomes`, so `mgflat` has no top
   or filler node and no dirt or grass exists until a program places some.
2. **One number, not two.** The world is ±N on every axis and N is
   `mapgen_limit`, because **CodeBlock already reads it** as the drone's bound. A
   second game-side number would let the drone build where the player cannot
   walk, and keeping the two in step would be a change in the other repository.
   Accepted cost: the world cannot be wide and shallow, since the floor is pinned
   at `y = 0`.
3. **A game-root `settingtypes.txt`**, for `mapgen_limit` only. A world size is
   the game's own subject, exactly like the light and the restrictions.
4. **The mapgen environment, not the main thread**, and therefore
   `min_minetest_version` **5.9**. Taken as 5.7 on the author's instruction and
   **corrected the same day on evidence**: `register_mapgen_script` is absent from
   the shipped `lua_api` at 5.7.0 and 5.8.0 and present at 5.9.0, so below 5.9 the
   call is `nil` and the game does not start. Recorded rather than overwritten,
   because a number silently changed is one the next reader re-derives. `C21`'s
   gap widened with it, to four minor versions.
5. **Default 1024.** 256 puts the walls inside `viewing_range = 300` so they are
   always in sight; 4096's walls are seven minutes' walk away and therefore
   theoretical.
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

### G7. Make the world something to be in — committed `d6e4a12`, 0/5 checked

Opened 2026-09-07 after `G6` closed, and **no finding is allocated for it**: the
wall `G6` built is a correct barrier and `W5` proves it stands. What the author
wanted changed is what it *looks* like, which is a new goal. Widened the same day
from one item to three, on the grounds that all three are appearance-and-feel,
none is a defect, and they are one tree that has to be checked together.

- [x] Split the bounds in two: `cc_mapgen:bedrock` stays the floor at `y = 0`,
  including the outermost column at that layer so the wall stands on a one-node
  opaque skirt; a new `cc_mapgen:barrier` is the wall above it. `W10`.
- [x] Ship the game's own 16×16 textures for both nodes, in
  `mods/cc_mapgen/textures/`. Asked for by the author — the bedrock should be
  *"more black like in minecraft"*, and the borrowed obsidian is blue-tinted.
  `cc_mapgen_bedrock.png` is a mottle of six neutral greys in the range 8–51,
  blurred with a **wrapping** kernel so a large floor shows no tiling grid;
  `cc_mapgen_barrier.png` keeps the 1px-border, transparent-centre pattern. `W11`
  is the check, and the wrapping blur is what it is written to catch.
- [x] Raise `mgflat_ground_level` 8 → **128** and declare it as a setting,
  mirroring `mapgen_limit`. This is the fourth line of the brief. `W12`, `W13`,
  `W14`.

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

### G5. Adopt CodeBlock 1.0.0 and ship — started (1/5)

The game's own last step, and it comes after the mod has a 1.0.0 to adopt. The
`release-codecube` skill owns the procedure and `release-check` gates it.

- [ ] Move `mods/codeblock` to a **tagged** release. See *which release is
  adopted* below: the pointer is currently off the release track, not merely
  behind it.
- [x] State the licence for the game's media, in `menu/license.txt`,
  `mods/cc_mapgen/license.txt`, `THIRD-PARTY-LICENSES.md` and
  `scripts/gen_cdb_json.sh`. Decided 2026-09-08 — see *The media licence* under
  `G7`. (`C22`)
- [ ] Re-pin or wait out `vector3`'s `max_minetest_version = 5.5`. (`C21`)
- [ ] Update `README.md`, `CHANGELOG.md` and `CONTENTDB.md` in the same commit,
  and regenerate `.cdb.json` — `check_game.sh` diffs it.
- [ ] Run `check_game.sh`, `P1`, `P2`, tag on `main`, upload, then read the page
  in-game (`P5`).

## Which CodeBlock release is adopted

**`2647228`, and it is a commit off `master`, not a tag.** The policy is that the
pointer names the release this game has *adopted*, so lagging upstream is
correct; this is a different thing — it was pinned before the project settled on
following releases. Upstream's newest tag is **`v0.7.3`**. Nothing is broken by
it: the game assembles and `P1`'s clone half passed on this pointer. `G5` is where
it goes back on the track. Read both numbers from `git ls-tree HEAD
mods/codeblock` and `git tag` inside the submodule, **never from upstream's
`HEAD`**.

The working tree's `mods/codeblock` is at `7dbe18f`, ahead of the committed
pointer and deliberately left unstaged. `git status` showing it modified is the
normal resting state.

## What ships broken

- **A rescued player is left standing in the shaft they fell down.** The design,
  not a defect — decision 7. Getting out needs a working program.
- **A player whose own column is solid for 72 nodes is still sent to spawn.**
  Accepted with decision 7; `W9` case 4 is its check.
- **The wall exists only in chunks generated after `G6`.** It is written by the
  mapgen callback, so a pre-existing world is bounded only where it has not been
  visited. `W7` confirms the *limit* moves; the missing wall is what nothing
  covers.
- **An existing world's surface moves only where it has not been generated.** Same
  mechanism, from `G7`. A world played at ground level 8 gets a step where the old
  ground meets the new. `W13` is the nearest check.
- **No check reads a media file, so a texture or menu image added with no licence
  line fails nothing** — locally or in CI. `C22` closed the gap the game has;
  this is the silence that let it open, and it is `C15`'s hazard in a second
  form. Not a finding: nothing in committed code is wrong.
- **`mapgen_limit` appears twice in the advanced settings menu** — under Mapgen
  from builtin, showing 4096, and under Content: Games → Codecube, showing 1024.
  Both write the same key. Inherent to decision 3; the alternative was not
  declaring it.
- **`mods/vector3/mod.conf` declares `max_minetest_version = 5.5`**, four minor
  versions below what `G6` requires. The engine does not read it, so it blocks
  nothing at load; it is ContentDB metadata on a pinned submodule. (`C21`)
- **`default` supplies 106 node definitions out of ~9,700 lines**, plus six ABMs,
  3 LBMs and 101 craft recipes nothing can reach. Deferred, not pending. (`A13`)
- **`.gitattributes` decides what reaches a player and no CI checks it.** `P2` is
  the only thing that would catch a file shipping by accident, and it has to be
  re-run every time a tracked file is added — `G6` added two and `G7` a directory
  and two more. (`C15`)
- **A bookshelf still opens and shows the player their own inventory.** Nothing
  can be moved and `R6` confirms it, but the formspec is metadata on the placed
  node, not a field `cc_security` can override away. (`S8`)
- **Fixed but unseen: the wool crack.** Committed `ec02760`; `R8` has a sha and
  nobody has watched a punch since. (`B48`)
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

- **Trimming vendored `default` down to the palette.** Decided 2026-09-02 by the
  author and **re-declined 2026-09-07 on fuller information**: CodeBlock is
  expected to integrate the blocks it needs, at which point `default` is deleted
  rather than trimmed. Trimming first means hand-curating 9,744 lines against a
  contract the other repository owns. Asked whether `default`, `wool` and `dye`
  could go outright, the author answered **"leave it for now"** —
  `mods/codeblock/mod.conf` hard-depends on `default` and `wool`, and `dye` is
  there because `wool` requires it. *What would change it:* CodeBlock deciding
  **not** to take the blocks. (`A13`)
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
  Game; CI lints only the three `cc_*` mods.
- **Bumping the submodule on every mod commit.** The pointer names the release
  this game has adopted. Moving it is a decision, taken with the documentation
  update that goes with it.

### The shape of the world

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
- **A ceiling on the world.** Rejected 2026-09-07: the player has no `fly`
  privilege and cannot reach one, so it would be scenery rather than a limit.
- **Separate width and depth.** Rejected 2026-09-07 — decision 2. One number, and
  it is `mapgen_limit`, because the drone already reads that setting.

### How the bounds are implemented

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
  `v1.0.0` is an unreleased heading that accumulates.
- **Keeping any agent guidance outside the repository.** Decided 2026-09-01 with
  the three-agent split. The reference documentation is copied in for the same
  reason: a fresh clone carries it.

### Conventions

- **Migrating off `minetest.*` as a project.** `minetest` is a permanent alias for
  `core`, with no deprecation warning and no removal date.
- **Reusing the mod's phase numbers.** They are quoted in commit messages;
  lettered milestones here cannot be mistaken for them.

---

2026-09-08 · codecube `6a0258a` on branch **`g6-world-limits`**, **19 commits
ahead of `origin/main` and unpushed**, with no CI run on the branch — the latest
is on `578b364`, which predates it. `codeblock` `2647228`, a commit off `master`
and not a tag; `mods/codeblock` is deliberately unstaged at `7dbe18f`, which is
its normal resting state.

The working tree over `6a0258a` carries the media licence change — a new
`menu/license.txt`, `mods/cc_mapgen/license.txt`, `THIRD-PARTY-LICENSES.md`,
`scripts/gen_cdb_json.sh` and the regenerated `.cdb.json` — the new
`scripts/gen_reports.py`, and this record pass. **None of it is committed**, and
`C22`'s closure holds only once `menu/license.txt` is tracked.

**`G6` is done on both counts and `G7` on one.** `G7`'s three changes are
committed with both gates green, and **neither gate runs a line of this game's
Lua**, so green means the game assembles and says nothing about how the world
looks, how deep it is, or where a rescue puts anybody. `W10`–`W14` have had a sha
since `d6e4a12` and are unrun.

The game's own Lua is **177 lines** across four files — `cc_day` 7, `cc_mapgen`
32 + 37, `cc_security` 101 — counting neither blanks nor comments, and **464
lines in all**.

This file is **521 lines against its own "under roughly 150"**, down from 968 two
passes ago. It got there by moving reasoning to `AUDIT.md` under its finding id
and settled questions into *deliberately not doing*, not by deleting either — and
it grew again here, because a decision was taken and this is where a decision is
recorded. The remaining excess is the decision log, which is this file's second job
and the one nothing else does; the `DECISIONS.md` split that would fix it stays
closed, declined by silence.
