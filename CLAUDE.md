# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository. The response, editing, coding and helper conventions are
in `~/.claude/CLAUDE.md` and are not repeated here.

## What this is

Codecube is a Luanti (formerly Minetest) **game** in which the player programs a
drone in Lua to build structures. It is not a mod, so it belongs in Luanti's
`games/` directory. What the game itself contributes is the setting and the fit:
a flat world, permanent day, build restrictions, the settings a server owner
wants, and a presentation that makes the programming pleasant to use. Branch
`main`.

**The game is thin on purpose.** Everything a player actually does — the sandbox,
the drone, the editor, the API and its limits — belongs to **CodeBlock**, an
upstream ContentDB package by the same author, embedded here as a submodule. The
game is a *consumer of its releases*. This repository's documentation stays
general — what the game is, its features, its settings, how to play — and
redirects to CodeBlock's own package and repository for the API and the detailed
instructions.

## `mods/` is not this project's code

| | |
|---|---|
| `codeblock`, `vector3` | Submodules. Pinned dependencies, **not working copies.** |
| `cc_day`, `cc_gui`, `cc_mapgen`, `cc_security` | The game's own mods: permanent daylight, the look of the interface, a flat bounded clean mapgen, and the build restrictions. One Lua file each except `cc_mapgen`, which has a second, `mapgen_env.lua`, run in the mapgen environment on the emerge threads. **This is the only Lua this repository owns or lints.** Two of them carry media in `textures/`, drawn by `scripts/gen_textures.py` and licensed in each mod's own `license.txt`: `cc_mapgen`'s four 16×16 world tiles and `cc_gui`'s three 64×64 interface tiles. |
**`mods/default`, `mods/dye` and `mods/wool` were deleted at `50fd05f`** under
`G3`: CodeBlock registers its own 105 nodes since its `F11` and depends on
`vector3` alone, so nothing reachable came from them. `mods/` holds the six
directories above and nothing else — do not re-vendor a Minetest Game mod for a
node, and note that the engine's three essential mapgen aliases moved into
`cc_mapgen` with the deletion.

**CodeBlock is developed in its own sibling checkout, not here.** `mods/codeblock`
exists so the game assembles and runs; it has its own repository, its own record,
its own CI and its own release path, and none of that is visible or relevant from
this tree. Do not edit it, commit to it, or read its documents to answer a
question about this game. If a question is really about the sandbox, the drone,
the editor or the API, it belongs to that project.

`.gitmodules` declares both submodules and `scripts/check_game.sh` verifies both
are populated. Both working remotes are SSH; `.gitmodules` deliberately stays on
HTTPS so anyone can clone the game without keys.

### The submodule pointer follows releases, not commits

`mods/codeblock` pins the CodeBlock release this game has **adopted**, not the tip
of upstream. So an ordinary mod change happens entirely upstream and nothing
happens here, and a pointer that lags upstream is *correct*. An unstaged
`mods/codeblock` in `git status` is the normal resting state.

The pointer moves only when the game adopts a new release — and that is the same
moment the game's own documentation is brought up to date with it. The
`release-codecube` skill owns that procedure. At adoption time, and only then, the
old hazard applies:

```bash
cd mods/codeblock && git checkout v<version>   # a tag that is already pushed
cd ../.. && git add mods/codeblock && git commit
```

Recording a hash nobody can fetch is invisible from a working tree that already
has the object; only a fresh `git clone --recurse-submodules` catches it
(`reference is not a tree`).

## The record

Seven tracked documents, all in this directory, plus the `.claude/` definitions
and the HTML renderings:

- `ROADMAP.md` — the game's own mods, its packaging and presentation, and which
  CodeBlock release it has adopted. Its milestones are lettered **`G`-numbers**,
  `G1` upward and allocated as they open, deliberately not "Phase N" — that is
  the mod's scheme and appears in its commit messages, and the two must stay
  distinguishable.
