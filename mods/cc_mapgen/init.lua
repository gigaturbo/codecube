-- The world: flat, bounded, and clean of everything a mapgen would otherwise
-- put in it. The bounds themselves -- a bedrock floor at y = 0 and a bedrock
-- wall at the outermost generated column -- are written by mapgen_env.lua, on
-- the emerge threads; this file settles the number they are measured from and
-- the node they are made of.

minetest.set_mapgen_setting("mg_flags",
                            "nocaves,nodungeons,light,nodecorations, nobiomes, noores",
                            true)

-- The world is a cube of +/- mapgen_limit on every axis, and that one number is
-- the whole of its size. settingtypes.txt declares it; the game's minetest.conf
-- carries the real default.
--
-- The force is what makes it apply. The engine stores mapgen_limit per world in
-- map_meta.txt, so a world created under a different value keeps its old edge
-- until override_meta says otherwise.
--
-- Nothing is needed to keep the drone's own bound in step: codeblock reads
-- core.settings:get("mapgen_limit"), which minetest.conf populates before any
-- mod loads. Writing that setting from here instead would make the two depend
-- on a load order this game does not fix.
local mapgen_limit = tonumber(minetest.settings:get("mapgen_limit")) or 1024

minetest.set_mapgen_setting("mapgen_limit", mapgen_limit, true)

-- The edge of the world, and nothing else. Not in any inventory, drops nothing,
-- carries no dig group -- so the client does not predict a dig on it either
-- (B48) -- and, being a registered node, it is covered by cc_security's
-- override pass for free. The texture is default's, so this adds no media.
minetest.register_node("cc_mapgen:bedrock", {
    description = "Bedrock",
    tiles = {"default_obsidian.png"},
    is_ground_content = false,
    diggable = false,
    drop = "",
    groups = {not_in_creative_inventory = 1}
})

-- The floor and the wall are written where the chunk already is: in the
-- VoxelManip the mapgen hands to the emerge threads. Needs Luanti 5.9, which is
-- what min_minetest_version in game.conf claims.
minetest.register_mapgen_script(minetest.get_modpath("cc_mapgen") ..
                                    "/mapgen_env.lua")

-- Four of `default`'s log schematics embed `flowers:mushroom_brown` and
-- `flowers:mushroom_red`, and no `flowers` mod is vendored, so the node resolver
-- prints five errors on every world load. Nothing is broken by them: decorations
-- are off above, so those schematics never place anything. Aliasing the two
-- missing names to `air` gives the resolver something to resolve and the log
-- opens clean. Deleting the schematics instead would mean editing vendored
-- binaries; this survives `default` being trimmed or dropped. (B19)
minetest.register_alias("flowers:mushroom_brown", "air")
minetest.register_alias("flowers:mushroom_red", "air")
