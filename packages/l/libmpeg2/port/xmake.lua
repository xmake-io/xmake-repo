option("tools", {default = false})

add_rules("mode.debug", "mode.release")

add_includedirs("include")
if is_plat("windows", "mingw") or is_host("windows") then
    add_includedirs("vc++")
end

if is_plat("windows") and has_config("tools") then
    add_requires("strings_h")
end

if is_arch("arm.*") then
    add_requires("nasm")
end

if is_plat("macosx") or (is_host("macosx") and is_plat("mingw")) then
    -- Fixes duplicate symbols
    set_languages("gnu89")
end

rule("tools")
    on_load(function (target)
        if not get_config("tools") then
            target:set("enabled", false)
            return
        end

        target:add("kind", "binary")
        target:add("files", "src/getopt.c")
        target:add("includedirs", "src")
        target:add("deps", "mpeg2")
        if target:is_plat("windows") then
            target:add("packages", "strings_h")
        end
    end)

target("mpeg2")
    set_kind("shared")
    add_files("libmpeg2/**.c", "libvo/*.c")
    add_headerfiles("include/mpeg2.h", "include/mpeg2convert.h", {prefixdir = "mpeg2dec"})

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32")
    end

    if is_arch("arm.*") then
        set_toolchains("nasm")
        add_files("libmpeg2/motion_comp_arm_s.S")
    end

    if is_kind("shared") then
        if is_plat("mingw") then
            add_shflags("-Wl,--output-def,mpeg2.def")
        elseif is_plat("windows") then
            add_rules("utils.symbols.export_all")
        end
    end

target("corrupt_mpeg2")
    add_rules("tools")
    add_files("src/corrupt_mpeg2.c")

target("extract_mpeg2")
    add_rules("tools")
    add_files("src/extract_mpeg2.c")

target("mpeg2dec")
    add_rules("tools")
    add_files("src/mpeg2dec.c", "src/dump_state.c", "src/gettimeofday.c")