- `TODO.md` — intentions that are not findings. One line per item and a finding
  id where there is one; the description of the work belongs in `ROADMAP.md`, and
  the reasoning in the audit.
- `AUDIT.md` — the game's findings, each with its severity, state and, once
  fixed, how. **Findings only**: no roadmap, no milestones.
- `PLAYTEST.md` — the manual checks nothing else here reaches, each with what to
  do in a running world and a result line. The game has no test suite, so this is
  its only route to verifying behaviour. Groups are lettered `W`, `L`, `R`, `P`,
  chosen not to collide with a finding id or a `G` milestone.
- `CHANGELOG.md` — what shipped, for people who *play* the game. It names the
  CodeBlock release adopted and links to that project's changelog rather than
  repeating it.
- `CONTENTDB.md` — the ContentDB long description. **Not the README**: write this
  file, never `.cdb.json`, and read the rules in the header of
  `scripts/gen_cdb_json.sh` before adding to it. (C20)
- `THIRD-PARTY-LICENSES.md` — the licence catalogue for everything the game
  bundles, code and media. It is the one record document that **ships to a
  player**: it carries no `export-ignore` line, deliberately, because a licence
  notice has to travel with what it licenses. `check_game.sh` reads it — a mod
  either carries its own licence file or is named here (C3). The game's **code is
  AGPL-3.0-only and all of its own media is CC BY-SA 4.0**, decided 2026-09-08;
  the machine-readable spelling is ContentDB's own, `CC-BY-SA-4.0` (C22).
  `menu/license.txt` ships for the same reason this file does.
- `.reports/*.html` — gitignored browsable renderings of `ROADMAP.md`, `AUDIT.md`
  and `PLAYTEST.md`, built by `python scripts/gen_reports.py` and reproducible:
  two runs give byte-identical output, and `--check` reports drift without
  writing. Presentation only: they hold no fact the Markdown does not, so a
  deleted `.reports/` costs nothing. **The generator recognises an entry only in
  the heading shapes the documents already use** — `B50 · medium · resolved… —
  title`, `W4 · title [B50]`, `G6. title — state`, and a bullet opening
  `**<id> · sev · state** —`. Change one and the entry degrades to a title-only
  card with no id and no sidebar row, and **nothing errors**.

`AUDIT.md`, `PLAYTEST.md` and `CONTENTDB.md` each carry their own `export-ignore`
line in `.gitattributes`, so none of them ships to a player.

Finding ids — `B` bugs, `S` sandbox and security, `C` compliance and packaging,
`A` architecture — are **never renumbered**, because commit messages cite them. A
gap in a sequence is a finding held by the mod's own audit, from when the two
projects shared one record. The mod's `F` feature series is its own.

The `project-manager` agent owns all of them except
`THIRD-PARTY-LICENSES.md`, which is `code-expert`'s because it moves with a mod,
a licence file or a media file rather than with the record — plus `README.md` and
this file, the renderings, and the `.claude/` definitions beside them; edit one by
hand only for something that agent cannot know.

**One exception, and it is deliberate.** `code-expert` writes its own definition,
`.claude/agents/code-expert.md`, and the skill it reads,
`.claude/skills/code-standards/SKILL.md`, so that an engine behaviour or a trap
that cost it a debugging round is written down where the next change will meet
it. That is the mechanism by which a mistake is made once. Nothing else in
`.claude/` is its — `luanti-reference` is a shared reference skill and belongs to
no single agent.

## The agents and the skills

Three agents divide the work by what each can be trusted with, and each reads its
own skill first. Their definitions are the long form; this is only the map.

