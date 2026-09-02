# Playtest — Codecube (the game)

The manual checks nothing else here can reach. **This game has no test suite at
all** — `scripts/check_game.sh` verifies that the game *assembles*, not that it
behaves, and luacheck reads three files without running them. So every claim
about what the game actually does in a world rests on reading three short Lua
files, and this document is where that gap is written down rather than
rediscovered from prose in `ROADMAP.md` and `AUDIT.md`.

The mod's own manual checks are separate and are the larger set:
`mods/codeblock/PLAYTEST.md`. Nothing here re-checks the drone, the editor, the
sandbox or the API. What is checked here is the world those run in, and what a
player gets when they install the package.

`PLAYTEST.md` carries its own `export-ignore` line in `.gitattributes`, so this
file never ships to a player.

## How to record a result

Each check carries a **Result** line. Leave it as `unchecked` until someone
actually does it in a running world, then replace it with:

```
Result: pass — <commit> · engine <version> · <YYYY-MM-DD> — <one line of detail>
```

`fail` and `partial` take the same shape. **Always keep the commit and the
date**: a pass recorded three milestones ago is not evidence about today's code,
and the point of the line is that a stale pass reads as stale rather than as
current. A `fail` is not a finding — report it and let `AUDIT.md` allocate or
widen an id.

Reference the finding id in brackets after the title where there is one; the
reasoning is in `AUDIT.md` under that id. A check with no id exists because
nothing has gone wrong there yet and nothing proves it right either.

Groups are lettered **W** (world), **L** (light), **R** (restrictions) and **P**
(packaging, boot and install). Those letters are deliberately none of `B`, `S`,
`C`, `A` or `F`, so a check id can never be read as a finding id, and none of
`G1`–`G5`, the milestone lettering in `ROADMAP.md`.

## Where it stands

**The game's behaviour has been checked in a world on 2026-09-01 over three
rounds, and again on 2026-09-02.** Fourteen of the eighteen have been run and
twelve pass: `W1`–`W3`, `L1`, `L2`, `R1`–`R4`, `R6`, `R7` and `P2`. Two are
partial: `P1`, its clone half only, and `R5`, whose drop half passed and whose
`R3` re-run has not been done. `L3` waits on `A7` landing upstream in
`codeblock`; `P3`, `P4` and `P5` are simply not done, and `P5` needs a release
first.

**`R2`'s drop half ran on 2026-09-02, for the first time in this project.** It
had been recorded as passing since the first playtest on the strength of the
inventory panel alone — nothing had ever been dug, because `diggable = false`
makes it impossible, and the check said only "with digging somehow permitted".
Commenting that line out for one run is what finally exercised
`handle_node_drops`, and it is the method the check now carries.

**Every restriction that was checked on 2026-09-01 is evidence rather than
reading.** Nothing is diggable, no item drops, there is no knockback, no
inventory is reachable, and the drone still builds through all of it.
`cc_mapgen` is proven the same way: flat and clean at spawn, far out into
unemerged map, and in a world created with other flags. `cc_day` holds the light
and the sky at every hour.

**`R7` is the one that earned the most.** The game also claims the world never
changes on its own, and the fix behind that claim rests on undocumented
behaviour — replacing an ABM's `action`, because Luanti cannot unregister one.
Nothing but `R7` could say whether it works, and on 2026-09-02 it did: nothing
moved in five minutes.

**Three findings came out of those rounds** — `B47`, `B48` and `S8` — none of
them visible from reading the three `cc_*` files, which are 21 lines between
them. Two are closed and re-checked; `B48` is cosmetic and open.

**`B49` came the other way, and is worth noting for that.** It was found by
reading `mods/default` while scoping `A13`, not by playing — three rounds in a
world walked past dirt spreading grass and a roofed grass floor reverting,
because nobody had thought to wait five minutes and look again. Playing finds
what reading misses; this one went the other way, and `R7` put it back in front
of a world.

**`R6` is the case for re-running a check against its own fix.** The first `S8`
fix stopped items going into the bookshelf and left the real hazard standing: the
same panel is a way into the player's own inventory, and a drone tool dragged out
of the hotbar there lands in a row the player can no longer open. Marking `R6`
pass on the strength of that fix would have shipped it. The same applies to `R4`,
re-run beside `R6` because the second fix denies every player inventory action
and `R4` is what would catch that being too broad.

---

## W · World and mapgen

`mods/cc_mapgen/init.lua` is three lines: one `set_mapgen_setting` call for
`mg_flags`, with `override_meta = true`.

