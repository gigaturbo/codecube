minetest.register_on_joinplayer(function(player)
    player:override_day_night_ratio(1)
    player:set_stars({visible = false})
    -- sunrise_visible is a separate field: hiding the sun leaves the sunrise
    -- texture drawn at dawn and dusk. (B47)
    player:set_sun({visible = false, sunrise_visible = false})
    player:set_moon({visible = false})
    player:set_clouds({density = 0})
end)