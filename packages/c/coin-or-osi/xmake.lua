package("coin-or-osi")
    set_homepage("https://github.com/coin-or/Osi")
    set_description("Open Solver Interface")

    add_urls("https://github.com/coin-or/Osi/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or/Osi.git")

    add_versions("0.108.11", "1063b6a057e80222e2ede3ef0c73c0c54697e0fee1d913e2bef530310c13a670")

    add_deps("coin-or-coinutils")

    add_includedirs("include", "include/coin")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        os.cd("Osi/src")
        io.gsub("Osi/config.h.in", "# *undef (.-)\n", "${define %1}\n")
        io.writefile("xmake.lua", [[
            includes("@builtin/check")
            configvar_check_cincludes("HAVE_CFLOAT", "cfloat")
            configvar_check_cincludes("HAVE_CIEEEFP", "cieeefp")
            configvar_check_cincludes("HAVE_CMATH", "cmath")
            configvar_check_cincludes("HAVE_DLFCN_H", "dlfcn.h")
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

            check_sizeof("SIZEOF_DOUBLE", "double")
            check_sizeof("SIZEOF_INT", "int")
            check_sizeof("SIZEOF_INT_P", "int *")
            check_sizeof("SIZEOF_LONG", "long")
            check_sizeof("SIZEOF_LONG_LONG", "long long")

            configvar_check_cincludes("STDC_HEADERS", {"stdlib.h", "string.h"})

            set_configvar("COIN_OSI_CHECKLEVEL", 0)
            set_configvar("COIN_OSI_VERBOSITY", 0)
            set_configvar("COIN_HAS_COINUTILS", 1)

            set_configvar("OSI_VERSION", "0.108.11")
            set_configvar("OSI_VERSION_MAJOR", 0)
            set_configvar("OSI_VERSION_MINOR", 108)
            set_configvar("OSI_VERSION_RELEASE", 11)

            add_rules("mode.debug", "mode.release")
            add_requires("coin-or-coinutils")
            set_languages("c++11")

            target("Osi")
                set_kind("$(kind)")
                add_files("Osi/*.cpp")
                add_configfiles("Osi/(config.h.in)", {filename = "config.h"})
                add_headerfiles("Osi/*.hpp", {prefixdir = "coin"})
                add_includedirs("Osi")
                add_packages("coin-or-coinutils")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end

            target("OsiCommonTests")
                set_kind("$(kind)")
                add_files("OsiCommonTest/*.cpp")
                add_headerfiles("OsiCommonTest/*.hpp", {prefixdir = "coin"})
                add_deps("Osi")
                add_includedirs("Osi")
                add_packages("coin-or-coinutils")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cstddef>
            #include <coin/OsiAuxInfo.hpp>
            void test() {
                OsiBabSolver solver = OsiBabSolver(0);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
