-- The edge of the world, written into each chunk as the mapgen produces it:
-- nothing below y = 0, a bedrock plane at y = 0, and a barrier wall standing
-- full height at the outermost generated column on x and on z.
--
-- This file runs in the mapgen environment, on the emerge threads; init.lua
-- registers it. There is no global step, no timer and no node metadata there,
-- and the chunk is already in the VoxelManip, so read_from_map and
-- write_to_map are neither needed nor allowed.

local c_air = core.get_content_id("air")
local c_bedrock = core.get_content_id("cc_mapgen:bedrock")
local c_barrier = core.get_content_id("cc_mapgen:barrier")

-- Where the wall stands. Not at mapgen_limit: only mapchunks falling wholly
-- inside the limit are generated, so the last generated column is short of it.
-- This reads the active setting, which init.lua has already forced -- the
-- mapgen environment is initialised after every mod has loaded.
local world_min, world_max = core.get_mapgen_edges()

core.register_on_generated(function(vmanip, minp, maxp, blockseed)
    -- An outermost column of the world concerns this chunk only if it falls
    -- inside it.
    local wall_x, wall_z = {}, {}
    if minp.x <= world_min.x then wall_x[#wall_x + 1] = world_min.x end
    if maxp.x >= world_max.x then wall_x[#wall_x + 1] = world_max.x end
    if minp.z <= world_min.z then wall_z[#wall_z + 1] = world_min.z end
    if maxp.z >= world_max.z then wall_z[#wall_z + 1] = world_max.z end

    -- Most chunks are interior and wholly above the floor. They need nothing,
    -- and a get_data/set_data pass over one is half a million nodes read and
    -- written on an emerge thread to change none of them.
    if minp.y > 0 and #wall_x == 0 and #wall_z == 0 then return end

    local data = vmanip:get_data()
    -- Indices are into the emerged area, which is larger than minp..maxp. Only
    -- minp..maxp is written: the shell around it belongs to the neighbouring
    -- chunks, and each of those gets this callback in its turn.
    local area = VoxelArea(vmanip:get_emerged_area())

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
