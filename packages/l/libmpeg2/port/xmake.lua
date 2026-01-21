option("tools", {default = false})

add_rules("mode.debug", "mode.release")

if is_plat("windows") and has_config("tools") then
    add_requires("strings_h")
end

if is_plat("macosx") or (is_host("macosx") and is_plat("mingw")) then
    -- Fixes duplicate symbols
    set_languages("gnu89")
end

add_includedirs("include")

set_configdir("include")
add_configfiles("config.h.in")

includes("@builtin/check")
configvar_check_cincludes("HAVE_ALTIVEC_H", "altivec.h")
configvar_check_cfuncs("HAVE_BUILTIN_EXPECT", "__builtin_expect")
-- configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cfuncs("HAVE_FTIME", "ftime", {includes = "time.h"})
configvar_check_cfuncs("HAVE_GETTIMEOFDAY", "gettimeofday", {includes = "time.h"})
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_IO_H", "io.h")
configvar_check_cfuncs("HAVE_MEMALIGN", "memalign", {includes = "stdlib.h"})
-- configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
-- configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
-- configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
-- configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_STRUCT_TIMEVAL", ".h")
-- configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TIMEB_H", "sys/timeb.h")
configvar_check_cincludes("HAVE_SYS_TIME_H", "sys/time.h")
-- configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_TIME_H", "time.h")
-- configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")

if is_plat("windows") then
    set_configvar("LIBVO_DX", "1")
end

if is_plat("linux", "macosx", "bsd") then
    set_configvar("LIBVO_X11", "1")
    add_requires("libxext")
    add_packages("libxext")
end

target("mpeg2")
    set_kind("$(kind)")
    add_files("libmpeg2/**.c", "libvo/*.c")

    add_headerfiles("include/mpeg2.h", "include/mpeg2convert.h", {prefixdir = "mpeg2dec"})

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "gdi32")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    on_config(function (target)
        if not target:has_tool("cxx", "cl") and target:is_arch("arm.*") then
            target:add("files", "libmpeg2/motion_comp_arm_s.S")
        end
    end)

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

target("corrupt_mpeg2")
    add_rules("tools")
    add_files("src/corrupt_mpeg2.c")

target("extract_mpeg2")
    add_rules("tools")
    add_files("src/extract_mpeg2.c")

target("mpeg2dec")
    add_rules("tools")
    add_files("src/mpeg2dec.c", "src/dump_state.c", "src/gettimeofday.c")
