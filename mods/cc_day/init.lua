minetest.register_on_joinplayer(function(player)
    player:override_day_night_ratio(1)
    player:set_stars({visible = false})
    player:set_sun({visible = false})
    player:set_moon({visible = false})
    player:set_clouds({density = 0})
end)