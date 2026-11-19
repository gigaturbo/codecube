-- What a player may do to the world, and what the world may do on its own.
-- Everything a player sees was placed by a program: nothing is diggable,
-- nothing drops, no inventory accepts anything, there is no knockback, and
-- nothing grows, spreads or decays by itself.

-- What other mods may call: `unbury`, for /codecube saveme.
cc_security = {}

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
-- above holds for the player: a node that carries an inventory -- a chest, a
-- furnace, a bookshelf -- is closed by either rule on its own, and neither stops
-- its formspec opening, since that lives in node metadata rather than in the
-- definition. (S8) The timer rule is what stops a node a program placed from
-- becoming something the program never wrote, a sapling into a tree. (B49)
--
-- No ABM runs either. Nothing this game bundles registers one today: the six
-- that mattered were `default`'s and went out with it under A13, two of them
-- rewriting a build as they ran -- `dirt` beside any `dirt_with_*` became that
-- node, and any `spreading_dirt_type` reverted to plain `dirt` as soon as
-- something opaque covered it, so roofing a grass floor quietly destroyed the
-- grass. The pass stays anyway, for the same reason the node loop above is
-- unconditional: it costs one loop over a table that is usually empty, and it
-- covers whatever the next codeblock release or a server owner's own mod
-- registers. Luanti has no API to unregister an ABM, so each action is replaced
-- with a no-op instead. The table is deliberately not cleared: the engine
-- registers each ABM by position, and emptying it would leave those
-- registrations pointing at nothing. (B49)
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

-- One pass over every registered node, because Luanti offers no game-wide
-- switch for any of these four rules.
-- `register_allow_player_inventory_action` governs the player's own inventory
-- only, with no counterpart for a node's metadata inventory, and a node timer
-- has no global form at all. Digging alone has one -- `core.node_dig`, the
-- default a definition's `on_dig` falls back to -- but a node bringing its own
-- `on_dig` never reaches it, and it says nothing to the client, so the group
-- strip above would still need the per-node walk. (A8)
-- The content ids of every node a player stands on, for the rescue below.
-- `walkable` defaults to true and definitions leave it out, so the test is
-- against `false`: a truthiness test would read every ordinary node as
-- walk-through. (B50)
-- The barrier is left out: every mapblock column at the edge holds a wall
-- column, whose top is wherever generation has reached, so counting it would
-- land a player on the wall and then inside it. (B-W-1)
local solid = {}

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        solid[minetest.get_content_id(name)] =
            def.walkable ~= false and name ~= "cc_mapgen:barrier" or nil
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
-- deletes them; a player who walks in falls out of the generated world onto
-- unloaded space, which the engine collides with -- an invisible dark ledge.
-- So the world box is kept on the player too, whatever a program does. (B50)
--
-- A player found outside the world box, or buried in a build and asking with
-- /codecube saveme, is moved onto the top of a build nearby: the highest solid
-- node of a mapblock column that leaves room for them under the top of the
-- world. Columns are drawn at random, `tries` at a time, up to `reach` nodes
-- away, then up to twice that, then up to four times. When every one fails, a
-- fallen player gets a bedrock platform where they are, and a buried one has
-- the mapblock around them carved out. Nothing else here writes to the map.
--
-- The edges come from the engine, not from mapgen_limit: only mapchunks falling
-- wholly inside the limit are generated, so the last generated column is short of
-- it. cc_mapgen has forced the setting by now, since last_mod makes this the last
-- mod to load, and the call reads a copy of the mapgen params rather than
-- freezing them, so asking at load time is safe.
local world_min, world_max = minetest.get_mapgen_edges()

-- Read rather than assumed, because a server owner may change it, and it comes
-- back as a string. The 128 guards a nil the engine should never return; it is
-- the game's own default, not the engine's 8.
local ground = tonumber(minetest.get_mapgen_setting("mgflat_ground_level")) or
                   128

local tries, reach = 8, 32

-- `pos` rounded to a node and moved inside the wall, which stands on the
-- outermost columns, so one node in from each.
local function inside(pos)
    local at = vector.round(pos)
    at.x = math.min(math.max(at.x, world_min.x + 1), world_max.x - 1)
    at.z = math.min(math.max(at.z, world_min.z + 1), world_max.z - 1)
    return at
end

-- Whether the node at `pos` is solid. An unloaded or never generated one is
-- not: nothing can have been built there. `minetest.get_node` would report
-- `ignore` for it, so `get_node_or_nil`. (B50)
local function solid_at(pos)
    local node = minetest.get_node_or_nil(pos)
    return node ~= nil and solid[minetest.get_content_id(node.name)] == true
end

