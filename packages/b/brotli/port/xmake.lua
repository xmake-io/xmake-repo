add_rules("mode.debug", "mode.release")

option("vers")
    set_default("")
    set_showmenu(true)
option_end()

if has_config("vers") then
    set_version(get_config("vers"))
end

target("brotlienc")
    set_kind("$(kind)")
    add_deps("brotlicommon")
    local links = {"brotlienc"}
    if is_kind("static") then
        table.insert(links, "brotlicommon")
    end
    add_rules("utils.install.pkgconfig_importfiles", {filename = "libbrotlienc.pc", links = links})
    add_includedirs("c/include", {public = true})
    add_files("c/enc/*.c")
    if is_kind("shared") and is_plat("windows") then
        add_defines("BROTLI_SHARED_COMPILATION", "BROTLIENC_SHARED_COMPILATION")
    end
    add_headerfiles("c/include/(brotli/*.h)")

target("brotlidec")
    set_kind("$(kind)")
    add_deps("brotlicommon")
    local links = {"brotlidec"}
    if is_kind("static") then
        table.insert(links, "brotlicommon")
    end
    add_rules("utils.install.pkgconfig_importfiles", {filename = "libbrotlidec.pc", links = links})
    add_includedirs("c/include", {public = true})
    add_files("c/dec/*.c")
    if is_kind("shared") and is_plat("windows") then
        add_defines("BROTLI_SHARED_COMPILATION", "BROTLIDEC_SHARED_COMPILATION")
    end
    add_headerfiles("c/include/(brotli/*.h)")

target("brotlicommon")
    set_kind("$(kind)")
    add_rules("utils.install.pkgconfig_importfiles", {filename = "libbrotlicommon.pc"})
    add_includedirs("c/include", {public = true})
    add_files("c/common/*.c")
    if is_kind("shared") and is_plat("windows") then
        add_defines("BROTLI_SHARED_COMPILATION", "BROTLICOMMON_SHARED_COMPILATION")
    end
    add_headerfiles("c/include/(brotli/*.h)")

target("brotli")
    set_kind("binary")
    add_files("c/tools/brotli.c")
    add_deps("brotlicommon", "brotlidec", "brotlienc")
