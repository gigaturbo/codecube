-- What the engine's flat fill does not give: nothing below y = 0, a bedrock
-- plane at y = 0, one layer of grass at the surface, and a barrier wall
-- standing full height at the outermost generated column on x and on z. The
-- dirt under the grass is the engine's own, through init.lua's mapgen_stone
-- alias, and nothing here touches it.
--
-- This file runs in the mapgen environment, on the emerge threads; init.lua
-- registers it. There is no global step, no timer and no node metadata there,
-- and the chunk is already in the VoxelManip, so read_from_map and
-- write_to_map are neither needed nor allowed.

local c_air = core.get_content_id("air")
local c_grass = core.get_content_id("cc_mapgen:grass")
local c_bedrock = core.get_content_id("cc_mapgen:bedrock")
local c_barrier = core.get_content_id("cc_mapgen:barrier")

-- Where the wall stands. Not at mapgen_limit: only mapchunks falling wholly
-- inside the limit are generated, so the last generated column is short of it.
-- This reads the active setting, which init.lua has already forced -- the
-- mapgen environment is initialised after every mod has loaded.
local world_min, world_max = core.get_mapgen_edges()

-- Where the grass goes. This environment cannot see the main one's locals, so
-- the number is read again rather than passed in: `get_mapgen_setting` is one
-- of the mapgen functions the mapgen env is documented to have, since 5.9, and
-- in the emerge environment it reads the same MapSettingsManager that
-- init.lua's set_mapgen_setting(..., true) wrote to. It comes back as a string.
--
-- The 128 guards a nil that should not happen -- the setting is in the world's
-- map_meta.txt by the time any chunk generates -- and it is the game's own
-- default, as in cc_security. The engine's own default of 8 would put the grass
-- a hundred and twenty nodes under the ground a player walks on.
local ground_level =
    tonumber(core.get_mapgen_setting("mgflat_ground_level")) or 128

core.register_on_generated(function(vmanip, minp, maxp, blockseed)
    -- An outermost column of the world concerns this chunk only if it falls
    -- inside it.
    local wall_x, wall_z = {}, {}
    if minp.x <= world_min.x then wall_x[#wall_x + 1] = world_min.x end
    if maxp.x >= world_max.x then wall_x[#wall_x + 1] = world_max.x end
    if minp.z <= world_min.z then wall_z[#wall_z + 1] = world_min.z end
    if maxp.z >= world_max.z then wall_z[#wall_z + 1] = world_max.z end

    local has_ground = minp.y <= ground_level and maxp.y >= ground_level

    -- Most chunks are interior, wholly above the floor and wholly clear of the
    -- surface. They need nothing, and a get_data/set_data pass over one is half
    -- a million nodes read and written on an emerge thread to change none of
    -- them. Keep this exhaustive: a chunk this returns for is a chunk nothing
    -- below writes to, and a new layer added without a test here is a layer
    -- that appears in some chunks and not others.
    if minp.y > 0 and #wall_x == 0 and #wall_z == 0 and not has_ground then
        return
    end

    local data = vmanip:get_data()
    -- Indices are into the emerged area, which is larger than minp..maxp. Only
    -- minp..maxp is written: the shell around it belongs to the neighbouring
    -- chunks, and each of those gets this callback in its turn.
    local area = VoxelArea(vmanip:get_emerged_area())

    -- One layer of grass over the engine's dirt, replacing the topmost fill
    -- node rather than sitting above it: mgflat fills up to and including
    -- mgflat_ground_level, so this y already holds dirt.
    --
    -- Written before the loop below, so that whatever the loop writes wins
    -- where the two meet. That matters twice: the wall stays barrier all the
    -- way up through the surface, and a ground level a server owner has put at
    -- or under 0 does not eat the bedrock floor.
    if has_ground then
        local y = ground_level
        for i in area:iter(minp.x, y, minp.z, maxp.x, y, maxp.z) do
            data[i] = c_grass
        end
    end

    for y = minp.y, maxp.y do
        if y < 0 then
            for i in area:iter(minp.x, y, minp.z, maxp.x, y, maxp.z) do
                data[i] = c_air
            end
        elseif y == 0 then
            for i in area:iter(minp.x, y, minp.z, maxp.x, y, maxp.z) do
                data[i] = c_bedrock
            end
        else
            for _, x in ipairs(wall_x) do
                for i in area:iter(x, y, minp.z, x, y, maxp.z) do
                    data[i] = c_barrier
                end
            end
            for _, z in ipairs(wall_z) do
                for i in area:iter(minp.x, y, z, maxp.x, y, z) do
                    data[i] = c_barrier
                end
            end
        end
    end

    vmanip:set_data(data)
end)
