add_rules("mode.debug", "mode.release")

option("zlib", {type = "boolean", default = false})
option("zstd", {type = "boolean", default = false})
option("xz",   {type = "boolean", default = false})
option("ver",  {type = "number"})

if has_config("zlib") then
    add_requires("zlib")
    add_packages("zlib")
    add_defines("ENABLE_ZLIB")
end
if has_config("zstd") then
    add_requires("zstd")
    add_packages("zstd")
    add_defines("ENABLE_ZSTD")
end
if has_config("xz") then
    add_requires("xz")
    add_packages("xz")
    add_defines("ENABLE_XZ")
end

add_defines("ENABLE_DEBUG=" .. (is_mode("debug") and "1" or "0"))

-- if is_config("ver", 34) then
--     add_defines("ENABLE_ELFDBG=" .. (is_mode("debug") and "1" or "0"))
-- end

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

    if not has_config("zlib") then
        remove_files("libkmod/libkmod-file-zlib.c")
    end
    if not has_config("zstd") then
        remove_files("libkmod/libkmod-file-zstd.c")
    end
    if not has_config("xz") then
        remove_files("libkmod/libkmod-file-xz.c")
    end

    on_config(function(target)
        if target:has_cfuncs("basename", {includes = "string.h"}) then
            target:add("defines", "HAVE_DECL_BASENAME")
        end
    end)