### W1 · A new world is flat and clean at spawn

Create a new world with default settings and enter it. Look around, and move a
few hundred nodes in one direction — `/teleport` rather than flight, since
`default_privs` dropped `fly` on 2026-09-02. The pass below was recorded before
that, by flying.

**Pass:** flat ground to the horizon at one level. No trees, grass, flowers or
any other decoration; no ore visible in the ground when a drone digs into it; no
cave mouths, no dungeon, no water, no biome transition — the ground node and its
colour never change.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — flat and clean at
spawn and for a few hundred nodes out.

### W2 · The mapgen flags survive a world that was created with others

Create a world, enter it once, leave. Edit that world's `map_meta.txt` to set
`mg_flags` to something with caves and decorations, then re-enter.

**Pass:** the world is still flat and clean. `override_meta = true` is the third
argument of the one call `cc_mapgen` makes, and this is the only thing that
argument is for. Without it a world remembers the flags it was created with and
the game's setting is read once and never again.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — a world re-entered
with caves and decorations written into its `map_meta.txt` is still flat and
clean. `override_meta = true` does what the one call needs it to.

### W3 · The world is flat far from spawn, and far from where anyone has been

Teleport several thousand nodes from spawn into unemerged map, and watch the
ground generate ahead.

**Pass:** the same flat clean ground, generated live. This distinguishes a
setting that applied at world creation from one that applies to every chunk the
engine emerges, and only the second is what the game promises.

**Use `/teleport`, not flight.** `default_privs` dropped `fly` and `noclip` on
2026-09-02, so the method this check passed by is no longer available to a
default player — grant the priv or teleport. The distance is also worth
re-reading against `mapgen_limit`, now 4096: "several thousand nodes" should
still land inside the world, but it is closer to the edge than it was at 2000.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — ground generated live
several thousand nodes out is the same flat clean ground. The setting applies to
every emerged chunk, not only to world creation. **Passed by flying**, before
`fly` left `default_privs`; the finding it establishes is unaffected, but a
re-run takes the route above.

---

## L · Light

`mods/cc_day/init.lua` is one `on_joinplayer` calling five player methods.

### L1 · Permanent noon, no sky objects [A7]

Enter a world and look up. Wait, or advance time with `/time`, and look again.

**Pass:** full daylight regardless of the time of day; no sun, no moon, no stars,
no clouds. `override_day_night_ratio(1)` is what pins the light level, and the
other four calls remove the objects — they are separate effects and a partial
result should say which of the two failed.

Result: pass — `b9bf82b` · engine 5.17.0 · 2026-09-01 — full daylight at
every hour, and no sun, moon, stars or clouds at any time of day. No sunrise or
sunset glow either, which is what this re-run was for.

Previously partial at `7f649d8`: **part of the sun was visible at `/time 5000`**
— the sunrise texture, which `set_sun{visible = false}` leaves alone. `B47`.
Adding `sunrise_visible = false` to `cc_day` was enough on its own, which also
answered the open question in that finding: `codeblock`'s duplicate bare
`set_sun` does **not** put the field back, so `A7` was never a prerequisite.

### L2 · It survives a rejoin, and it applies to a second player

Leave the world and rejoin. On a server, have a second player join after the
first.

**Pass:** the same for both, every time. The callback is `on_joinplayer` and
these are per-player settings, not world settings — a rejoin is the path that
matters, and a second player is what would catch a setting applied to whoever
joined first.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — survives a rejoin.
The second-player half was not exercised: singleplayer only.

### L3 · Permanent noon still holds once the duplicate is removed [A7]

**Run this only once the game has adopted a `codeblock` release with the block
removed** — the edit is upstream, not here, so nothing in this repository will
show that it has landed. `codeblock` currently registers its own `on_joinplayer`
calling the same five methods, annotated `-- TODO: TEMP fix`. `A7` removes that
copy, leaving `cc_day` as the only thing setting the sky.

**Pass:** L1 and L2 both still pass with the mod's copy gone. This is the check
that says which of the two was doing the work, and until it runs, `cc_day` being
sufficient on its own is an assumption.

**Look at dawn and dusk in particular.** The two copies were never identical:
`codeblock`'s is a bare `set_sun{visible = false}` and `cc_day`'s adds
`sunrise_visible = false`. `L1` already passes with both in place, so this is not
expected to regress — it is the one field that distinguishes them, and the one
worth confirming by eye.

Result: unchecked

---

## R · Restrictions

