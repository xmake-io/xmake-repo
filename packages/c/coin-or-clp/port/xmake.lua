includes("@builtin/check")
configvar_check_cincludes("COINUTILS_HAS_CSTDINT", "cstdint")
configvar_check_cincludes("COINUTILS_HAS_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_ARM_NEON_H", "arm_neon.h")
configvar_check_cincludes("HAVE_FMAINTRIN_H", "fmaintrin.h")
configvar_check_cincludes("HAVE_IMMINTRIN_H", "immintrin.h")
configvar_check_cincludes("HAVE_INTRIN_H", "intrin.h")
configvar_check_cincludes("HAVE_STDIO_H", "stdio.h")
configvar_check_cincludes("HAVE_CFLOAT", "cfloat")
configvar_check_cincludes("HAVE_CIEEEFP", "cieeefp")
configvar_check_cincludes("HAVE_CINTTYPES", "cinttypes")
configvar_check_cincludes("HAVE_CMATH", "cmath")
configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
configvar_check_cincludes("HAVE_FLOAT_H", "float.h")
configvar_check_cincludes("HAVE_IEEEFP_H", "ieeefp.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_MATH_H", "math.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_READLINE_READLINE_H", "readline/readline.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")
configvar_check_cincludes("STDC_HEADERS", {"stdlib.h", "string.h"})
            
set_configvar("COIN_CLP_CHECKLEVEL", 0)
set_configvar("COIN_CLP_VERBOSITY", 0)

set_configvar("CLP_VERSION", "1.17.10")
set_configvar("CLP_VERSION_MAJOR", 1)
set_configvar("CLP_VERSION_MINOR", 17)
set_configvar("CLP_VERSION_RELEASE", 10)

add_rules("mode.debug", "mode.release")

add_requires("coin-or-coinutils", "coin-or-osi")
if is_plat("linux") then
    add_requires("lapack")
    add_packages("lapack")
    add_defines("LAPACK_TEST")
end

set_languages("c++11")

target("clp")
    set_kind("$(kind)")
    add_defines("HAVE_CONFIG_H", "CLP_BUILD", "COIN_HAS_CLP")
    add_files("Clp/src/*.cpp", "Clp/src/OsiClp/*.cpp")
    remove_files(
     "Clp/src/ClpCholeskyMumps.cpp",
     "Clp/src/ClpCholeskyUfl.cpp",
     "Clp/src/ClpCholeskyWssmp.cpp",
     "Clp/src/ClpCholeskyWssmpKKT.cpp",
     "Clp/src/ClpMain.cpp",
     "Clp/src/*Abc*.cpp"
    )
    add_includedirs("Clp/src")
    add_headerfiles("Clp/src/*.hpp", "Clp/src/*.h", {prefixdir = "coin"})
    add_headerfiles("Clp/src/OsiClp/*.hpp", {prefixdir = "coin"})
    remove_headerfiles(
     "Clp/src/ClpCholeskyMumps.hpp",
     "Clp/src/ClpCholeskyUfl.hpp",
     "Clp/src/ClpCholeskyWssmp.hpp",
     "Clp/src/ClpCholeskyWssmpKKT.hpp",
     "Clp/src/*Abc*.hpp",
     "Clp/src/*Abc*.h"
    )
    set_configdir("Clp/src")
    add_configfiles("Clp/src/(config.h.in)")
    add_configfiles("Clp/src/(config_clp.h.in)")
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
    add_packages("coin-or-coinutils", "coin-or-osi")