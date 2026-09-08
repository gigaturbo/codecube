-- Luacheck configuration for the Codecube game.
--
--   luacheck .
--
-- Scope: the game's own mods only, which is cc_day, cc_mapgen and cc_security.
--
-- The codeblock mod is developed in its own repository, ships as its own
-- ContentDB package, and carries its own .luacheckrc, test suite and CI. It is
-- excluded here on purpose: this repository checks that the game *assembles*
-- (see scripts/check_game.sh), not that its dependencies are internally clean.
-- Duplicating codeblock's lint here would report the same findings twice and
-- make this repository's build status depend on a submodule bump.
--
-- vector3 is a submodule with its own upstream and is not ours to lint. The
-- default, dye and wool excludes went with those mods under A13.

std = "lua51"
cache = true
codes = true

-- Formatting is handled by the existing lua-format style; don't fight it.
max_line_length = false

-- Engine callbacks have signatures fixed by Luanti and must declare every
-- parameter whether the body uses it or not. Unused *locals* are still reported.
unused_args = false

read_globals = {
    -- Luanti / Minetest engine
    "core", "minetest", "dump", "dump2", "vector", "ItemStack", "VoxelManip",
    "VoxelArea", "PseudoRandom", "PcgRandom", "PerlinNoise", "PerlinNoiseMap",
    "ValueNoise", "ValueNoiseMap", "SecureRandom", "Settings", "AreaStore",
    "Raycast", "ItemStackMetaRef", "DEFAULT_ALLOW_MOVE", "INIT",
    -- published by mods this game ships
    "codeblock", "vector3"
}

exclude_files = {
    -- has its own repository, config, tests and CI
    "mods/codeblock/**",
    -- submodule with its own upstream
    "mods/vector3/**",
    -- toolchain, not source: gh-actions-luarocks installs into the workspace
    ".luarocks/**",
    ".install/**",
    ".lua/**"
}

files["mods/cc_security/**"] = {
    -- 122: assigning to a field of the `minetest` global. Replacing
    -- handle_node_drops and calculate_knockback is the whole point of those two
    -- lines, so the code stays and the check is off for this file. What luacheck
    -- was really pointing at -- that the replacement is discarded by whatever
    -- loads next -- is fixed instead by `last_mod = cc_security` in game.conf,
    -- and the drop handler now chains the value it captured. (A8)
    ignore = {"122"}
}
