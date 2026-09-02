-- The world: flat, and clean of everything a mapgen would otherwise put in it.

minetest.set_mapgen_setting("mg_flags",
                            "nocaves,nodungeons,light,nodecorations, nobiomes, noores",
                            true)

-- Four of `default`'s log schematics embed `flowers:mushroom_brown` and
-- `flowers:mushroom_red`, and no `flowers` mod is vendored, so the node resolver
-- prints five errors on every world load. Nothing is broken by them: decorations
-- are off above, so those schematics never place anything. Aliasing the two
-- missing names to `air` gives the resolver something to resolve and the log
-- opens clean. Deleting the schematics instead would mean editing vendored
-- binaries; this survives `default` being trimmed or dropped. (B19)
minetest.register_alias("flowers:mushroom_brown", "air")
minetest.register_alias("flowers:mushroom_red", "air")
