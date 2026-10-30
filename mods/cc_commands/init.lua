-- The game's own chat commands, all under `/codecube <subcommand>`, the way
-- codeblock keeps its own under `/codeblock`. One table of subcommands, each
-- with its usage line and the privileges it needs, so a panel can later offer
-- the same handlers, and only the ones a player may run, without a second copy.
local subcommands = {}

-- How fast a player moves, on foot and in flight. Four levels, set by a player
-- holding `server`, kept in the target's metadata and re-applied on every join.
-- A player who was never given one moves at `normal`.
--
-- One multiplier on the engine's `speed` physics field, which scales walking,
-- fast mode, flying, climbing and sneaking together, with their acceleration.
-- `speed_walk` and `speed_fast` would scale them apart, but they are not in the
-- 5.8 physics set the game's 5.9 floor can rely on.
--
-- Each is a multiple of the engine's own speed: 4 nodes a second walking, 20 in
-- fast mode.
local levels = {slow = 2, normal = 2.5, fast = 3, fastest = 3.5}
local speed_key = "cc_commands:speed"

local function apply_speed(player)
    local level = player:get_meta():get_string(speed_key)
    player:set_physics_override({speed = levels[level] or levels.normal})
end

minetest.register_on_joinplayer(apply_speed)

subcommands.speed = {
    params = "<slow|normal|fast|fastest> [<player>]",
    privs = {server = true},
    run = function(caller, param)
        local level, target = param:match("^(%S+)%s*(%S*)$")
        if not levels[level] then return false end
        if target == "" then target = caller end
        local player = minetest.get_player_by_name(target)
        if not player then
            return false, "Player " .. target .. " is not online."
        end
        player:get_meta():set_string(speed_key, level)
        apply_speed(player)
        return true, target .. " now moves at " .. level .. " speed."
    end
}

-- Where a player may be sent: the world's surface, kept clear of the wall by
-- 500 nodes, or by a tenth of the world's width when that is less, so a small
-- world still has room to choose from. `y` is the first node above the ground.
--
-- The edges and the surface are read when a command runs, not at load time,
-- because cc_mapgen forces both and this mod does not depend on it loading
-- first.
local function surface()
    local min, max = minetest.get_mapgen_edges()
    local margin = math.min(500, math.floor((max.x - min.x) / 10))
    local ground = tonumber(minetest.get_mapgen_setting("mgflat_ground_level"))
    return {
        x0 = min.x + margin,
        x1 = max.x - margin,
        z0 = min.z + margin,
        z1 = max.z - margin,
        y = (ground or 128) + 1
    }
end

-- A fresh place to build: a random column of the surface. Nothing checks that the
-- column is empty. In a world this wide a random column is almost always ground
-- nobody has built on, and a player who lands in a build can ask again.
--
-- It needs the `newplace` privilege, which every player is given once, on their
-- first join with this mod, and which an admin can then revoke for good: the
-- grant is remembered in the player's metadata and never repeated.
-- `default_privs` would not do, because it reaches new players only, and a
-- server owner's own value would replace the game's.
--
-- It works once per `codecube_newplace_cooldown` seconds, so it cannot be used
-- to flood the server with new mapblocks. A player holding `server` is never
-- made to wait. The cooldown is held in memory: a restart forgets it.
minetest.register_privilege("newplace", {
    description = "Can move to a fresh place to build with /codecube newplace"
})

-- The privileges every player is given once, each remembered on its own so one
-- added later still reaches players who joined before it.
local granted_once = {"newplace", "saveme"}

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    local name = player:get_player_name()
    local privs = minetest.get_player_privs(name)
    for _, priv in ipairs(granted_once) do
        local key = "cc_commands:" .. priv .. "_granted"
        if meta:get_int(key) ~= 1 then
            privs[priv] = true
            meta:set_int(key, 1)
        end
    end
    minetest.set_player_privs(name, privs)
end)

local last_newplace = {}

subcommands.newplace = {
    params = "",
    privs = {newplace = true},
    run = function(caller)
        local now = minetest.get_us_time() / 1e6
        local cooldown =
            tonumber(minetest.settings:get("codecube_newplace_cooldown")) or 60
        local wait = (last_newplace[caller] or -math.huge) + cooldown - now
        if wait > 0 and
            not minetest.check_player_privs(caller, {server = true}) then
            return false, ("Wait %d seconds before moving again."):format(
                       math.ceil(wait))
        end
        local player = minetest.get_player_by_name(caller)
        if not player then return false, "You are not in the world." end

        local box = surface()
        player:set_pos({
            x = math.random(box.x0, box.x1),
            y = box.y,
            z = math.random(box.z0, box.z1)
        })
        last_newplace[caller] = now
        return true, "Moved to a fresh place."
    end
}

