---
name: build-feature
description: How work gets built in the Codecube game — first deciding whether it is the game's at all rather than the CodeBlock mod's, then shaping it in prose under a G milestone, putting the author's choices to them, arguing out what should not be built, writing it with the two gates, the author playing it in a real world, and recording what that found. Use when starting or resuming a G item, when a TODO line is being picked up, or when deciding whether a piece of work is finished.
when_to_use: Starting or resuming any item in ROADMAP.md's G1-G5 milestones, before writing any code under mods/cc_*, when asked what is next on a milestone or whether something is finished, when triaging whether an idea belongs to the game or to the mod, and when a playtest has just produced results.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, AskUserQuestion
---

# Building something in Codecube

The milestones `G1`–`G5` and the agreed shape of each item live in
**`ROADMAP.md`**; the reasoning is in `AUDIT.md`, the in-world checks in
`PLAYTEST.md`, the author's inbox in `TODO.md`. Ids are never renumbered, and
milestones here are **lettered**, never "Phase N" — that is the mod's scheme and
appears in its commit messages.

The steps below are cheap early and expensive late. The first one is this
project's own, and it is the one that saves the most.

## 0. Decide whose the work is

**Most feature-shaped ideas that arrive here belong to CodeBlock, upstream.** The
game is thin on purpose: 21 lines of Lua across `cc_day`, `cc_mapgen` and
`cc_security`, plus packaging and presentation. Everything a player *does* is the
mod's.

- The **game's** if it is about the world, the light, what a player may break or
  place, what a server owner gets by default, packaging, licensing, or how the
  package presents itself.
- The **mod's** if it is about programming the drone — the sandbox, the API, the
  editor, the limits. Say so, say it belongs to the other repository, and stop.
  Do not implement it here, and do not edit `mods/codeblock` from this tree.

`TODO.md` already triages this way: *"teleport function? — game-side, a chat
command rather than a drone command"*.

A third answer exists and is often right: **it needs no work here at all**,
because it arrives with the next adopted CodeBlock release. That is
`release-codecube`'s subject, not this one's.

## 1. Shape it in prose before any code exists

Dependencies, consequences, risks, and what the player experiences. Write it into
the item's line — or, if it needs more than a line, its entry — under the right
`G` milestone in `ROADMAP.md`. Keep the roadmap an index: the reasoning goes in
`AUDIT.md` under a finding id, not into the roadmap as a second audit.

Read what is already there first. The open items carry their constraints
already — `A13` names the two findings it closes for free, `A8` names why the
lint code is ignored rather than the defect fixed.

## 2. Put the author's choices to them, with a recommendation

Use **`AskUserQuestion`**: a small set of options with a recommendation, **never
a survey**.

A choice is the author's when it is about what a player gets, what the game
imposes on a server owner, or what is privileged — `default_privs`, a
restriction loosened, a setting exposed, what the ContentDB page says. It is
yours when it is about how the code is arranged.

## 3. Argue out what should not be built

A part losing an argument before it is written is a normal outcome, not a
failure, and it is cheapest here. **Record the grounds** in `ROADMAP.md` under
*what is deliberately not being done* — an omission with no recorded reason gets
proposed again in three months, and neither git nor the changelog records why a
question is settled.

For this game the argument that recurs is *should the game do this at all, or
should it stop duplicating the mod*: `A7` is `cc_day` duplicating a block
CodeBlock already runs, and it is being removed rather than kept in step.

## 4. Write it, then both gates, every time

**`code-expert`** writes it — it reads the `code-standards` skill first and knows
what a change drags with it. **`test-agent`** runs the gates. Delegating both is
the normal path; the gates are the same either way.

```bash
bash scripts/check_game.sh
wsl bash -lc 'cd /mnt/c/Users/lacba/PRogrammation/codecube && luacheck mods/cc_day mods/cc_mapgen mods/cc_security --formatter plain --codes'
```

**Read the output, not the exit code** — `$?` does not survive this machine's WSL
layer. Green is `all game integration checks passed` and luacheck silent.

Two dependencies nothing checks: a **file added to the tree** needs an
`export-ignore` line in `.gitattributes` or it ships to a player (`C15`), and a
**`CONTENTDB.md` edit** needs `bash scripts/gen_cdb_json.sh` in the same commit —
that one `check_game.sh` does catch, but only after the fact.

## 5. The author plays it in a real world — you cannot do this for them

Hand it over and stop. Here that is not a formality but the *only* evidence this
repository can produce: **the game has no test suite**, and both gates together
prove only that it assembles. Every claim about what `cc_day`, `cc_mapgen` and
`cc_security` do in a world currently rests on reading three short files.

So the hand-over names the `PLAYTEST.md` checks the change touches, and adds one
if the change reaches behaviour no existing check does. `run-checks` holds what a
good check looks like and how a result is recorded.

Reach for the engine's documentation on the first surprise, not the second — the
`references` skill bundles `lua_api.md` and the settings reference offline.

## 6. Record what the playtest found, before the work moves on

Call **`project-manager`**, and tell it:

- the outcome of each check, with the **commit**, the **engine version** and the
  **date** — a result with no commit is not evidence;
- what the two gates printed, read from their output;
- anything the author decided or reworded in the exchange, so it reaches
  `ROADMAP.md`'s record of what was agreed;
- any defect found, so it gets a finding id in `AUDIT.md`;
- the `TODO.md` line to strike.

**What gets an id is a defect in committed code.** Work that is wrong before it
ships is the change being wrong, and its record is the roadmap entry. A wrong
*check* is a defect in the record and is fixed in `PLAYTEST.md`.

## The two rules that are easiest to lose

- **Committed with gates green is done; checked is a second state.** An item
  whose in-world checks are unrun is outstanding *checking*, not unfinished work,
  and `PLAYTEST.md` is where that is said. Reporting the two as one is the
  failure this whole arrangement exists to prevent.
- **Nothing in a running world is provable from this repository.** If there is no
  `PLAYTEST.md` entry, the behaviour is unverified however green both gates are.
