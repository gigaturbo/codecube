-- The world: flat, bounded, and clean of everything a mapgen would otherwise
-- put in it. Four nodes make the whole of it -- dirt for the fill, one layer of
-- grass on top, a bedrock floor at y = 0, and a translucent barrier wall at the
-- outermost generated column. The engine writes the dirt itself, through the
-- mapgen_stone alias below; mapgen_env.lua writes the other three on the emerge
-- threads. This file settles the numbers all of that is measured from and
-- registers the nodes it is made of.

-- `nobiomes` is what makes the grass layer this game's job rather than the
-- engine's: without biomes mgflat has no top node and no filler node, so it
-- fills mapgen_stone to the surface and puts nothing on it. The other flags
-- keep the world clean -- no caves, no dungeons, no decorations, no ores -- and
-- `light` is left on so the sky lights the surface.
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

-- How high the ground stands over the bedrock floor, and so the height a player
-- walks about at: mgflat fills mapgen_stone -- this game's dirt -- from the
-- bottom of the world up to and including this y, mapgen_env.lua turns that top
-- layer into grass, and it clears everything under y = 0 again.
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

-- Every node below shares four fields, for one reason each. None is in any
-- inventory and none drops anything, because a player is not meant to hold the
-- world's own material. None carries a dig group, so the client does not
-- predict a dig on it either (B48). And each says `diggable = false` even
-- though cc_security's register_on_mods_loaded pass sets it on every registered
-- node whatever is written here: the field states the intent, and leaving it
-- out would read as a node this game meant to be dug, of which it has none.
--
-- All four textures are this mod's own and 16x16. The three mottled ones --
-- grass, dirt and bedrock -- are drawn so their noise wraps at every edge, so a
-- large flat area of any of them shows no tiling grid. The barrier is a border
-- rather than a field, and tiles by construction.

-- The ground the mapgen fills the world with, and the one layer on top of it.
-- Three tiles, not one: +Y, -Y, then the last entry copied to all four sides,
-- so a grass node exposed by a program shows dirt where it was cut.
--
-- `is_ground_content` is the default `true` here and `false` on the two bounds
-- below, and that contrast is the point. These two *are* the mapgen's ground
-- and there is nothing to protect in them; the floor and the wall must never be
-- carved through, whatever generates. Moot while mg_flags carries nocaves and
-- nodungeons, and still the honest answer if that ever changes.
minetest.register_node("cc_mapgen:dirt", {
    description = "Dirt",
    tiles = {"cc_mapgen_dirt.png"},
    is_ground_content = true,
    diggable = false,
    drop = "",
    groups = {not_in_creative_inventory = 1}
})

minetest.register_node("cc_mapgen:grass", {
    description = "Grass",
    tiles = {
        "cc_mapgen_grass.png", "cc_mapgen_dirt.png", "cc_mapgen_dirt.png"
    },
    is_ground_content = true,
    diggable = false,
    drop = "",
    groups = {not_in_creative_inventory = 1}
})

-- The three mapgen aliases every non-V6 mapgen requires of a game. `default`
-- registered them until it was dropped, and they are not optional: with
-- mapgen_stone unresolved the engine writes "Mapgen alias 'mapgen_stone' is
-- invalid" to errorstream and fills the world with `ignore`, which is not a
-- node and cannot be stood on.
--
-- The two water aliases point at `air` rather than at a water node, because
-- this game has no water and generates none. mgflat writes water only where the
-- surface falls to or below `water_level`, whose default is 1, and this game's
-- surface stands at 128 with mgflat_spflags left at its own default of
-- `nolakes,nohills,nocaverns` -- which game.conf's disallowed_mapgen_settings
-- keeps the world creation dialog from changing. `air` is a registered node, so
-- both aliases resolve and the boot log stays clean; omitting them costs an
-- errorstream line and a warningstream line at every mapgen init. (B19)
minetest.register_alias("mapgen_stone", "cc_mapgen:dirt")
minetest.register_alias("mapgen_water_source", "air")
minetest.register_alias("mapgen_river_water_source", "air")

-- The two edges of the world. Both are near-black, so the floor and the wall
-- read as one material and neither is mistaken for ground.
--
-- Bedrock is the floor at y = 0, and the node cc_security's rescue writes back
-- under a player. Its texture is a mottled near-black grey.
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

-- The grass, the floor and the wall are written where the chunk already is: in
-- the VoxelManip the mapgen hands to the emerge threads. Needs Luanti 5.9,
-- which is what min_minetest_version in game.conf claims.
minetest.register_mapgen_script(minetest.get_modpath("cc_mapgen") ..
                                    "/mapgen_env.lua")
