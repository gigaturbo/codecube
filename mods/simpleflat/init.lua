local fst = minetest.get_content_id("default:dirt_with_grass")
local gnd = minetest.get_content_id("default:dirt")
local air = minetest.get_content_id("air")

minetest.clear_registered_biomes()
minetest.clear_registered_ores()
minetest.clear_registered_decorations()

minetest.register_on_generated(function(minp, maxp)
    local vm = VoxelManip(minp, maxp)
    local va = VoxelArea:new{MinEdge = minp, MaxEdge = maxp}
    local data = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                local index = va:index(x, y, z)
                if y == 0 then
                    data[index] = fst
                elseif y < 0 then
                    data[index] = gnd
                else
                    data[index] = air
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map()
end)