`mods/cc_security/init.lua`, and it is the whole of what a player may and may not
do: a blank inventory formspec per player, a guard denying every player-initiated
inventory action (`S8`), a pass over every registered node setting
`diggable = false`, denying its three inventory callbacks and stopping its timer
(`S8`, `B49`), every ABM action replaced with a no-op (`B49`), and two engine
globals replaced — drops chained with an empty list, knockback returning 0, with
`last_mod = cc_security` in `game.conf` keeping this mod the one that replaces
them (`A8`).

### R1 · Nothing is diggable

Punch and hold on the ground, on a wall the drone built, and on several different
block types including one from `wool` and one from `default`.

**Pass:** nothing breaks, anywhere, on any node. The pass runs at
`on_mods_loaded` over `minetest.registered_nodes`, so a node registered later —
by another mod, or by a future `default` trim — would not be covered; try a block
type the drone can place but you have not seen before.

Result: pass, with two things it turned up — `7f649d8` · engine 5.17.0 ·
2026-09-01 — nothing breaks, anywhere, on any node tried. The rule holds. But:

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

Two halves, and only the first can be checked by playing normally. Open the
inventory: it should be blank.

**The drop half is not reachable from inside a running game, and that is the
point of it.** Checked against the 5.17.0 reference on 2026-09-02:

- No built-in chat command digs a node. `/give` and `/giveme` put an item in an
  inventory, which is a different path; nothing exposes `core.dig_node` to chat.
- **Privileges do not help.** `diggable = false` is a node property, not a
  permission — the reference says *"if false, can never be dug"* — so `node_dig`
  refuses before drops are ever computed, however privileged the player.
- **The drone does not reach it either.** `codeblock` writes the map with
  `set_node` and `VoxelManip` (`lib/commands.lua`, `lib/shapes.lua`), neither of
  which computes drops. So `R4` does not exercise this.

So `handle_node_drops` is unreachable while `diggable = false` holds on every
node — it is the fallback for the one gap `R1` names: **the override pass runs at
`on_mods_loaded` over `registered_nodes`, so a node registered later is not
covered**, and then the drop guard is all that is left.

**To check it, reproduce that gap.** Comment out the `diggable = false` line in
`mods/cc_security/init.lua`'s `override_item` call, restart the server, and dig a
node by hand. Revert the line afterwards. This is not cheating the check: an
uncovered node is exactly the situation the guard exists for, and it is the only
way to put the real `handle_node_drops` on a real dig.

**Pass:** the inventory formspec is blank; digging with the line commented out
removes the node and **no item appears** — none on the ground, none in the
inventory. `handle_node_drops` passes an empty list to whatever it captured, so
nothing is ever handed out. (`A8`)

Result: pass, both halves — `7dc764f` · engine 5.17.0 · 2026-09-02 — the
inventory formspec is blank, and **the drop half ran for the first time**: with
`diggable = false` commented out and the server restarted, a node dug by hand
disappeared and no item appeared, on the ground or in the inventory. The line was
reverted afterwards. So `previous_drops` is not `nil`, the chain fires, and the
empty list reaches the captured handler — the one thing `A8` changed that could
have failed silently. What this still does not establish is that no inventory is
*reachable*: `R1` found a bookshelf's own formspec shows the player's `main` list
(`S8`).

Previously pass on the inventory half only — `7f649d8` · engine 5.17.0 ·
2026-09-01 — nothing was dug, because nothing could be.

### R3 · No knockback

Take a hit — from another player, or anything that would push you.

**Pass:** you are not moved. `calculate_knockback` returns 0.

Result: pass — `7f649d8` · engine 5.17.0 · 2026-09-01 — no knockback.

### R4 · The drone can still build [R1 must not have broken it]

Run `stairs.lua`. Then run a program that places, and one that removes, blocks.

**Pass:** the drone places and removes normally. `diggable = false` is a property
of the node for a *player's* tool; the drone writes the map directly and must be
unaffected. This is the check that a restriction has not been made so broad it
disables the point of the game.

Result: pass — `6f2409e` · engine 5.17.0 · 2026-09-02 — re-run after `A8` changed
`cc_security`. The drone still places and removes normally, so chaining the drop
handler and declaring `last_mod` have not narrowed the game.

Result: pass — `c042364` · engine 5.17.0 · 2026-09-01 — the drone places and
removes normally with every node undiggable, and still does with the `S8` guard
denying every player-initiated inventory action. That second run was the point:
the guard is deliberately total, and this is what would have caught the editor or
a tool depending on an inventory move. Also passed at `7f649d8`, before the
guard.

### R6 · A bookshelf opens nothing you can use [S8]

