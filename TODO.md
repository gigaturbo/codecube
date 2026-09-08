# TODO

The author's inbox and wanted-features list for the Codecube game. One line each.
What the work involves is in `ROADMAP.md`; why, in this game's audit at
`AUDIT.md`; the manual checks are in `PLAYTEST.md`. The mod is the main project
and keeps its own list and its own audit, in `mods/codeblock/`.

**A `FIX:` or `BUG:` line is a hand-off**: it gets a finding id in `AUDIT.md` and
stays here until the author deletes it. **A `DECIDE:` line is blocked on the
author** and nobody else can close it.

**Completed items are not kept here.** This file is an inbox, not a log: a done
item's record is its `CHANGELOG.md` entry, its `ROADMAP.md` milestone line, its
`AUDIT.md` finding and its `PLAYTEST.md` result line, each of which carries the
commit and the date that a struck TODO line would only restate. Two lines on one
subject disagree within a month and neither is marked as the wrong one. **A line
is deleted only once its facts are somewhere else** — check before striking, and
move anything that has no other home.

Finding ids are shared between the two audits and are never renumbered;
milestones here are lettered `G1`–`G7`, not the mod's phase numbers.

## Decisions wanted from the author

Nothing below can be closed by an agent.

*Nothing at present.* The media licence was the last one and was answered on
2026-09-08 — code AGPL-3.0-only, media CC BY-SA 4.0 (roadmap G7, audit C22).

## To do

- [ ] `P1`'s boot half and `P3` are unrun. Narrower than it was — `W10`–`W14`
      passing proves the author's own checkout boots — but `P1` is a **fresh
      recursive clone**, whose submodule objects nobody has locally
- [ ] `W4`, `W8` and `W9` are owed re-runs at the new depth: all three pass at
      `60259dd`, where `mgflat_ground_level` was 8, and all three exercise heights
      the rescue derives from that number. **`W14` discharges none of them** —
      `PLAYTEST.md`'s *what needs action* table says why per check (audit B50).
      **G3 widens this to the whole `W` group**, since it rewrites both of the
      files that group exercises
- [ ] `W15`, `W16` and `R9` are new and have no commit to run against yet, and
      `R1`'s method and `R8`'s subjects were rewritten because their nodes are
      being deleted (roadmap G3). Do this sitting **before** G4's, or G4's results
      are owed a re-run the moment the deletion lands
- [ ] `code-expert`: with `default` gone nothing registers an ABM or an
      `on_timer`, so `cc_security`'s two neutralising loops walk empty sets, and
      `cc_mapgen`'s two `flowers:*` aliases have no schematics left to resolve.
      Keep as defence or delete as dead code — a decision, not a finding (audit
      B49, B19)
- [ ] `P2` and the changelog's download figure: the deletion of three vendored
      mods changes the archive size, and `CHANGELOG.md` still states 1.93 MB
      measured at `48cc63e`. Re-measure at release (audit C15)
- [ ] one playtest sitting for what G4 left: see the *what needs action* table in
      `PLAYTEST.md` rather than a second list here (audit B48, B19, B24)
- [ ] `check_game.sh`: nothing reads a media file, so a texture or menu image
      added with no licence line fails no gate — the same silence as
      `.gitattributes` (audit C22 `Keep`, C15). A wanted check, not a finding
- [ ] **standing:** re-run `P2` whenever a tracked file is added — not only at a
      release. Nothing in either CI reads `.gitattributes`, so the next tracked
      file ships or does not with nothing failing (audit C15, C22). It passed at
      `48cc63e` on 2026-09-08 and has been needed twice in two milestones
- [ ] `cc_day`: drop the duplicate of a block `codeblock` already runs (audit A7)
      — settled upstream as a setting off by default, not a removal; closes at
      adoption on `L3`, and the game must **not** set `codeblock_flat_sky`
- [ ] delete `mods/default`, `mods/dye` and `mods/wool`, and give `cc_mapgen` the
      three mapgen aliases and the grass/dirt surface that go with it (audit A13,
      roadmap G3) — no longer deferred: `codeblock` took the blocks (its F11)
- [ ] `vector3` declares `max_minetest_version = 5.5`, four minor versions below
      the 5.9 G6 needs (audit C21) — upstream or a re-pin
- [ ] adopt a tagged CodeBlock release and update the game's documentation with
      it (roadmap G5)
- [ ] `cc_security`: the rescue's `load_area` column grew from 5 mapblocks to 13
      with the deeper world, and the scan reads ~128 more nodes before it finds
      the surface — bounded and deliberate; it could start at the surface and
      fall back to a full-column scan (`code-expert`, not a finding)
- [ ] `README.md`'s five inline tool icons are raw GitHub URLs on `codeblock`'s
      `master` branch. Correct for a README, but a rename or a move upstream
      breaks all five silently and nothing here checks them
- [ ] the live ContentDB page still shows **v1.0.2, dated 2022-07-07, listed for
      Luanti 5.4 and above**, while `game.conf` now says 5.9 — check the page's
      declared support at release time, not only `.cdb.json` (roadmap G5)
- [ ] `mods/cc_security/init.lua:96-97` claims the engine collides with unloaded
      space and leaves a player on an invisible dark ledge. That replaced a wrong
      claim and is **itself unverified** — neither read out of the engine source
      nor seen in a world. See `AUDIT.md`, *verified, committed, claimed*
- [ ] fog distance

## To raise in CodeBlock's own audit, not here

These are the mod's defects, read while working on the game. They get no
`B`/`S`/`C`/`A` id in `AUDIT.md`; they are hand-offs to the other repository.
Both were read, neither was run. **Both re-read at `fb75bc8` on 2026-09-08 and
both still apply** — `check_inside_world` is still position-only and the bound is
still the raw `mapgen_limit` setting, at `lib/commands.lua:53` and `:92`.

- [ ] codeblock: `check_inside_world` is applied to the drone's position only,
      never to a shape's extent — `lib/commands.lua:82-87`, called at `:130`,
      `:213`, `:555`, and by no shape command — so a drone inside the limit can
      place a shape of arbitrary extent past it
- [ ] codeblock: the bound is the raw `mapgen_limit` setting
      (`lib/commands.lua:49`) rather than `get_mapgen_edges()`, and generation
      stops at least a mapchunk inside the limit, so the drone is permitted past
      the wall even where it does check

## Other ideas

- teleport function? — game-side, a chat command rather than a drone command