-- A way out for a player walled in by a program's build, who cannot dig. Where
-- they land is cc_security's, which owns the rescue from the void too: on top
-- of a build nearby, or, when there is none, the mapblock around them carved
-- out.
--
-- It needs the `saveme` privilege, given once like `newplace`, and works once a
-- second per player.
minetest.register_privilege("saveme", {
    description = "Can climb out of a build with /codecube saveme"
})

local last_saveme = {}
local unburied = {
    moved = "Moved on top of a build nearby.",
    carved = "No build nearby to stand on, so the blocks around you were cleared."
}

subcommands.saveme = {
    params = "",
    privs = {saveme = true},
    run = function(caller)
        local now = minetest.get_us_time() / 1e6
        if now - (last_saveme[caller] or -math.huge) < 1 then
            return false, "Wait a moment before asking again."
        end
        local player = minetest.get_player_by_name(caller)
        if not player then return false, "You are not in the world." end
        local outcome = cc_security.unbury(player)
        if not outcome then
            return false, "Nothing is built above you. " ..
                       "/codecube newplace moves you somewhere fresh."
        end
        last_saveme[caller] = now
        return true, unburied[outcome]
    end
}

-- Spreading a class: each chosen player gets a plot of their own, never one
-- that was built on before, so a teacher can send everyone to fresh ground as
-- often as they like.
--
-- The surface is cut into square plots of `codecube_plot_size` nodes, and a
-- player lands in the middle of one. The 100 by 100 nodes at a plot's centre are
-- its core, and the world keeps a record of the cores already used: one around
-- every player online at each spread, where they have been building, and one
-- around each landing. A plot is free when its core overlaps no recorded one.
-- The record is kept as points, not plots, so it stays right when a server owner
-- changes the plot size. Nothing ever clears it: once every plot is used, the
-- command says so.
--
-- A free plot can still hold a build nobody recorded, from a player who walked
-- there. So its core is generated and read before anyone lands: anything but air
-- in the 16 layers above the ground marks it used, and the player gets another.
--
-- `random` takes any free plot. `spaced` takes the free plot farthest from
-- everyone placed so far: players who are not moving, then each landing in turn.
-- With no player arguments every online player but the caller moves. A name
-- adds that player, `*` in one matches any run of characters, and a leading `-`
-- leaves out the players it matches.
minetest.register_privilege("spreadplayers", {
    description = "Can move players to fresh plots with /codecube spreadplayers"
})

local storage = minetest.get_mod_storage()
local used = minetest.deserialize(storage:get_string("used_cores")) or {}
local core_size, core_depth = 100, 16

