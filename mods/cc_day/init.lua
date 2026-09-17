-- Permanent noon: the light level pinned, the sky one unmoving colour, and no
-- sky objects. Per-player and re-applied on every join, so nothing has to be
-- undone.
--
-- This is the only place in the package that sets the sky, and it must stay so.
-- A second copy anywhere would have to carry set_sun's sunrise_visible below to
-- match, and the obvious spelling leaves it out, which is B47 back on screen.
-- Move this file if the sky ever belongs elsewhere; never add a second copy.
-- (A7)
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
