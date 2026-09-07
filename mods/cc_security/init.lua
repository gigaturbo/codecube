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
-- deletes them; a player who walks in falls out of the generated world onto
-- unloaded space, which the engine collides with -- an invisible dark ledge.
-- So the world box is kept on the player too, whatever a program does. (B50)
--
-- The rescue keeps the player where they were: their own column, its floor made
-- whole under them, and the lowest room in it they fit. It falls back to the
-- spawn point only when that column has no room at all. See standing_pos below.
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
-- Without a static spawn point, the first air node over the mapgen's ground. The
-- bedrock plane at y = 0 is *not* the surface: mgflat fills stone up to and
-- including mgflat_ground_level, which this game sets to 128, so the plane sits
-- that far under it and a rescue to y = 1 would land the player inside stone.
-- The setting is read rather than assumed because a server owner may change it
-- -- game.conf does not disallow it -- and it comes back as a string.
--
-- The 128 guards a nil the engine should never return, cc_mapgen having forced
-- the setting before this mod loads. It is the game's own default, from
-- minetest.conf; the engine's own default of 8 would be a fallback into a
-- hundred and twenty nodes of solid stone.
--
-- `minetest.get_spawn_level` answers a similar question, but not here: it needs
-- the emerge manager, which is initialised after every mod has run, and until
-- then it returns 1 and writes an error to the log. (B50)
local ground = tonumber(minetest.get_mapgen_setting("mgflat_ground_level")) or
                   128

local spawn = minetest.setting_get_pos("static_spawnpoint") or
                  {x = 0, y = ground + 1, z = 0}

-- The three nodes the spawn fallback lands in: the one the player stands on, and
-- the two their body occupies. Rounded because a server owner's
-- static_spawnpoint need not sit on node centres, while a node position is an
-- integer.
local feet = vector.round(spawn)
local head = {x = feet.x, y = feet.y + 1, z = feet.z}
local below = {x = feet.x, y = feet.y - 1, z = feet.z}
local body = {feet, head}

-- Whether the node at `pos` would hold a player up: true, false, or nil when the
-- map cannot answer -- an unloaded block, an `ignore` left inside a loaded one,
-- or a node nothing registers. `minetest.get_node` is no use here, because it
-- reports `ignore` for an unloaded block and that reads as an ordinary solid
-- node, so a repair would be skipped on exactly the tick that needs it. (B50)
--
-- Every caller tests against `true` or `false` and never for truthiness, for two
-- reasons. `walkable` defaults to true and node definitions leave it out, so the
-- field is `nil` on an ordinary solid node such as default:stone. And an
-- unanswerable node has to count as unusable in *both* directions: it cannot be
-- relied on to hold the player, and it cannot be assumed to be clear.
local function walkable(pos)
    local node = minetest.get_node_or_nil(pos)
    if not node or node.name == "ignore" then return nil end
    local def = minetest.registered_nodes[node.name]
    if not def then return nil end
    return def.walkable ~= false
end

-- The fallback destination, made standable. The rescue is the one rule in this
-- mod that writes to the map -- every other one denies -- and it has to be,
-- because a destination is only a rescue if the player can stand in it, and a
-- program is free to have made the spawn column anything at all. Carve the floor
-- away under spawn and an unrepaired rescue drops the player straight back
-- through it four times a second, airborne throughout so they can never walk
-- out; build a solid node there instead and they are moved inside it, which with
-- damage off has no way out at all. So the ground is restored one node under
-- spawn and the two nodes the player occupies are cleared. Because the node
-- written is bedrock, this terminates whatever the program carved. (B50)
--
-- Clearing is right here and wrong in standing_pos below: this destination is
-- fixed, so there is nothing to do but make room for the player, while a column
-- always has somewhere higher to look.
local function repair_spawn()
    -- The ground has to arrive before the player does, and both reads and every
    -- write need the blocks resident: `minetest.set_node` into a mapblock that
    -- is not in memory silently does nothing. `load_area` is synchronous and
    -- does not run mapgen, which is enough here -- the spawn column has been
    -- generated since the world's first join.
    minetest.load_area(below, head)

    if walkable(below) ~= true then
        minetest.set_node(below, {name = "cc_mapgen:bedrock"})
    end

    for _, pos in ipairs(body) do
        if walkable(pos) ~= false then
            minetest.set_node(pos, {name = "air"})
        end
    end
end

-- How far up a column a rescue looks for room to stand: the mapgen surface,
-- which is stone to mgflat_ground_level, plus 64 nodes of whatever a program has
-- built on top of it, and never past the top of the world. It is also the height
-- of the column load_area pulls into memory -- thirteen mapblocks, a little over
-- 200 kB, with the surface at 128. A player whose own column is solid the whole
-- way up goes to spawn instead: that is what the bound trades away, and the
-- spawn path is the one that cannot fail.
local scan_top = math.min(ground + 64, world_max.y - 1)

-- Where to put a player who has left the world box: their own column, made
-- standable. nil when nothing in it fits them. (B50)
--
-- This restores the floor plane, which the rescue deliberately did not do
-- before, and so accepts leaving a player at the bottom of a shaft a program
-- dug. That is acceptable in this game and would not be in another: a player
-- standing in a shaft can point the drone at its wall and program their way out,
-- which a player falling out of the bottom of the world cannot. Nothing is
-- cleared to make room either -- the scan moves the player up instead, so the
-- rescue destroys nothing a program placed.
local function standing_pos(p)
    -- The wall stands *on* world_min.x and world_max.x, so the innermost
    -- standable column is one node in from each. A player who only fell through
    -- the floor is already inside, and the clamp leaves their column alone.
    local at = vector.round(p)
    local x = math.min(math.max(at.x, world_min.x + 1), world_max.x - 1)
    local z = math.min(math.max(at.z, world_min.z + 1), world_max.z - 1)

    -- Everything read below, and the one node written, have to be resident:
    -- minetest.set_node into a mapblock that is not in memory silently does
    -- nothing, and get_node_or_nil answers nil for one. load_area is
    -- synchronous, where emerge_area would let the player arrive before the
    -- ground; it does not run mapgen, which is enough, since a column a player
    -- reached has been generated.
    local floor = {x = x, y = 0, z = z}
    minetest.load_area(floor, {x = x, y = scan_top + 1, z = z})

    if walkable(floor) ~= true then
        minetest.set_node(floor, {name = "cc_mapgen:bedrock"})
    end

    -- The first height at which both nodes a player occupies are clear. What
    -- they land on needs no test of its own: y - 1 is either the floor just made
    -- whole, or a node that failed this same test one pass earlier, and nothing
    -- that fails it is something a player falls through. `clear` carries that
    -- answer forward so each node is read once.
    local clear = walkable({x = x, y = 1, z = z}) == false
    for y = 1, scan_top do
        local above = walkable({x = x, y = y + 1, z = z}) == false
        if clear and above then return {x = x, y = y, z = z} end
        clear = above
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
            -- In place first; spawn is the fallback, and the only destination
            -- guaranteed to be standable, because repair_spawn makes it so.
            local dest = standing_pos(p)
            if not dest then
                repair_spawn()
                dest = spawn
            end
            player:set_pos(dest)
        end
    end
end)