local function record(pos)
    used[#used + 1] = {x = math.floor(pos.x + 0.5), z = math.floor(pos.z + 0.5)}
    storage:set_string("used_cores", minetest.serialize(used))
end

-- The free plot that best suits `layout`, or nil once none is left.
local function pick(layout, placed, box)
    local size = tonumber(minetest.settings:get("codecube_plot_size")) or 300
    local spaced = layout == "spaced" and #placed > 0
    local best, best_score
    for x = box.x0 + math.floor(size / 2), box.x1 - size / 2, size do
        for z = box.z0 + math.floor(size / 2), box.z1 - size / 2, size do
            local free = true
            for _, c in ipairs(used) do
                free = free and (math.abs(c.x - x) >= core_size or
                           math.abs(c.z - z) >= core_size)
            end
            local score = spaced and math.huge or math.random()
            for _, p in ipairs(spaced and placed or {}) do
                score = math.min(score, (p.x - x) ^ 2 + (p.z - z) ^ 2)
            end
            if free and (not best or score > best_score) then
                best, best_score = {x = x, y = box.y, z = z}, score
            end
        end
    end
    return best
end

-- Sends one player of a spread to a free plot, retrying on a plot found built,
-- and tells the caller once the last player of the spread has landed or failed.
local function land(job, name)
    local function done(moved)
        local list = moved and job.moved or job.stuck
        list[#list + 1] = name
        if #job.moved + #job.stuck < job.count then return end
        local text = ("Spread %d players."):format(#job.moved)
        if #job.stuck > 0 then
            text = text .. " No free plot was left for " ..
                       table.concat(job.stuck, ", ") .. "."
        end
        minetest.chat_send_player(job.caller, text)
    end

    local spot = pick(job.layout, job.placed, job.box)
    if not spot then return done(false) end
    record(spot)
    job.placed[#job.placed + 1] = spot
    local half = core_size / 2
    local minp = {x = spot.x - half, y = spot.y, z = spot.z - half}
    local maxp = {
        x = spot.x + half,
        y = spot.y + core_depth - 1,
        z = spot.z + half
    }
    minetest.emerge_area(minp, maxp, function(_, _, remaining)
        if remaining > 0 then return end
        local vm = minetest.get_voxel_manip()
        local emin, emax = vm:read_from_map(minp, maxp)
        local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
        local data = vm:get_data()
        local air = minetest.get_content_id("air")
        for i in area:iterp(minp, maxp) do
            if data[i] ~= air then return land(job, name) end
        end
        local player = minetest.get_player_by_name(name)
        if not player then return done(false) end
        player:set_pos(spot)
        minetest.chat_send_player(name, "You were moved to a fresh plot.")
        done(true)
    end)
end

-- A player-name glob as an anchored Lua pattern: every character literal but
-- `*`, which matches any run.
local function glob(text)
    return "^" .. text:gsub("%W", "%%%0"):gsub("%%%*", ".*") .. "$"
end

subcommands.spreadplayers = {
    params = "<random|spaced> [<player>|-<player> ...]",
    privs = {spreadplayers = true},
    run = function(caller, param)
        local layout, rest = param:match("^(%S+)%s*(.*)$")
        if layout ~= "random" and layout ~= "spaced" then return false end
        local include, exclude = {}, {}
        for token in rest:gmatch("%S+") do
            if token:sub(1, 1) == "-" then
                exclude[#exclude + 1] = glob(token:sub(2))
            else
                include[#include + 1] = glob(token)
            end
        end

        local job = {
            caller = caller,
            layout = layout,
            box = surface(),
            placed = {},
            moved = {},
            stuck = {}
        }
        local chosen, online = {}, minetest.get_connected_players()
        for _, player in ipairs(online) do
            local name = player:get_player_name()
            local wanted = #include == 0 and name ~= caller
            for _, p in ipairs(include) do
                wanted = wanted or name:find(p) ~= nil
            end
            for _, p in ipairs(exclude) do
                wanted = wanted and not name:find(p)
            end
            if wanted then
                chosen[#chosen + 1] = name
            else
                job.placed[#job.placed + 1] = player:get_pos()
            end
        end
        if #chosen == 0 then return false, "No online player matches." end
        for _, player in ipairs(online) do record(player:get_pos()) end

        job.count = #chosen
        for _, name in ipairs(chosen) do land(job, name) end
        return true, ("Spreading %d players with %s."):format(#chosen, layout)
    end
}

-- Built from the table once, so the help cannot drift from the subcommands.
local forms = {}
for name, sub in pairs(subcommands) do
    forms[#forms + 1] = (name .. " " .. sub.params):gsub(" $", "")
end
table.sort(forms)

-- The usage a caller is shown lists only what they may run.
local function usage(caller)
    local lines = {}
    for _, form in ipairs(forms) do
        local sub = subcommands[form:match("^%S+")]
        if minetest.check_player_privs(caller, sub.privs) then
            lines[#lines + 1] = "Usage: /codecube " .. form
        end
    end
    return table.concat(lines, "\n")
end

-- No command-level privs: each subcommand names what it needs. A handler
-- returns false with no message for a malformed argument, and gets the usage.
minetest.register_chatcommand("codecube", {
    params = table.concat(forms, " | "),
    description = "The game's own commands",
    func = function(caller, param)
        local name, rest = param:match("^%s*(%S+)%s*(.-)%s*$")
        local sub = name and subcommands[name]
        if not sub then return false, usage(caller) end
        local ok, missing = minetest.check_player_privs(caller, sub.privs)
        if not ok then
            return false, "You need the " .. table.concat(missing, ", ") ..
                       " privilege for /codecube " .. name .. "."
        end
        local done, message = sub.run(caller, rest)
        return done, message or usage(caller)
    end
})
