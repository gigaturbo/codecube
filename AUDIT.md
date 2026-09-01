# Audit — Codecube (the game)

Findings only: what was wrong, what it cost, how it was fixed, and the reasoning
a future change would otherwise re-break. **No roadmap and no milestones here** —
the order of work and the `G1`–`G5` lettering live in `ROADMAP.md`. The manual
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
shared audit; `C15` is the first allocated after the split, `C20` the second.
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

16 findings, this game's own. **10 resolved, 6 open, none won't-fix.** No open
finding is critical or high: three medium (`A7`, `A8`, `A13`) and three low
(`B19`, `B24`, `B48`). Three close together — `A13` takes `B19` and `B24` with
it — and `A7` and `A8` are a few lines each, so the open list is shorter work
than its count suggests. **Nothing resolved is now unverified.** `S8` and `B47`
were both fixed and both confirmed in a world on 2026-09-01, by `R6` and `L1`.

**Three of the sixteen arrived that same day, from the first hours anyone has
spent playing this game against `PLAYTEST.md`** — `B47`, `B48` and `S8`. None was
visible from reading the three `cc_*` files, which between them are 21 lines; two
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
| B bugs | 5 | `B19`, `B24` (close with `A13`), `B48` |
| S sandbox and security | 1 | — `S8` resolved, `R6` passes |
| C compliance and packaging | 6 | — |
| A architecture and performance | 4 | `A7`, `A8`, `A13` |

The game is current with `codeblock` `2647228`, adopted at `33bdae8`; both are at
`origin` and both CI workflows were green on those exact shas. `C15` was open as
a working-tree change at the last revision and has since landed in `8d18e8b`.
`C20` is new — filed and fixed in the same change, committed in `9ad884c`, and
the only finding here to arrive from reading a published rule rather than from a
defect.

## Findings in full

The six open findings. A finding leaves this section once a `PLAYTEST.md` check
has passed on it, which is where `S8` and `B47` went on 2026-09-01 — both are
still in full, under `S` and `B` respectively, because their reasoning is
load-bearing.

### A13 · medium · open — `default` is 9,744 lines to supply 108 node definitions, and the rest still runs

`mods/default`

The palette references 124 nodes: 108 from `default`, 15 from `wool`, plus `air`.
Nothing else in `default` is reachable — digging is disabled for every node, the
inventory formspec is blanked, `handle_node_drops` is stubbed, mapgen is flat
with no decorations, ores or biomes, and creative is on. So `mapgen.lua` (2,492
lines), `trees`, `crafting`, `furnace`, `chests`, `tools`, `craftitems`,
`item_entity` and `torch` register and do nothing — roughly 6,800 lines.

Not only dead weight: it installs **6 ABMs, 3 LBMs and 101 craft recipes**, and
those ABMs are evaluated against every loaded mapblock for the life of the
server. The largest single reduction available anywhere in the project, and it
removes a permanent background CPU cost. Closes `B19` and `B24` for free.

**One thing to check before cutting, since the palette is the contract.** The
block list a player's program uses is `codeblock`'s, in its config; the nodes
come from here. Removing a node the palette names breaks saved player programs,
which is the game's own reason to care about the mod's major version.

### A7 · medium · open — `cc_day` duplicates a block `codeblock` already runs, marked "TEMP fix"

`mods/cc_day/init.lua` · `codeblock lib/register.lua`

Both register an `on_joinplayer` calling the same five sky methods with identical
arguments; the copy inside `codeblock` is annotated `-- TODO: TEMP fix`. Sky
presentation is the game's job, not the programming mod's — and removing it also
stops `codeblock` imposing permanent daylight on any other game that installs it.

**Routed here, and it is the one genuinely two-sided item.** The duplicate to
delete is in `codeblock`, but the decision and the behaviour that must survive it
are the game's: `cc_day` is what should own permanent noon. Kept in this audit as
one finding rather than split in two; the mod's roadmap does not list it.

### A8 · medium · open — `cc_security` clobbers two engine callbacks by direct assignment

`mods/cc_security/init.lua`

`function minetest.handle_node_drops() end` and
`function minetest.calculate_knockback() return 0 end` overwrite the globals
outright, discarding whatever another mod installed and being discarded in turn
by any later mod that does the same. Capture and chain, and declare load order
with `last_mod` so the outcome is deterministic rather than alphabetical.

Separately: the mod overrides **every registered node** at `on_mods_loaded` to
set `diggable = false` — a large table walk to express one rule.

### B48 · low · open — wool plays the dig animation before the server refuses

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

**Not verified: whether the client is told at all.** The mechanism above is
inferred from which nodes show it, not from reading the engine. `override_item`
runs at `on_mods_loaded`, and whether a `diggable` changed there reaches the
client's copy of the node definition is the open question; if it does, the client
is ignoring the field and the fix has to come from the groups instead. Stripping
the dig groups in the same override would stop the prediction at its source, but
groups carry other meanings — `flammable`, `falling_node`, and whatever the
palette or `codeblock` reads — so that is a change to make deliberately, not as a
tidy-up.

### B19 · low · open — five `NodeResolver` errors on every world load

`mods/default/schematics/*_log.mts`

Four log schematics embed `flowers:mushroom_brown` and `flowers:mushroom_red`,
and no `flowers` mod is vendored. Harmless — `cc_mapgen` disables decorations —
but every boot log opens with red errors that are not real problems, which trains
you to ignore the log. Resolved for free by `A13`.

### B24 · low · open — vendored `default` uses a deprecated tile field, and `cc_security` re-triggers it

`mods/default/furnace.lua` · `mods/cc_security/init.lua`

Two `TileDef.image` warnings per load: `default`'s own node definition, and
`cc_security`'s `override_item` pass re-processing it against its own call site.
Cosmetic, and it lands in code `A13` proposes trimming anyway. Recorded mainly so
the warnings are not mistaken for something a recent change broke.

## B — bugs

5 findings, 2 resolved. `B19`, `B24` and `B48` are open and in full above; `B47`
is closed and kept here in full, because the prediction it got wrong is the
reusable part.

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

6 findings, all 6 resolved.

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
engine version was not recorded, which it should have been.

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

**Still not checked:** `L3` and `R5`, gated on `A7` and `A8`; `P3` (the boot
log), `P4` (the main menu), `P5` (the ContentDB page, which needs a release), and
the boot half of `P1`. `L2`'s second-player half was not exercised either —
singleplayer only, so a per-player setting applied to whoever joined first would
not have been caught.

**Not recorded, and it should have been:** the engine version, for any of the
three rounds.

## Corrections kept rather than edited away

Two filings in this document were wrong and say so where they stand: `C2` was
filed High on an inferred 404 that one `curl` disproved, and `C3` reported an
untracked licence file as a fix. Both are kept because the method that produced
them is the reusable part. `C5` additionally carried a stale state marker for
several revisions while its prose was already correct.

---

Revised 2026-09-01, five times in one day: at `8b27f2f` for the packaging checks;
at `7f649d8` for the first playtest; again for the `B47` and `S8` fixes it
produced; again after re-running `L1` and `R6` against those fixes, which closed
`B47` and reopened `S8`; and again at `c042364`, when `R6` and `R4` closed `S8`
for good. Describes codecube `c042364` (main) and codeblock `2647228` (master),
the release commit this game has adopted. `S8`, `B47` and `B48` are the new
findings; ids were allocated against the mod's audit in the sibling checkout,
which stands at `B46`, `S7`, `A16`, `C19` and `F8` — the game's `C20` is the
highest `C`.
