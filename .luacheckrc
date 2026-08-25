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
-- default, dye, wool and vector3 are vendored or third-party and are not ours
-- to lint.

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
    "codeblock", "vector3", "default", "dye", "wool"
}

exclude_files = {
    -- has its own repository, config, tests and CI
    "mods/codeblock/**",
    -- vendored or third-party
    "mods/default/**",
    "mods/dye/**",
    "mods/wool/**",
    "mods/vector3/**",
    -- toolchain, not source: gh-actions-luarocks installs into the workspace
    ".luarocks/**",
    ".install/**",
    ".lua/**"
}

files["mods/cc_security/**"] = {
    -- 122: assigning to a field of the `minetest` global. This mod does
    --   function minetest.handle_node_drops() end
    --   function minetest.calculate_knockback() return 0 end
    -- which clobbers any other mod's override and gets clobbered in turn.
    -- luacheck is right, and this is recorded as audit finding A8; fixing it
    -- means capturing and chaining the previous value, which is a behaviour
    -- change and belongs with that work, not with lint setup.
    ignore = {"122"}
}
