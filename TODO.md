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

- DECIDE: which licence the three menu images ship under — `menu/background.png`,
  `header.png` and `icon.png` reach every player and no file states one (C22).
  AGPL-3.0-only keeps the package single-licence; CC BY-SA 4.0 is the convention
  for game art and lets it be reused
- DECIDE: whether the two `cc_mapgen` textures stay AGPL-3.0-only or move to
  CC BY-SA 4.0 — the same question as above and best answered with it. AGPL was
  chosen to keep the game single-licence, and it is reversible (roadmap G7)

## To do

- [ ] run `W10`–`W14`, which now have a sha: `d6e4a12` committed the whole of G7
      (roadmap G7). `W13` and `W14` first — an existing world's surface actually
      moving, and the rescue reading the new depth
- [ ] `W4`, `W8` and `W9` are owed re-runs at `d6e4a12`: all three pass at
      `60259dd`, where `mgflat_ground_level` was 8, and all three exercise heights
      the rescue derives from that number (audit B50)
- [ ] one playtest sitting for what G4 left: see the *what needs action* table in
      `PLAYTEST.md` rather than a second list here (audit B48, B19, B24)
- [ ] re-run `P2`: G6 added two tracked files and G7 a new directory and two
      more (`mods/cc_mapgen/textures/`), and nothing in CI reads `.gitattributes`
      (audit C15) — `code-expert` confirmed both textures by hand with
      `git check-attr`, which is one manual run and not a gate
- [ ] `cc_day`: drop the duplicate of a block `codeblock` already runs (audit A7)
      — upstream edit, closes at adoption
- [ ] trim vendored `default` down to the nodes the game actually uses (audit
      A13) — deferred, not pending: `codeblock` is expected to take the blocks
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
Both were read, neither was run.

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
