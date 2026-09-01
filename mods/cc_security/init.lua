minetest.register_on_joinplayer(function(player)
    player:set_inventory_formspec("")
end)

-- Nothing is diggable, and no node inventory accepts anything. The second rule
-- is not redundant: a node can carry its own formspec, and default:bookshelf's
-- contains list[current_player;main], which shows the player the inventory the
-- blank formspec above is meant to keep shut. The palette can place one and
-- nothing can dig it afterwards, so an item moved in would be near-unreachable.
-- Denying the three inventory callbacks leaves the formspec openable but inert;
-- the formspec itself lives in node metadata, not in the definition, so it
-- cannot be removed from here. (S8)
local function deny() return 0 end

minetest.register_on_mods_loaded(function()
    for name in pairs(minetest.registered_nodes) do
        minetest.override_item(name, {
            diggable = false,
            allow_metadata_inventory_put = deny,
            allow_metadata_inventory_take = deny,
            allow_metadata_inventory_move = deny
        })
    end
end)

function minetest.handle_node_drops() end

function minetest.calculate_knockback() return 0 end
