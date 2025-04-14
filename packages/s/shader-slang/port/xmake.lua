add_rules("mode.debug", "mode.release", "mode.releasedbg")

option("slang_version", {description = "Slang version", type = "string"})

-- Global Compiler Options --
add_cxxflags(
    "-Wno-assume",
    "-Wno-switch",
    "-Wno-constant-logical-operand",
    "-Wno-invalid-offsetof",
    "-Wno-dangling-else",
    "-fms-extensions",
    { force = true, tools = { "clang", "gcc", "clang_cl" } }
)

set_encodings("utf-8")

set_project("slang")
if has_config("slang_version") then
    local version = get_config("slang_version")
    set_version(version)
    set_configvar("SLANG_VERSION_FULL", version)
end

includes("slang_target.lua")
includes("tools")
includes("source")
includes("prelude")
