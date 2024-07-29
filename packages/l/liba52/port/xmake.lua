option("tools", {default = false})

add_rules("mode.debug", "mode.release")

add_includedirs("include")
if is_plat("windows", "mingw") and (not is_subhost("msys")) then
    add_includedirs("vc++")
end

if is_plat("windows") and has_config("tools") then
    add_requires("strings_h")
end

if is_plat("macosx", "iphoneos") then
    -- Fixes duplicate symbols errors on arm64
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
        target:add("deps", "a52")
        if target:is_plat("windows") then
            target:add("packages", "strings_h")
        end
    end)

target("a52")
    set_kind("$(kind)")
    add_files("liba52/*.c", "libao/*.c")
    add_headerfiles(
        "include/a52.h",
        "include/attributes.h",
        "include/audio_out.h",
        "include/mm_accel.h",
        "liba52/a52_internal.h", {prefixdir = "a52dec"}
    )

    if is_plat("windows", "mingw") then
        add_syslinks("winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

target("a52dec")
    add_rules("tools")
    add_files("src/a52dec.c", "src/gettimeofday.c")

target("extract_a52")
    add_rules("tools")
    add_files("src/extract_a52.c")
