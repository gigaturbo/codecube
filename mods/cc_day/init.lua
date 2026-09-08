-- Permanent noon, and no sky objects. Per-player and re-applied on every join,
-- so nothing has to be undone.
--
-- codeblock does the same five calls behind codeblock.config.flat_sky, which is
-- off by default and must stay off: this game does not set
-- codeblock_flat_sky in its minetest.conf, whatever the mod's own roadmap asks
-- for. Turning it on would run both copies, which is what A7 exists to remove,
-- and the mod's copy still lacks the sunrise_visible line below -- so the flag
-- would put the B47 defect back on screen. Delete this file instead if the mod
-- is ever the one to hold the sky.
minetest.register_on_joinplayer(function(player)
    player:override_day_night_ratio(1)
    player:set_stars({visible = false})
    -- sunrise_visible is a separate field: hiding the sun leaves the sunrise
    -- texture drawn at dawn and dusk. (B47)
    player:set_sun({visible = false, sunrise_visible = false})
    player:set_moon({visible = false})
    player:set_clouds({density = 0})
end)