-- The node above the highest solid one in the mapblock whose lowest corner is
-- `minp`, or nil when it holds none.
local function block_top(minp)
    local maxp = vector.add(minp, 15)
    local vm = minetest.get_voxel_manip(minp, maxp)
    local emin, emax = vm:get_emerged_area()
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()
    for y = maxp.y, minp.y, -1 do
        for z = minp.z, maxp.z do
            local i = area:index(minp.x, y, z)
            for x = minp.x, maxp.x do
                if solid[data[i]] then return {x = x, y = y + 1, z = z} end
                i = i + 1
            end
        end
    end
end

-- Where a player lands in the mapblock column at block coordinates `bx, bz`:
-- on its highest solid node, or nil when that leaves no room under the top of
-- the world. The column is read from the top down, and a mapblock that was
-- never saved costs a lookup and no read. A column never generated at all has
-- nothing built in it, so the player lands where its ground will be.
local function column_top(bx, bz)
    local x, z = bx * 16, bz * 16
    minetest.load_area({x = x, y = 0, z = z},
                       {x = x + 15, y = world_max.y, z = z + 15})
    for by = math.floor(world_max.y / 16), 0, -1 do
        local minp = {x = x, y = by * 16, z = z}
        local top = minetest.get_node_or_nil(minp) and block_top(minp)
        if top then return top.y + 1 <= world_max.y and top or nil end
    end
    return {x = x + 8, y = ground + 1, z = z + 8}
end

-- The top of a build near `at`, or nil when none of the columns drawn has
-- room. Each band is twice as far out as the one before.
local function nearby_top(at)
    local tried, near, far = {}, 0, reach
    for _ = 1, 3 do
        for _ = 1, tries do
            local r = near + math.random() * (far - near)
            local a = math.random() * 2 * math.pi
            local p = inside({
                x = at.x + r * math.cos(a),
                y = at.y,
                z = at.z + r * math.sin(a)
            })
            local bx, bz = math.floor(p.x / 16), math.floor(p.z / 16)
            local key = bx .. " " .. bz
            local top = not tried[key] and column_top(bx, bz)
            tried[key] = true
            if top then return top end
        end
        near, far = far, far * 2
    end
end

-- The last resort for a fallen player: a 3 by 3 bedrock platform under where
-- they are, inside the world box, and the two nodes their body takes cleared.
-- `set_node` into a mapblock not in memory silently does nothing, so the area
-- is loaded first; `load_area` is synchronous, where `emerge_area` would let the
-- player arrive before the ground. (B50)
local function platform(pos)
    local at = inside(pos)
    at.y = math.min(math.max(at.y, 1), world_max.y - 2)
    minetest.load_area(vector.subtract(at, 1), vector.add(at, 1))
    for x = at.x - 1, at.x + 1 do
        for z = at.z - 1, at.z + 1 do
            local p = {x = x, y = at.y - 1, z = z}
            if not solid_at(p) then
                minetest.set_node(p, {name = "cc_mapgen:bedrock"})
            end
        end
    end
    for y = at.y, at.y + 1 do
        local p = {x = at.x, y = y, z = at.z}
        if solid_at(p) then minetest.remove_node(p) end
    end
    return at
end

-- The last resort for a buried player: every node of the mapblocks around their
-- feet and head turned to air, except the floor and the wall.
local function carve(at)
    local minp = vector.multiply(vector.floor(vector.divide(at, 16)), 16)
    local maxp = {
        x = minp.x + 15,
        y = math.floor((at.y + 1) / 16) * 16 + 15,
        z = minp.z + 15
    }
    local vm = minetest.get_voxel_manip(minp, maxp)
    local data = vm:get_data()
    local air = minetest.get_content_id("air")
    local kept = {
        [minetest.get_content_id("cc_mapgen:bedrock")] = true,
        [minetest.get_content_id("cc_mapgen:barrier")] = true
    }
    for i = 1, #data do
        if not kept[data[i]] then data[i] = air end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

-- Gets a player out of a build, for /codecube saveme. Answers nil when nothing
-- solid is where they stand or anywhere above them, "moved" when they were put
-- on a build nearby, and "carved" when there was none to put them on.
function cc_security.unbury(player)
    local at = vector.round(player:get_pos())
    minetest.load_area(at, {x = at.x, y = world_max.y, z = at.z})
    local y = at.y
    while y <= world_max.y and not solid_at({x = at.x, y = y, z = at.z}) do
        -- A mapblock not in memory was never saved: skip the rest of it.
        local loaded = minetest.get_node_or_nil({x = at.x, y = y, z = at.z})
        y = loaded and y + 1 or (math.floor(y / 16) + 1) * 16
    end
    if y > world_max.y then return nil end

    local dest = nearby_top(at)
    if dest then
        player:set_pos(dest)
        return "moved"
    end
    carve(at)
    return "carved"
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
            player:set_pos(nearby_top(inside(p)) or platform(p))
        end
    end
end)
