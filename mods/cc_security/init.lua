-- What a player may do to the world, and to their own inventory. Everything a
-- player sees is placed by a program: nothing is diggable, nothing drops, no
-- inventory accepts anything, and there is no knockback.

local function deny() return 0 end

minetest.register_on_joinplayer(function(player)
    player:set_inventory_formspec("")
end)

-- The player may not move an item, anywhere. Blanking the formspec above only
-- removes the usual way in; a node carrying its own formspec with
-- list[current_player;main] is another, and through one of those a player could
-- drag a drone tool out of the hotbar into a row they can no longer open. This
-- covers moves within the player's inventory as well as puts and takes across
-- it, and only for actions the player initiates -- codeblock still hands out
-- the two tools from Lua. (S8)
minetest.register_allow_player_inventory_action(deny)

-- Nothing is diggable, and no node inventory accepts anything. That second rule
-- is the node's side of the same boundary the callback above holds for the
-- player, and either one closes the bookshelf by itself. Neither stops the
-- formspec opening: it lives in node metadata, not in the definition, so
-- nothing reachable from here removes it. (S8)
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
