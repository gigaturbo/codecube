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
--
-- `diggable = false` is what enforces the restriction, but only on the server.
-- The client predicts a dig from the node's groups and its own tool
-- capabilities alone -- `core.get_dig_params` takes those two and never
-- `diggable` -- so a node the hand believes it can break cracks on screen
-- before the server refuses. Dropping the digging groups below stops the
-- prediction at its source. Every other group is kept deliberately: they carry
-- colour, flammability, attachment, decay and whatever the palettes read, and
-- none of them says anything about digging. (B48)
local dig_groups = {
    crumbly = true,
    cracky = true,
    snappy = true,
    choppy = true,
    oddly_breakable_by_hand = true,
    dig_immediate = true
}

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        local groups = {}
        for group, value in pairs(def.groups or {}) do
            if not dig_groups[group] then groups[group] = value end
        end
        minetest.override_item(name, {
            groups = groups,
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

-- Nothing above stops a *program* opening a hole. To the drone the bedrock floor
-- and the wall are ordinary nodes well inside its mapgen_limit bound, so `remove`
-- deletes them; a player who walks in falls out of the bottom of the generated
-- world and never lands. The world box is therefore kept on the player too, and
-- that holds whatever a program does to the nodes. (B50)
--
-- The rescue is the spawn point, not the floor plane above the hole: putting the
-- player back at the same x, z drops them through the same hole again, four times
-- a second, forever. Losing your position is the lesser cost.
--
-- The edges come from the engine, not from mapgen_limit: only mapchunks falling
-- wholly inside the limit are generated, so the last generated column is short of
-- it. cc_mapgen has forced the setting by now, since last_mod makes this the last
-- mod to load, and the call reads a copy of the mapgen params rather than
-- freezing them, so asking at load time is safe.
local world_min, world_max = minetest.get_mapgen_edges()

-- `minetest.settings:get_pos` is 5.10 and later; this spelling is the one the
-- game's 5.9 floor has.
--
-- Without a static spawn point, the first air node over the mapgen's ground --
-- the same node the engine's own findSpawnPos gives a new player. The bedrock
-- plane at y = 0 is *not* the surface: mgflat fills stone up to and including
-- mgflat_ground_level, 8 by default, so the plane sits eight nodes under it and
-- a rescue to y = 1 would land the player inside stone. The setting is read
-- rather than assumed because a server owner may change it -- game.conf does
-- not disallow it -- and it comes back as a string. The 8 guards a nil the
-- engine should never return, since that value is its own default.
--
-- `minetest.get_spawn_level` answers the same question, but not here: it needs
-- the emerge manager, which is initialised after every mod has run, and until
-- then it returns 1 and writes an error to the log. (B50)
local ground = tonumber(minetest.get_mapgen_setting("mgflat_ground_level"))

local spawn = minetest.setting_get_pos("static_spawnpoint") or
                  {x = 0, y = (ground or 8) + 1, z = 0}

-- The three nodes a rescue lands in: the one the player stands on, and the two
-- their body occupies. Rounded because a server owner's static_spawnpoint need
-- not sit on node centres, while a node position is an integer.
local feet = vector.round(spawn)
local head = {x = feet.x, y = feet.y + 1, z = feet.z}
local below = {x = feet.x, y = feet.y - 1, z = feet.z}
local body = {feet, head}

-- The definition of the node at `pos`, or nil when the map cannot answer: an
-- unloaded block, an `ignore` left inside a loaded one, or a node nothing
-- registers. `minetest.get_node` is no use here, because it reports `ignore` for
-- an unloaded block and that reads as an ordinary solid node -- the repair below
-- would then be skipped on exactly the tick that needs it, and the loop it
-- exists to break would carry on looking unfixed. (B50)
local function known_node(pos)
    local node = minetest.get_node_or_nil(pos)
    if not node or node.name == "ignore" then return nil end
    return minetest.registered_nodes[node.name]
end

-- The only place this mod writes to the map; every other rule in it denies. The
-- rescue has to be the exception, because a destination is only a rescue if the
-- player can stand in it, and a program is free to have made the spawn column
-- anything at all. Carve the floor away under spawn and an unrepaired rescue
-- drops the player straight back through it four times a second, airborne
-- throughout so they can never walk out; build a solid node there instead and
-- they are moved inside it, which with damage off has no way out at all. So the
-- ground is restored under the destination and the two nodes the player occupies
-- are cleared. Because the node written is bedrock, this terminates whatever the
-- program carved. (B50)
--
-- The repair goes one node under the destination, not on the bedrock plane at
-- y = 0: filling the plane would leave the player at the bottom of the shaft the
-- program dug, unable to climb out and unable to dig, which is the same softlock
-- by another route.
--
-- `walkable` defaults to true and node definitions leave it out, so the tests are
-- against `false` rather than truthiness. An unanswerable node is repaired in
-- both directions: it cannot be relied on to hold the player, and it cannot be
-- assumed to be clear.
local function repair_spawn()
    -- The ground has to arrive before the player does, and both reads and every
    -- write need the blocks resident: `minetest.set_node` into a mapblock that
    -- is not in memory silently does nothing. `load_area` is synchronous and
    -- does not run mapgen, which is enough here -- the spawn column has been
    -- generated since the world's first join.
    minetest.load_area(below, head)

    local under = known_node(below)
    if not under or under.walkable == false then
        minetest.set_node(below, {name = "cc_mapgen:bedrock"})
    end

    for _, pos in ipairs(body) do
        local def = known_node(pos)
        if not def or def.walkable ~= false then
            minetest.set_node(pos, {name = "air"})
        end
    end
end

-- Four times a second, not every server step for every player: a fall crosses
-- nothing that matters in 250 ms.
local since_check = 0

minetest.register_globalstep(function(dtime)
    since_check = since_check + dtime
    if since_check < 0.25 then return end
    since_check = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        local p = player:get_pos()
        -- `< 0` and not `<= 0`: a player's position is their feet, and the
        -- bedrock plane's nodes span y = -0.5 to 0.5, so standing on an
        -- exposed floor reads as 0.5. Only a player already through it is
        -- below zero.
        local outside = p.y < 0 or p.x < world_min.x or p.x > world_max.x or
                            p.z < world_min.z or p.z > world_max.z
        if outside then
            repair_spawn()
            player:set_pos(spawn)
        end
    end
end)
