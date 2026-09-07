-- The world: flat, bounded, and clean of everything a mapgen would otherwise
-- put in it. The bounds themselves -- a bedrock floor at y = 0 and a translucent
-- barrier wall at the outermost generated column -- are written by
-- mapgen_env.lua, on the emerge threads; this file settles the number they are
-- measured from and the two nodes they are made of.

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

-- How high the stone surface stands over the bedrock floor, and so the height a
-- player walks about at: mgflat fills stone from the bottom of the world up to
-- and including this y, and mapgen_env.lua clears everything under y = 0 again.
-- settingtypes.txt declares it; the game's minetest.conf carries the real
-- default.
--
-- The force is needed for the same reason as above, and is easy to miss because
-- this is not a setting the world creation dialog offers: the engine writes
-- every mgflat_* parameter into a world's map_meta.txt when the world is made,
-- so a world created under a different value keeps its old surface for ever and
-- minetest.conf alone would reach new worlds only.
--
-- cc_security reads the number back with get_mapgen_setting, which sees this
-- override because last_mod = cc_security makes it the last mod to load.
local ground_level = tonumber(minetest.settings:get("mgflat_ground_level")) or
                         128

minetest.set_mapgen_setting("mgflat_ground_level", ground_level, true)

-- The two edges of the world, and nothing else. Neither is in any inventory,
-- neither drops anything, and neither carries a dig group -- so the client does
-- not predict a dig on them either (B48). Being registered nodes, both are
-- covered by cc_security's override pass for free. Both textures are this mod's
-- own, 16x16 and near-black, so the floor and the wall read as one material and
-- nothing here depends on `default` for its appearance.
--
-- Bedrock is the floor at y = 0, and the node cc_security's rescue writes back
-- under a player. Its texture is a mottled near-black grey whose noise wraps at
-- every edge, so a floor of it shows no tiling grid.
minetest.register_node("cc_mapgen:bedrock", {
    description = "Bedrock",
    tiles = {"cc_mapgen_bedrock.png"},
    is_ground_content = false,
    diggable = false,
    drop = "",
    groups = {not_in_creative_inventory = 1}
})

-- The barrier is the wall at the outermost generated column: translucent, so
-- that the edge of the world reads as a limit rather than as the inside of a
-- box. The texture is a dark one-pixel border around a fully transparent centre,
-- and plain `glasslike` puts it on every face whose neighbour differs, so the
-- wall shows an outline per node and is seen through everywhere else.
--
-- Four things here are load-bearing and would be re-broken if forgotten.
-- The drawtype is *not* `glasslike_framed`: that variant draws its faces from a
-- second tile, which this node does not have, and on a one-node-thick wall it
-- hides every frame edge lying in the plane of the wall anyway. Nor
-- `glasslike_framed_optional`, whose appearance follows the client's "Connected
-- Glass" setting rather than anything this game can decide.
-- `paramtype = "light"` and `sunlight_propagates` come as a pair: the engine
-- derives `light_propagates` from `paramtype`, which defaults to "none", so a
-- see-through wall without them casts a shadow with no visible cause.
-- `pointable = false` is *not* set, because it is honoured by the client alone;
-- pointing through the barrier would let a player place a node on its far side,
-- at the position on_place derives.
--
-- `use_texture_alpha` takes the string form (5.4.0); the boolean is deprecated
-- and would put a warning in the boot log (B19, B24). "clip" is both the default
-- for every drawtype but normal, liquid, flowingliquid, mesh and nodebox, and
-- what this texture wants: each of its pixels is fully opaque or fully
-- transparent, and nothing here needs the cost of "blend".
minetest.register_node("cc_mapgen:barrier", {
    description = "Barrier",
    drawtype = "glasslike",
    tiles = {"cc_mapgen_barrier.png"},
    use_texture_alpha = "clip",
    paramtype = "light",
    sunlight_propagates = true,
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
