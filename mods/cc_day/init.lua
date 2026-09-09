-- Permanent noon: the light level pinned, the sky one unmoving colour, and no
-- sky objects. Per-player and re-applied on every join, so nothing has to be
-- undone.
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
    -- The pinned light level does not reach the sky's own colour: the client
    -- mixes a sun/moon tint into the sky and into the fog by up to a half, on a
    -- curve of the time of day alone (sky.cpp, m_horizon_blend), which is the
    -- horizon brightness that still moved between /time 5000 and /time 10000.
    -- A plain sky is the one type immune to it: the client draws no sky mesh at
    -- all and takes base_color for the whole sky and for the fog, with the
    -- directional tint disabled. Flat by consequence, so base_color is the
    -- colour the horizon already had at noon. (A19)
    player:set_sky({type = "plain", base_color = "#90d3f6"})
    -- Belt and braces under a plain sky, which draws none of the four anyway.
    -- Kept so a return to a "regular" sky cannot silently restore them.
    player:set_stars({visible = false})
    -- sunrise_visible is a separate field: hiding the sun leaves the sunrise
    -- texture drawn at dawn and dusk. (B47)
    player:set_sun({visible = false, sunrise_visible = false})
    player:set_moon({visible = false})
    player:set_clouds({density = 0})
end)