| Agent | Owns | Reads |
|---|---|---|
| `project-manager` | the record above, `README.md`, `CONTENTDB.md` and the `.cdb.json` generator over it, `.reports/`, and the `.claude/` definitions bar the two below | `build-feature` |
| `code-expert` | the game's own mods, `mods/cc_*` — currently `cc_day`, `cc_gui`, `cc_mapgen` and `cc_security` — plus `scripts/`, `game.conf`, `minetest.conf`, `settingtypes.txt`, the packaging and lint configuration, `THIRD-PARTY-LICENSES.md` and each mod's `license.txt`, and its own two files — `.claude/agents/code-expert.md` and `.claude/skills/code-standards/SKILL.md` | `code-standards`, `luanti-reference` |
| `test-agent` | the two gates, the CI lookup, `PLAYTEST.md`'s result lines, and the evidence side of `AUDIT.md` | `run-checks`, `luanti-reference` |

Two rules make the split work: **call the agent rather than doing its work**, and
**never two of them on one file in a turn** — `AUDIT.md` and `PLAYTEST.md` are
the two that can happen to.

The `build-feature` skill holds the order any piece of work follows, and its
step 0 is the one this project needs most: deciding whether the work is the
game's at all, or the mod's.

The `release-codecube` skill carries `disable-model-invocation: true`
deliberately, because a release is not something to start by accident. Ask for it
by name. The `release-check` agent gates it.

## Commands

These are the game's own checks, and they are what this repository's CI runs —
`game assembles` and `luacheck (game mods)`:

```bash
bash scripts/check_game.sh    # the game assembles: metadata, submodules, deps, .cdb.json
luacheck mods/cc_*/ --formatter plain --codes   # the glob CI uses; picks up a new game mod
bash scripts/gen_cdb_json.sh  # regenerate after a CONTENTDB.md edit; check_game.sh diffs it
```

Two more generators, and **neither is a gate nor something CI runs**:

```bash
python scripts/gen_reports.py          # rebuild the three HTML renderings
python scripts/gen_reports.py --check  # report drift without writing
python scripts/gen_textures.py         # redraw all seven textures the game ships
```

Run `gen_reports.py` after editing `ROADMAP.md`, `AUDIT.md` or `PLAYTEST.md`, and
check the entry count it prints against that document's own status table — a
count that has dropped is an entry heading that stopped parsing. Nothing fails if
it is skipped, because `.reports/` is gitignored.

`gen_textures.py` draws every texture the game ships from the palettes and seeds
in its own table, byte-identically on every run: `cc_mapgen`'s grass, dirt,
bedrock and barrier at 16×16, and `cc_gui`'s panel background, hotbar strip and
selection frame at 64×64 — one hotbar slot exactly at the default HUD scale. The
seven PNGs are **committed artefacts**, so nothing fails if it is never run
again: `check_game.sh` does not know about the script and luacheck does not read Python. It exists so the palettes
and the seeds do not rot in a comment. The style is deliberate and is not noise —
`ROADMAP.md` `G7`, *The texture rework*, says why, and `PLAYTEST.md` `W11` and
`W15` are what judge it in a world.

The game has **no test suite of its own**, and no automated check reaches its
behaviour at all — `check_game.sh` verifies that the game *assembles*. Say so
plainly rather than reporting a test gate as passed. Every claim about behaviour
rests on a `PLAYTEST.md` result line naming a commit, an engine version and a
date; count them there rather than trusting a number written anywhere else,
including here.

Linting and testing the mod belongs to its own repository and CI, and neither
workflow duplicates the other. The consequence: **the two go red
independently.** A mod change turns its CI red and leaves this repository green,
because nothing here re-runs its checks; a broken submodule pointer or a stale
`.cdb.json` turns this one red and leaves the mod's green. Check the repository
you changed.

## Architecture

