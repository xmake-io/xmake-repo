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
-- set_configvar("ATTRIBUTE_ALIGNED_MAX", 4)
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

configvar_check_cincludes("LIBA52_DJBFFT", "fftc4.h")
-- set_configvar("LIBA52_DOUBLE", "1")
-- set_configvar("LIBA52_FIXED", "1")
-- set_configvar("LIBAO_AL", "1")
if is_plat("linux") then
    set_configvar("LIBAO_OSS", "1")
end
if is_plat("windows", "mingw", "msys", "cygwin") then
    set_configvar("LIBAO_WIN", 1)
end

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

target("a52dec")
    add_rules("tools")
    add_files("src/a52dec.c", "src/gettimeofday.c")

target("extract_a52")
    add_rules("tools")
    add_files("src/extract_a52.c")
