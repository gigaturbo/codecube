-- The look of every panel and of the hotbar. Per-player and re-applied on every
-- join, because the engine offers no server-wide default for either. (B57)
--
-- A prepend is added to every formspec shown to the player, including
-- codeblock's editor, unless that form carries no_prepend[]. Nothing in this
-- package does, and that is the point: one style, set once, rather than a
-- styling line repeated in every form. A server owner who wants a different
-- look sets a prepend of their own from their own mod, which runs after this one
-- and replaces it; there is deliberately no setting here.
--
-- No colour below is invented. The panel, its lit ring and the hotbar strip are
-- the three tones of cc_mapgen_bedrock.png, every outer border is the barrier's
-- near-black, and the hotbar's selection frame is the grass -- the one
-- saturated colour in the interface, and the colour of the ground the bar sits
-- over.
--
-- bgcolor[] takes two parameters here and must not take three. A prepend is
-- parsed with the *target* form's formspec version, not with one of its own, and
-- a form that declares no version is version 1, where the third parameter is
-- rejected outright with a line to errorstream (guiFormSpecMenu.cpp,
-- parseBackgroundColor). codeblock's forms declare version 4; a node's form from
-- someone else's mod need not.
local style =
    -- Drawn behind the panel, and what is left if the texture ever fails to
    -- load, so a missing file costs the tint and not legibility.
    "bgcolor[#1c1c20c0;false]" ..
    -- Inventory slots, their border, and -- the last two -- the default tooltip
    -- colours, which are otherwise the engine's olive green against this grey.
    -- Four arguments would be an invalid combination and drop the whole
    -- element; this form takes five.
    "listcolors[#181820a0;#3c3c44;#101010;#1c1c20f0;#e6e8ec]" ..
    -- Nine-sliced on an 8 px border and auto-clipped to the form, where the
    -- leading 5,5 is a pixel bleed beyond its edge rather than a position. The
    -- ring border survives the stretch; see scripts/gen_textures.py for why
    -- nothing else in the tile could.
    "background9[5,5;1,1;cc_gui_formbg.png;true;8]"

minetest.register_on_joinplayer(function(player)
    -- cc_security blanks the inventory formspec, and this does not fight it: an
    -- empty inventory form means the client opens no menu at all (game.cpp,
    -- Game::openInventory returns early on an empty form), so there is nothing
    -- for the prepend to be added to.
    player:set_formspec_prepend(style)
    -- The bar image is stretched over the whole hotbar, whose width follows the
    -- item count, so it carries no per-slot detail that would land at the wrong
    -- scale. Setting it also switches off the engine's own backdrop behind each
    -- item, so this texture's alpha is what keeps an icon readable.
    player:hud_set_hotbar_image("cc_gui_hotbar.png")
    player:hud_set_hotbar_selected_image("cc_gui_hotbar_selected.png")
end)
