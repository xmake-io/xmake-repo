package("pseudo-double")
    set_homepage("https://github.com/royward/pseudo-double")
    set_description("A relatively fast C and C++ 64 bit floating point library written using only integer operations for cross platform consistency. Tested with gcc/clang/Visual Studio, on x86-64/ARMv8 (64 bit)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/royward/pseudo-double.git")
    add_versions("2024.01.17", "275b244eee40b987a209927d7942d4bf83d91c95")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("pseudo-double")
                set_kind("$(kind)")
                set_languages("c99", "cxx11")
                add_files("pseudo_double.c", "pseudo_double.cpp")
                add_headerfiles("(pseudo_double.h)", "(PseudoDouble.h)")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pseudo_double.h>
            #include <PseudoDouble.h>
            void test() {
                pseudo_double a_1 = int64fixed10_to_pd(3, -1);
                PseudoDouble a_2 = PD_create_fixed10(3,-1);
            }
        ]]}))
    end)