Have a program place a `bookshelf`, then right-click it. Try to drag one of the
two drone tools from the inventory panel into the bookshelf's own slots, and try
to drag it back out. Then leave the world, rejoin, and open the same bookshelf.

**Pass:** the formspec still opens — that part is in node metadata and
`cc_security` cannot reach it — but no item moves in either direction, and the
bookshelf is empty after the rejoin. The three `allow_metadata_inventory_*`
callbacks are overridden to return 0 on every registered node, so the denial is
not specific to bookshelf; a chest or furnace would behave the same if one
existed.

**Also confirm the drone still builds** — the same override pass touches every
node, and `R4` is what says the restriction has not been widened into the game.

**And confirm you cannot rearrange your own hotbar from inside that panel.** The
bookshelf's formspec shows `list[current_player;main]`, so it is a way into the
player's own inventory even when nothing can be moved into the bookshelf itself.
Drag a drone tool from the hotbar into one of the rows below it. Nothing should
move. That is the half the first fix missed.

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

**This is the check the fix depends on, not a formality.** Neutralising an ABM by
replacing its `action` is not documented behaviour — Luanti has no API to
unregister one — so nothing but this says whether it works.

Have a program build three things, then leave them alone for **at least five
minutes** of running server and look again. The ABMs run on 6- and 8-second
intervals with a 1-in-50 chance, so a glance after thirty seconds proves nothing;
if you want it faster, build many of each.

1. A patch of `dirt` with `dirt_with_grass` next to it, and another `dirt` with a
   `grass_3` on top.
2. A floor of `dirt_with_grass` with an opaque roof — `stone` will do — one node
   above part of it.
3. A `sapling`, in the open.

**Pass:** nothing has changed. The `dirt` is still `dirt`, the roofed
`dirt_with_grass` is still grass, and the sapling is still a sapling.

**On the code before `B49`, all three change**, which is what makes this a real
check rather than an assertion: 1 turns to grass, 2 reverts to plain `dirt` —
destroying what the program placed — and 3 becomes a tree that may overwrite
blocks above it. If any of the three still changes, the `action` replacement does
not take effect and the fallback is deleting the two ABMs from
`mods/default/functions.lua` directly.

**Also confirm a sapling has not simply frozen the server**: the timer stopper
returns `false`, and **`0` is truthy in Lua 5.1** — had it returned `0`, every
node timer in the world would restart forever instead of stopping.

Result: pass — `d16f9bb` · engine 5.17.0 · 2026-09-02 — nothing changed after
five minutes: the `dirt` stayed `dirt`, the roofed `dirt_with_grass` stayed
grass, the sapling stayed a sapling, and the server kept running. The `action`
replacement takes effect, so the fallback of deleting the two ABMs from
`mods/default/functions.lua` is not needed.

### R5 · The chained drop handler still hands out nothing [A8]

**A regression check, not a composition one.** `A8` replaced
`function minetest.handle_node_drops() end` with a call to the handler it
captured, given an empty drop list. **Nothing else in this game assigns either
global** — `grep -rn "handle_node_drops\|calculate_knockback" mods/` finds only
`cc_security` — so the captured value is the engine default and the new code
should behave exactly like the old. What is worth confirming is that it does:
`previous_drops` being non-nil is read from the 5.17.0 reference and has never
been run, and a `nil` there would error on the one path that is meant to be
silent.

Re-run `R3`, and run `R2` **by its drop method** — comment out `diggable = false`
in `mods/cc_security/init.lua`, restart, dig a node by hand, revert the line.
That is the only way to put a real dig through the chain; no second mod, nothing
to install. Without it R5 proves nothing that `R3` does not already prove.

**Pass:** both still pass. No item entity ever appears, and nothing pushes you.

**What this deliberately does not check, and why.** `A8`'s other half — that
`last_mod = cc_security` makes this mod's assignment the one that survives —
needs a second mod installed that assigns the same globals, and none ships here.
Building one for the occasion would be testing a composition this game does not
have. The scenario it defends is a server owner adding a worldmod to a Codecube
server from ContentDB, and even then the game's promise is held by
`diggable = false`: the drop handler matters only once something has already
re-enabled digging, at which point the owner has deliberately changed the game.
**Untested by choice, recorded so it does not read as an omission.** Decided by
the author on 2026-09-02.

