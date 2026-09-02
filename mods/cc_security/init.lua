-- What a player may do to the world, and what the world may do on its own.
-- Everything a player sees was placed by a program: nothing is diggable,
-- nothing drops, no inventory accepts anything, there is no knockback, and
-- nothing grows, spreads or decays by itself.

local function deny() return 0 end

-- A node timer must be stopped with `false`, not with `deny` above: **`0` is
-- truthy in Lua 5.1**, and a truthy return restarts the timer. (B49)
local function never() return false end

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

-- Nothing is diggable, no node inventory accepts anything, and no node timer
-- ever fires. The inventory rule is the node's side of the boundary the callback
-- above holds for the player, and either one closes the bookshelf by itself;
-- neither stops the formspec opening, since it lives in node metadata rather
-- than in the definition. (S8) The timer rule is what stops a sapling a program
-- placed from becoming a tree the program never wrote. (B49)
--
-- No ABM runs either. `default` registers six, and two of them rewrite a build:
-- `dirt` beside any `dirt_with_*` becomes that node, and any `spreading_dirt_type`
-- reverts to plain `dirt` as soon as something opaque covers it -- so roofing a
-- grass floor quietly destroys the grass. Luanti has no API to unregister an ABM,
-- so each action is replaced with a no-op instead. The table is deliberately not
-- cleared: the engine registers each ABM by position, and emptying it would leave
-- those registrations pointing at nothing. (B49)
minetest.register_on_mods_loaded(function()
    for name in pairs(minetest.registered_nodes) do
        minetest.override_item(name, {
            diggable = false,
            on_timer = never,
            allow_metadata_inventory_put = deny,
            allow_metadata_inventory_take = deny,
            allow_metadata_inventory_move = deny
        })
    end
    for _, abm in ipairs(minetest.registered_abms) do
        abm.action = function() end
    end
end)

-- Both of these replace an engine function by assignment, which holds only
-- because `last_mod = cc_security` in game.conf loads this mod after every other
-- one. Without that the winner is alphabetical, and a mod loading later would
-- take the restriction away with nothing failing. (A8)
--
-- Drops are chained with an empty list rather than discarded, so whatever the
-- previous handler did besides handing out items still runs. Knockback is not
-- chained: it is a pure calculation whose result this game replaces outright, so
-- there is no previous behaviour left to keep.
local previous_drops = minetest.handle_node_drops

function minetest.handle_node_drops(pos, drops, digger)
    return previous_drops(pos, {}, digger)
end

function minetest.calculate_knockback() return 0 end
