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

-- Baseline exemptions, disabled when LUACHECK_STRICT is set so CI can report
-- what they hide without the build depending on it. Everything NOT listed here
-- is a hard failure, so new classes of defect still break the build.
ignore = os.getenv("LUACHECK_STRICT") and {} or {
    -- 412: "shadowing argument". The codebase's normalisation idiom is
    --   local n = (type(n) == 'number') and round0(n) or 1
    -- which deliberately shadows the parameter to coerce it in place. There are
    -- 36 of these, 34 in lib/commands.lua alone. Consolidating them is audit
    -- finding A3 (movement/placement de-duplication); until then, flagging every
    -- one drowns out real findings.
    "412",
    -- 411/421/431: the same shadowing pattern applied to locals and upvalues,
    -- from the same idiom. Revisit together with 412 under A3.
    "411", "421", "431",
    -- 213: unused loop variable, e.g.
    --   for i, filename in ipairs(meta.tabs) do meta.active = i end
    -- in lib/formspecs.lua, which is a convoluted way to write #meta.tabs and is
    -- already called out under audit finding A1's editor rewrite.
    "213"
}

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
    -- vendored upstream mods
    "mods/default/**",
    "mods/dye/**",
    "mods/wool/**",
    "mods/worldedit/**",
    "mods/formspecs/**",
    "mods/vector3/**",
    -- Toolchain, not source. gh-actions-luarocks installs into .luarocks/
    -- inside the workspace, and luacheck would otherwise lint luafilesystem's
    -- own test suite and luarocks' generated config.
    ".luarocks/**",
    ".install/**",
    ".lua/**"
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
        "acos", "tan", "tanh", "atan", "atan2", "pi", "e",
        -- Examples pass a bare `_` to mean "use the default for this argument".
        -- It is never assigned, so it reads as nil by design.
        "_"
    }
}

files["mods/codeblock/lib/examples/**"] = {
    std = "codeblock_sandbox",
    -- Player code runs under setfenv with its own environment table, so a
    -- top-level `function foo()` is a normal, working way to declare a helper -
    -- it just lands in the sandbox env rather than the real _G. Eight examples
    -- do this (menger, forest, recursion, plot2D, ...), often recursively.
    allow_defined_top = true,
    -- Player programs legitimately use short throwaway names.
    ignore = {"212", "213"}
}
