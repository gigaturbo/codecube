# TODO

Intentions for the Codecube game, one line each. What the work involves is in
`ROADMAP.md`; why, in this game's audit at `AUDIT.md`. The manual checks are in
`PLAYTEST.md`. The mod is the main project and keeps its own list and its own
audit, in `mods/codeblock/`. Finding ids are shared between the two audits and are never
renumbered; milestones here are lettered G1-G5, not the mod's phase numbers.

# v1.0.0 goals

- [x] generate flat clean world https://github.com/srifqi/superflat (cc_mapgen)
- [x] always day, etc (cc_day)
- [x] give every bundled mod its own licence, catalogued in THIRD-PARTY-LICENSES.md (audit C3, C4, C5)
- [x] CI that checks the game assembles, without duplicating the mod's (audit A14)
- [x] keep the release archive to what a player needs - no .claude/, .reports/ or art sources (audit C15)
- [x] write the ContentDB page for its own reader instead of shipping README.md as it (audit C20)
- [x] run the W, L and R groups of PLAYTEST.md once - found B47, B48 and S8
- [ ] trim vendored default down to the nodes the game actually uses (audit A13)
- [x] cc_day: hide the sunrise texture, not only the sun (audit B47) - L1 passes
- [x] cc_security: deny every node inventory and every player inventory move, closing the bookshelf hole (audit S8) - fixed twice, R6 and R4 pass
- [ ] cc_day: drop the duplicate of a block codeblock already runs (audit A7)
- [ ] cc_security: chain the two engine callbacks instead of assigning over them (audit A8)
- [ ] wool cracks under a punch it will not break - client-side dig prediction (audit B48)
- [ ] adopt a tagged CodeBlock release and update the game's documentation with it
- [ ] fog distance

# Other ideas

- teleport function? - game-side, a chat command rather than a drone command
