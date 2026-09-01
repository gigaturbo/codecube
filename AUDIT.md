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
There are no `S` findings on the game's side — all seven are the mod's — and the
`F` feature series is the mod's own.

States: **resolved**, **open**, **won't fix** (the defect is real, the decision
is not to fix it), **withdrawn** (no longer applies — none is). Severities:
critical, high, medium, low.

Compression rule: a closed finding whose reasoning is spent is one line. A closed
finding whose reasoning is load-bearing keeps a **Keep** paragraph, because
someone could otherwise undo it by accident. Nothing has ever been renumbered and
nothing dropped.

## Where it stands

13 findings, this game's own. **8 resolved, 5 open, none won't-fix.** No open
finding is critical or high: three medium (`A7`, `A8`, `A13`) and two low
(`B19`, `B24`). Three of the five close together — `A13` takes `B19` and `B24`
with it — so the open list is shorter than its count suggests, and `A7` and `A8`
are a few lines each.

| Category | Count | Open |
|---|---|---|
| B bugs | 3 | `B19`, `B24` (both low, both close with `A13`) |
| S sandbox and security | 0 | — |
| C compliance and packaging | 6 | — |
| A architecture and performance | 4 | `A7`, `A8`, `A13` |

The game is current with `codeblock` `2647228`, adopted at `33bdae8`; both are at
`origin` and both CI workflows were green on those exact shas. `C15` was open as
a working-tree change at the last revision and has since landed in `8d18e8b`.
`C20` is new, and filed and fixed in the same change — the only finding here to
arrive from reading a published rule rather than from a defect.

## Open findings, in full

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

3 findings, 1 resolved. `B19` and `B24` are open and in full above. The other
B-findings are the mod's.

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

## C — compliance and packaging

6 findings, all 6 resolved — `C20` in the working tree rather than in a commit.

- **C20 · medium · resolved, in the working tree** — the ContentDB long
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
  archive, and the file's own header now says so. Measured by the author: **4.94 MB
  down to 2.75 MB**. First finding allocated after the audit split; its
  counterpart in the mod's audit is `C10`, the same subject in
  `mods/codeblock/.gitattributes`.

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

**Verified:** `scripts/check_game.sh` passes; the `.claude/` size quoted in `C15`
(993 kB, measured here); `C20`'s counts, read out of `README.md` — nine images,
four `dp.png`, one `ds.png`, two links to the game's own ContentDB page.

**Committed, unproven:** the `.gitattributes` rewrite (`C15`) landed in `8d18e8b`,
but no archive has been built here to confirm the rules from the outside.

**In the working tree, not committed:** the `CONTENTDB.md` split for `C20`, with
`.cdb.json` regenerated and `check_game.sh` passing on it. It has not been seen
rendered on ContentDB, in a browser or in-game — that is `P5`.

**Claimed, on the author's measurement:** the archive sizes, 4.94 MB → 2.75 MB.

**Not checked:** whether `.gitattributes` excludes exactly what is intended,
which one `git archive --format=zip HEAD` and a listing would settle. Nothing in
`PLAYTEST.md` has been run — the checks are written, not performed, and the game
has no test suite that could stand in for them.

## Corrections kept rather than edited away

Two filings in this document were wrong and say so where they stand: `C2` was
filed High on an inferred 404 that one `curl` disproved, and `C3` reported an
untracked licence file as a fix. Both are kept because the method that produced
them is the reusable part. `C5` additionally carried a stale state marker for
several revisions while its prose was already correct.

---

Revised 2026-08-30. Describes codecube `54a2b7e` (main) plus the working tree,
and codeblock `2647228` (master), the release commit this game has adopted.
