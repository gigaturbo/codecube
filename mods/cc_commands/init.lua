-- The game's own chat commands, all under `/codecube <subcommand>`, the way
-- codeblock keeps its own under `/codeblock`. One table of subcommands, each
-- carrying its own usage line and checking its own privileges, so a panel can
-- later offer the same handlers without a second copy of them.
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
    run = function(caller, param)
        if not minetest.check_player_privs(caller, {server = true}) then
            return false, "You need the server privilege to set a speed."
        end
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

-- Built from the table once, so the help cannot drift from the subcommands.
local forms = {}
for name, sub in pairs(subcommands) do
    forms[#forms + 1] = name .. " " .. sub.params
end
table.sort(forms)
local usage = "Usage: /codecube " .. table.concat(forms, "\nUsage: /codecube ")

-- No command-level privs: each subcommand asks for what it needs. A handler
-- returns false with no message for a malformed argument, and gets the usage.
minetest.register_chatcommand("codecube", {
    params = table.concat(forms, " | "),
    description = "The game's own commands",
    func = function(caller, param)
        local name, rest = param:match("^%s*(%S+)%s*(.-)%s*$")
        local sub = name and subcommands[name]
        if not sub then return false, usage end
        local ok, message = sub.run(caller, rest)
        return ok, message or usage
    end
})