Result: partial — `7dc764f` · engine 5.17.0 · 2026-09-02 — **the half that could
have broken is done.** `R2`'s drop method passed: the chain fires, hands an empty
list to the captured handler, and nothing drops. `R3` was not re-run on current
code, so the knockback half is still resting on its 2026-09-01 pass. The risk
there is small — `A8` left `calculate_knockback` byte-identical and nothing
competes for it — but small is not none, and thirty seconds closes it.

---

## P · Packaging, boot and install

### P1 · A fresh recursive clone boots

`git clone --recurse-submodules` into an empty directory, put it in Luanti's
`games/`, create a world, enter it.

**Pass:** it boots and is playable. This is the check that catches a submodule
pointer naming a commit nobody can fetch — `reference is not a tree` — which is
invisible from a working tree that already has the object. It is also the gate
the `release-codecube` skill runs before a tag.

Result: partial — `8b27f2f` · 2026-09-01 — the clone half only. A fresh
`git clone --recurse-submodules` populated both submodules from the HTTPS remotes
in `.gitmodules`: `codeblock` `2647228` (`v0.4.0-98-g2647228`) and `vector3`
`16621648` (`v1.5`), so neither pointer names a commit nobody can fetch, and
`check_game.sh` passes inside the clone. **Not booted in Luanti** — the half that
says it is playable is still unchecked.

### P2 · The release archive holds only what a player needs [C15]

`git archive --format=zip HEAD -o /tmp/codecube.zip` and list it.

**Pass:** no `.claude/`, `.reports/`, `.github/`, `scripts/`, no art sources, and
none of `CLAUDE.md`, `ROADMAP.md`, `TODO.md`, `AUDIT.md`, `PLAYTEST.md` or
`CONTENTDB.md`. `menu/*.png` **is** present — the main menu reads it. Note the
total size; the last measurement was 2.75 MB, down from 4.94 MB.

**This is the half of `C15` that reading cannot settle**, and the reason it stays
worth running: `.gitattributes` decides what reaches a player and **nothing in
either CI checks it**, so a file added to the repository ships unless a rule
excludes it, and nothing fails locally when one does. Run this whenever a tracked
file is added, not only at a release.

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

Watch the log while a world loads, from a cold start.

**Pass: nothing.** No `NodeResolver` errors, no deprecation warnings, nothing red
or yellow at all. This became a real check on 2026-09-02, when `B19` and `B24`
were fixed directly rather than left to `A13`; before that it could only ask you
to count seven known messages and hope no eighth was hiding among them.

**The seven that should now be gone**, so a re-appearance is recognisable: five
`NodeResolver` errors from four `default` log schematics embedding
`flowers:mushroom_brown` and `flowers:mushroom_red` (`B19`, now aliased to `air`
in `cc_mapgen`), and two `TileDef.image` deprecation warnings from `default`'s
furnace and from `cc_security`'s `override_item` pass re-processing it (`B24`,
now `name =`). **If either is back, `default` has been re-vendored** and took the
fix with it — `B24`'s especially, since it is one word inside a third-party file.

**Luanti deduplicates deprecation warnings by message**, so a count here is a
count of distinct messages, not of occurrences — that is what hid the two
`TileDef.image` warnings behind the `formspecs` warnings until `B20` removed
them. A single occurrence of anything new is therefore worth a finding.

Result: unchecked

### P4 · The main menu presents the game

Open Luanti's main menu with the game installed and select it.

**Pass:** the game's name, its menu artwork and its icon all appear. `menu/*.png`
is what the menu reads, and it is the one thing `.gitattributes` deliberately
keeps in the archive; a `P2` rule written too broadly would break this and
nothing else would notice.

Result: unchecked

### P5 · The ContentDB page reads as a page [C20]

After a release, open the package page on ContentDB and read the long
description as someone who has just arrived there.

**Pass:** it says what the game contains, what distinguishes it and how to play
it once installed. No heading repeating the title, no badges, no screenshots, no
licence line, no link to the repository or back to the page itself. Every
instruction is complete as words — **images are not visible inside Luanti**, so
an instruction that depended on an icon has lost its object for exactly the
readers it was written for.

Also check the page from **inside Luanti**, in the content browser, not only in a
web browser. That is the reader the rule exists for and the one a web preview
does not show you.

Result: unchecked

---

Written 2026-08-30 at `54a2b7e`. Revised 2026-09-01 across three rounds: `P2` and
half of `P1` at `8b27f2f`; the `W`, `L` and `R` groups at `7f649d8`; then `L1`
and `R6` at `b9bf82b` against the fixes those produced, and `R6` and `R4` again
at `c042364`. All played by the author in a world on Luanti 5.17.0 — recovered
from the engine's own debug log afterwards, not noted at the time.
