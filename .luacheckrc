-- Luacheck configuration for Codecube.
--
--   luacheck .
--
-- Only first-party code is checked. The vendored mods (default, dye, wool,
-- worldedit, formspecs, vector3) are upstream copies and are excluded, so a
-- clean run means *our* code is clean.

std = "lua51"
cache = true
codes = true

-- Formatting is handled by the existing lua-format style; don't fight it.
max_line_length = false

-- The engine namespace and the globals our dependencies publish.
read_globals = {
    -- Luanti / Minetest engine
    "core", "minetest", "dump", "dump2", "vector", "ItemStack", "VoxelManip",
    "VoxelArea", "PseudoRandom", "PcgRandom", "PerlinNoise", "PerlinNoiseMap",
    "ValueNoise", "ValueNoiseMap", "SecureRandom", "Settings", "AreaStore",
    "Raycast", "ItemStackMetaRef", "DEFAULT_ALLOW_MOVE", "INIT",
    -- dependencies
    "worldedit", "vector3", "default", "dye", "wool",
    -- Lua 5.1 / LuaJIT builtins that luacheck's lua51 std can miss
    "jit"
}

-- Our own mod namespace is written across many files by design.
globals = {"codeblock"}

exclude_files = {
    "mods/default/**",
    "mods/dye/**",
    "mods/wool/**",
    "mods/worldedit/**",
    "mods/formspecs/**",
    "mods/vector3/**"
}

files["mods/codeblock/tests/**"] = {
    -- The spec is written to run standalone too, so it touches arg/io/os.
    read_globals = {"arg"}
}

-- The shipped example programs are *player* code: they run inside the sandbox
-- environment built by lib/sandbox.lua, not in a Luanti mod environment. Given
-- their own std, luacheck will catch typo'd API names and stray globals in the
-- examples - which is exactly the drift described in audit finding A2.
--
-- Keep this list in sync with getScriptEnv() in lib/sandbox.lua.
stds.codeblock_sandbox = {
    read_globals = {
        -- movement
        "move", "forward", "back", "left", "right", "up", "down",
        "turn_left", "turn_right", "turn",
        -- placement
        "place", "place_relative",
        "cube", "sphere", "dome", "cylinder",
        vertical = {fields = {"cylinder"}},
        horizontal = {fields = {"cylinder"}},
        centered = {
            fields = {
                "cube", "sphere", "dome", "cylinder",
                vertical = {fields = {"cylinder"}},
                horizontal = {fields = {"cylinder"}}
            }
        },
        -- checkpoints
        "save", "go",
        -- blocks
        "blocks", "plants", "wools", "iwools",
        -- utilities
        "get_block", "print", "color", "ipairs", "pairs", "random", "table",
        "vector", "error",
        -- math
        "floor", "ceil", "round", "round0", "deg", "rad", "exp", "log", "max",
        "min", "pow", "sqrt", "abs", "sin", "sinh", "asin", "cos", "cosh",
        "acos", "tan", "tanh", "atan", "atan2", "pi", "e"
    }
}

files["mods/codeblock/lib/examples/**"] = {
    std = "codeblock_sandbox",
    -- Player programs legitimately use short throwaway names.
    ignore = {"212", "213"}
}
