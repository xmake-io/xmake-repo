includes("@builtin/check")
configvar_check_cincludes("COINUTILS_HAS_CSTDINT", "cstdint")
configvar_check_cincludes("COINUTILS_HAS_STDINT_H", "stdint.h")
-- configvar_check_cincludes("COIN_HAS_BLAS",  "cblas.h")
-- configvar_check_cincludes("COIN_HAS_GLPK", "glpk.h")
-- configvar_check_cincludes("COIN_HAS_LAPACK", "lapacke_utils.h")
configvar_check_cincludes("HAVE_CFLOAT", "cfloat")
configvar_check_cincludes("HAVE_CIEEEFP", "cieeefp")
configvar_check_cincludes("HAVE_CINTTYPES", "cinttypes")
configvar_check_cincludes("HAVE_CMATH", "cmath")
configvar_check_cincludes("HAVE_CSTDINT", "cstdint")
configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_ENDIAN_H", "endian.h")
configvar_check_cincludes("HAVE_FLOAT_H", "float.h")
configvar_check_cincludes("HAVE_IEEEFP_H", "ieeefp.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_MATH_H", "math.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("HAVE_WINDOWS_H", "windows.h")
configvar_check_cincludes("STDC_HEADERS", {"stdlib.h", "string.h"})

set_configvar("COIN_INT64_T", "long long", {quote = false})
set_configvar("COIN_INTPTR_T", "intptr_t", {quote = false})
set_configvar("COIN_UINT64_T", "unsigned long long", {quote = false})

add_rules("mode.debug", "mode.release")

add_requires("bzip2", "zlib")
if is_plat("linux", "macosx", "bsd") then
    add_requires("readline")
    add_packages("readline")
end

set_languages("c++11")

target("CoinUtils")
    set_kind("$(kind)")
    add_defines("HAVE_CONFIG_H", "COINUTILS_BUILD")
    add_files("CoinUtils/src/*.cpp")
    add_headerfiles("CoinUtils/src/*.hpp", "CoinUtils/src/*.h", {prefixdir = "coin"})
    set_configdir("CoinUtils/src")
    add_configfiles("CoinUtils/src/(config.h.in)")
    add_configfiles("CoinUtils/src/(config_coinutils.h.in)")
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
    add_packages("bzip2", "zlib")
    if is_plat("macosx", "iphoneos") then
        add_frameworks("Accelerate")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end
