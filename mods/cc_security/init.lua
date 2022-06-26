minetest.register_on_joinplayer(function(player)
    player:set_inventory_formspec("")
end)

minetest.register_on_mods_loaded(function()
    for name in pairs(minetest.registered_nodes) do
        minetest.override_item(name, {diggable = false})
    end
end)

function minetest.handle_node_drops() end

function minetest.calculate_knockback() return 0 end
