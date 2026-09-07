# TODO

Intentions for the Codecube game, one line each. What the work involves is in
`ROADMAP.md`; why, in this game's audit at `AUDIT.md`. The manual checks are in
`PLAYTEST.md`. The mod is the main project and keeps its own list and its own
audit, in `mods/codeblock/`. Finding ids are shared between the two audits and are never
renumbered; milestones here are lettered G1-G7, not the mod's phase numbers.

# v1.0.0 goals

- [x] generate flat clean world https://github.com/srifqi/superflat (cc_mapgen)
- [x] always day, etc (cc_day)
- [x] give every bundled mod its own licence, catalogued in THIRD-PARTY-LICENSES.md (audit C3, C4, C5)
- [x] CI that checks the game assembles, without duplicating the mod's (audit A14)
- [x] keep the release archive to what a player needs - no .claude/, .reports/ or art sources (audit C15)
- [x] write the ContentDB page for its own reader instead of shipping README.md as it (audit C20)
- [x] run the W, L and R groups of PLAYTEST.md once - found B47, B48 and S8
- [x] stop the world changing on its own - ABMs rewriting builds, saplings growing (audit B49) - R7 passes
- [~] trim vendored default down to the nodes the game actually uses (audit A13) - deferred, codeblock will take the blocks
- [x] cc_day: hide the sunrise texture, not only the sun (audit B47) - L1 passes
- [x] cc_security: deny every node inventory and every player inventory move, closing the bookshelf hole (audit S8) - fixed twice, R6 and R4 pass
- [ ] cc_day: drop the duplicate of a block codeblock already runs (audit A7) - upstream edit, closes at adoption
- [x] cc_security: chain the two engine callbacks instead of assigning over them (audit A8) - R5 unverified
- [x] cc_security: strip the six digging groups so the client stops predicting a dig (audit B48) - committed ec02760, R8 unverified
- [x] cc_mapgen: alias the two flowers nodes default's log schematics name, so the boot log has no NodeResolver errors (audit B19) - P3 unverified
- [x] default: rename the furnace's deprecated TileDef image field to name (audit B24) - P3 unverified
- [x] bound the world: bedrock floor at y=0, bedrock wall at the edge, default 1024 (audit B50, roadmap G6) - committed f5f2385, W4-W9 all pass at 60259dd, B50 resolved
- [x] game-root settingtypes.txt declaring mapgen_limit only (roadmap G6, extends C7)
- [x] raise min_minetest_version 5.4 -> 5.9 for the mapgen environment (roadmap G6) - 5.7 was wrong, register_mapgen_script arrived in 5.9.0
- [x] cc_security: catch a player found outside the world box, for the hole a program digs in the floor (audit B50, roadmap G6 decision 6) - committed f5f2385, W8 passes at 60259dd on both halves
- [x] cc_security: repair the rescue destination before moving anyone - playing found the spawn column looping (roadmap G6, no finding id) - committed f5f2385, now the fallback path only, exercised by W9 case 4
- [x] cc_security: rescue the player into their own column instead of to spawn, lifting them to the nearest free space above (roadmap G6 decision 7, no finding id - the author asked for it after playing) - committed 60259dd, W8 and W9 pass there
- [x] PLAYTEST checks for the world limits (audit B50) - W4-W9 written, rewritten for the new rescue, and all six run: pass at 60259dd
- [x] run W4-W9 at 60259dd - W5 closes route one of B50, W8 and W9 close route two, W6 and W7 were first runs, W4 re-run rather than backdated
- [~] cc_mapgen: split the bounds in two - bedrock stays the floor at y=0, a new translucent cc_mapgen:barrier becomes the wall (roadmap G7, no finding id - an appearance change the author asked for, not a defect in G6) - written, both gates green, NOT committed
- [~] cc_mapgen: ship the game's own bedrock and barrier textures instead of borrowing two from default - the author asked for bedrock "more black like in minecraft" (roadmap G7, no finding id) - written, both gates green, NOT committed
- [~] cc_mapgen: raise mgflat_ground_level 8 -> 128 and make it a setting, mirroring mapgen_limit (roadmap G7, no finding id) - implements the fourth line of the author's world-limits brief, "height of map configurable (mapgen?)", now quoted under roadmap G6 - written, both gates green, NOT committed
- [x] decide whether to lower mgflat_ground_level so the bedrock floor is visible - answered 2026-09-07 in the opposite direction: the author raised it to 128, so the floor is buried deeper than ever (roadmap G7, deliberately not doing)
- [x] remove default/wool/dye outright - declined by the author 2026-09-07, "leave it for now": codeblock's mod.conf hard-depends on default and wool (audit A13)
- [ ] run W10-W14 once the G7 changes are committed - the outline grid per node, the floor not tiling, a new world at 128, an existing world's surface moving, and the rescue heights (roadmap G7)
- [ ] C22: menu/background.png, header.png and icon.png ship to every player with no licence stated anywhere, and .cdb.json has no media_license - needs a licence statement, a THIRD-PARTY-LICENSES.md row, and a media_license in gen_cdb_json.sh (code-expert; which licence is the author's call)
- [ ] decide whether the two new cc_mapgen textures stay AGPL-3.0-only or move to CC BY-SA 4.0, the convention for game art - AGPL was chosen to keep the game single-licence, and it is reversible (roadmap G7)
- [ ] cc_security: the rescue's load_area column grew from 5 mapblocks to 13 with the deeper world, and the scan reads ~128 more nodes before it finds the surface - bounded and deliberate; it could start at the surface and fall back to a full-column scan (code-expert, not a finding)
- [ ] CONTENTDB.md and README.md: say the world is bounded and 128 deep, once G6 and G7 ship (audit B50) - neither mentions the world's size, its depth or its edge at all yet; wait for W10 and W11 before describing what the wall or the floor looks like (roadmap G7)
- [ ] vector3 declares max_minetest_version = 5.5, four minor versions below the 5.9 G6 needs (audit C21) - upstream or a re-pin
- [ ] run R8 at ec02760, with R1, R4, R6 and P3 beside it (audit B48) - the only checking left, and the next thing to do
- [ ] re-run P2: G6 added two tracked files, G7 adds a new directory and two more (mods/cc_mapgen/textures/), and nothing in CI reads .gitattributes (audit C15) - code-expert confirmed both textures by hand with git check-attr, which is one manual run and not a gate
- [ ] adopt a tagged CodeBlock release and update the game's documentation with it
- [ ] fog distance

# To raise in CodeBlock's own audit, not here

These are the mod's defects, read while working on the game. They get no B/S/C/A
id in `AUDIT.md`; they are hand-offs to the other repository. Both were read,
neither was run.

- [ ] codeblock: check_inside_world is applied to the drone's position only, never to a shape's extent - lib/commands.lua:82-87, called at :130, :213, :555, and by no shape command - so a drone inside the limit can place a shape of arbitrary extent past it
- [ ] codeblock: the bound is the raw mapgen_limit setting (lib/commands.lua:49) rather than get_mapgen_edges(), and generation stops at least a mapchunk inside the limit, so the drone is permitted past the wall even where it does check

# Owed corrections, each to the agent that owns the file

- [ ] .claude/skills/code-standards/SKILL.md states disabled_settings backwards - it says `!` forces a setting off, where the API says `!` initializes it to true; game.conf is correct as written, so the skill would lead someone to "fix" a working file
- [ ] .claude/skills/code-standards/SKILL.md carries a line count that is now stale - the game is 177 code lines across four files, 464 in all
- [ ] mods/cc_security/init.lua:96-97 overstates a failure mode - it says a player through the floor "never lands", where the engine collides with unloaded space and zeroes velocity, so they land on an invisible dark ledge; B50's fix and reasoning are unaffected and confirmed

# Other ideas

- teleport function? - game-side, a chat command rather than a drone command