`cc_mapgen` makes the world flat, clean and bounded, and it defines **four**
nodes for that — two for the bounds and, since `G3`, two for the ground. It also
registers the engine's three **essential** non-V6 mapgen aliases,
`mapgen_stone`, `mapgen_water_source` and `mapgen_river_water_source`, which came
from `mods/default/mapgen.lua` until that mod was deleted; the two water ones
alias to `air`, because the surface stands far above `mgflat`'s water level and no
water is ever generated. `mapgen_stone` aliases to `cc_mapgen:dirt`, which is
therefore what the engine fills the world with, and `mapgen_env.lua` writes a
**single** layer of `cc_mapgen:grass` at `mgflat_ground_level` on top of it —
`mg_flags` carries `nobiomes`, so the engine supplies no top or filler node of its
own. `cc_mapgen:bedrock` is the floor at `y = 0`, including the
outermost column at that layer, so the wall stands on a one-node opaque skirt;
it is also the node `cc_security`'s rescue writes back under a player.
`cc_mapgen:barrier` is the wall at the outermost generated column, above the
floor — a translucent `glasslike` node, so the world's edge reads as a limit you
can see past rather than the inside of a box. Both are written from
`mapgen_env.lua` on the emerge threads, which is what `min_minetest_version =
5.9` in `game.conf` is for. Both draw from `cc_mapgen`'s own
textures in `mods/cc_mapgen/textures/`, not from `default` — the bounds used to
borrow two of its textures and no longer do. `cc_day` holds the world at noon —
the light level, the sky objects, and since `A19` the sky itself, declared as a
`plain` sky whose one `base_color` is both the sky and the fog. `plain` is the
only type the engine excludes from the time-of-day tint it mixes into a
gradient sky, so the flatness is what buys the pinning, not a style choice.
`cc_security`
restricts what a player may break or place, and rescues a player found outside
the world box **into their own column** — clamping it inside the wall, making the
floor whole under it and standing them on the first height in it they fit, and
falling back to the spawn point only when nothing in that column fits. Those
writes are **the one place this game writes to the map**; every other rule in
`cc_security` denies. `cc_gui` gives every panel and the hotbar their look — one
formspec prepend and two hotbar images, set per player on join because the engine
offers no server-wide default for either, and the reason a form is no longer the
engine's semi-transparent default. It has no setting and no dependency. Five Lua
files, and the whole of this game's code: **218 lines** — `cc_day` 8, `cc_gui` 9,
`cc_mapgen` 51 + 49, `cc_security` 101, counting neither blanks nor comments, and
**647 lines in all**, counted 2026-09-17 over the working tree with `cc_gui`
still untracked. `G3` is what moved the code count from 177 and `G8` is the 9
lines of `cc_gui`; **read the files rather than trusting the number**, which has
been written down wrong twice. Everything between `50fd05f` (208 and 572) and
`cc_gui` was comment.

**The bedrock floor is buried deep under the ground.** `mgflat` fills
`mapgen_stone` — `cc_mapgen:dirt` — up to
`mgflat_ground_level`, which this game sets to **128**, and `mapgen_env.lua` puts
one layer of grass on top. Nothing else is in the world until a program places
it. So a player stands about
128 nodes up and the plane at `y = 0` is that far down, well out of sight in
ordinary play: reaching it means having a program clear a shaft. **It was 8 until
2026-09-07**, and a great deal of prose in this repository still reasons from
that number — check it against `minetest.conf` before trusting it.

The world's size is one number, `mapgen_limit`, and its depth is a second,
`mgflat_ground_level`; both are declared in the game-root `settingtypes.txt` and
defaulted in `minetest.conf`, and `cc_mapgen` forces both onto the world with
`set_mapgen_setting(..., true)` because the engine stores each per world in
`map_meta.txt`. The floor itself stays pinned at `y = 0`. CodeBlock reads the same
setting for the drone's bound, so the two never disagree; nothing here writes it
into the mod.

## Environment notes

- `minetest` is a permanent alias for `core` and is **not** deprecated.
- Lua 5.1 / LuaJIT: `loadstring`, `setfenv`, `math.pow`, `math.atan2` all exist;
  `0` is truthy; you cannot yield across `pcall`.
- `check_game.sh` fails `game.conf` for having a `max_minetest_version`.
- `git archive` does not include submodule contents, so what a ContentDB user
  gets for `mods/codeblock` comes from ContentDB's own dependency resolution, not
  from this repository's release archive.
