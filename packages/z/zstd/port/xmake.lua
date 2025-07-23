option("ver", {default = "v1.5.6"})

local version = get_config("ver")
if version then
    set_version(version)
end

add_rules("mode.debug", "mode.release", "asm")

add_rules("utils.install.pkgconfig_importfiles", {filename = "libzstd.pc"})

target("zstd")
    set_kind("$(kind)")
    add_files("lib/common/*.c")
    add_files("lib/compress/*.c")
    add_files("lib/decompress/*.c")
    add_files("lib/dictBuilder/*.c")
    add_headerfiles("lib/*.h")
    add_defines("XXH_NAMESPACE=ZSTD_")

    if is_kind("shared") and is_plat("windows") then
        add_defines("ZSTD_DLL_EXPORT=1")
    end

    on_config(function (target)
        if target:is_arch("x64", "x86_64") and target:has_tool("cc", "clang", "gcc") then
            target:add("files", "lib/decompress/*.S")
        else
            target:add("defines", "ZSTD_DISABLE_ASM")
        end
    end)
