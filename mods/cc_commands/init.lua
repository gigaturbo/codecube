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

-- A fresh place to build: a random column of the world's surface, kept clear
-- of the wall by 500 nodes, or by a tenth of the world's width when that is
-- less, so a small world still has room to choose from. Nothing checks that the
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
--
-- The edges and the surface are read when the command runs, not at load time,
-- because cc_mapgen forces both and this mod does not depend on it loading
-- first.
minetest.register_privilege("newplace", {
    description = "Can move to a fresh place to build with /codecube newplace"
})

local granted_key = "cc_commands:newplace_granted"

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    if meta:get_int(granted_key) == 1 then return end
    local name = player:get_player_name()
    local privs = minetest.get_player_privs(name)
    privs.newplace = true
    minetest.set_player_privs(name, privs)
    meta:set_int(granted_key, 1)
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

        local min, max = minetest.get_mapgen_edges()
        local margin = math.min(500, math.floor((max.x - min.x) / 10))
        local ground = tonumber(
                           minetest.get_mapgen_setting("mgflat_ground_level")) or
                           128
        player:set_pos({
            x = math.random(min.x + margin, max.x - margin),
            y = ground + 1,
            z = math.random(min.z + margin, max.z - margin)
        })
        last_newplace[caller] = now
        return true, "Moved to a fresh place."
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
