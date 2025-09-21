add_rules("mode.debug", "mode.release")

option("zlib", {type = "boolean", default = false})
option("zstd", {type = "boolean", default = false})
option("xz",   {type = "boolean", default = false})
option("ver",  {type = "number"})

for _, lib in ipairs({"zlib", "zstd", "xz"}) do
    if has_config(lib) then
        add_requires(lib)
        add_packages(lib)
        add_defines("ENABLE_" .. lib:upper())
    end
end

add_defines("ENABLE_DEBUG=" .. (is_mode("debug") and "1" or "0"))

target("kmod")
    set_kind("$(kind)")
    set_languages("gnu99")
    add_headerfiles("(libkmod/libkmod.h)")
    add_headerfiles("(libkmod/libkmod-index.h)")
    add_includedirs(".")
    add_defines("PATH_MAX=4096")
    add_defines("ANOTHER_BRICK_IN_THE")
    add_defines("SYSCONFDIR=\"/tmp\"")
    add_defines("DISTCONFDIR=\"/lib\"")
    add_defines("MODULE_DIRECTORY=\"/lib/modules\"")
    add_defines("secure_getenv=getenv")
    add_cflags("-include config.h")
    add_files("libkmod/*.c", "shared/*.c")
    add_options("zlib", "zstd", "xz", "ver")

    for _, lib in ipairs({"zlib", "zstd", "xz"}) do
        if not has_config(lib) then
            remove_files("libkmod/libkmod-file-" .. lib .. ".c")
        end
    end

    on_config(function(target)
        if target:has_cfuncs("basename", {includes = "string.h"}) then
            target:add("defines", "HAVE_DECL_BASENAME")
        end
    end)
