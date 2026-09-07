# TODO

Intentions for the Codecube game, one line each. What the work involves is in
`ROADMAP.md`; why, in this game's audit at `AUDIT.md`. The manual checks are in
`PLAYTEST.md`. The mod is the main project and keeps its own list and its own
audit, in `mods/codeblock/`. Finding ids are shared between the two audits and are never
renumbered; milestones here are lettered G1-G6, not the mod's phase numbers.

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
- [x] bound the world: bedrock floor at y=0, bedrock wall at the edge, default 1024 (audit B50, roadmap G6) - committed f5f2385, the floor is seen and the wall is not
- [x] game-root settingtypes.txt declaring mapgen_limit only (roadmap G6, extends C7)
- [x] raise min_minetest_version 5.4 -> 5.9 for the mapgen environment (roadmap G6) - 5.7 was wrong, register_mapgen_script arrived in 5.9.0
- [x] cc_security: put a player found outside the world box back at spawn, for the hole a program digs in the floor (audit B50, roadmap G6 decision 6) - committed f5f2385, W8 partial against the tree that preceded it
- [x] cc_security: repair the rescue destination before moving anyone - playing found the spawn column looping (roadmap G6, no finding id) - W9 passes f5f2385 2026-09-04, out-of-range spawn included
- [x] PLAYTEST checks for the world limits (audit B50) - W4-W9; W9 passes, W4 and W8 partial against an uncommitted tree, W5-W7 unchecked
- [ ] decide whether to lower mgflat_ground_level so the bedrock floor is visible; it is 8, so the floor is buried and only the wall is (roadmap G6 open question) - unanswered
- [ ] CONTENTDB.md and README.md: say the world is bounded, once G6 ships (audit B50)
- [ ] vector3 declares max_minetest_version = 5.5, four minor versions below the 5.9 G6 needs (audit C21) - upstream or a re-pin
- [ ] re-run W4 and W8 at f5f2385 - seen on an uncommitted tree, kept partial rather than backdated because repair_spawn landed on W8's path in between
- [ ] run W5 - route one of B50, the wall, and the only check that closes the finding
- [ ] run W6 and W7 - the drone's error naming 1024, and an old world re-bounded
- [ ] run R8 at ec02760, with R1, R4, R6 and P3 beside it (audit B48)
- [ ] adopt a tagged CodeBlock release and update the game's documentation with it
- [ ] fog distance

# Other ideas

- teleport function? - game-side, a chat command rather than a drone command
