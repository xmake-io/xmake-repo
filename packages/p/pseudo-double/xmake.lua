package("pseudo-double")
    set_homepage("https://github.com/royward/pseudo-double")
    set_description("A relatively fast C and C++ 64 bit floating point library written using only integer operations for cross platform consistency. Tested with gcc/clang/Visual Studio, on x86-64/ARMv8 (64 bit)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/royward/pseudo-double.git")

    add_versions("2024.01.17", "275b244eee40b987a209927d7942d4bf83d91c95")

    add_patches("2024.01.17", path.join(os.scriptdir(), "patches", "2024.01.17", "fix_build.patch"), "47d9e5b354311ec8004ea8281f18ecdd1641bfbf8668e71c046724c80d95d6f1")

    add_configs("pseudo_double_exp_bits", {description = "This sets the number of bits in the exponent, defaulting to 16 if not set.", default = "16", type = "string", values = {"8", "16", "32"}})
    add_configs("pd_error_check", {description = "This enables error checking in the library, defaulting to true if not set.", default = true, type = "boolean"})

    on_install("windows|x64", "linux|x86_64", "bsd", "android|arm64*", "cross", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("pseudo-double")
                set_kind("$(kind)")
                set_languages("c++11")

                if is_plat("windows") then
                    add_defines("_MSC_VER")
                end

                add_files("pseudo_double.c", "pseudo_double.cpp")
                add_headerfiles("(pseudo_double.h)", "(PseudoDouble.h)")
                
                on_config(function (target)
                    if target:has_tool("gcc", "gxx") then
                        target:add("defines", "__GNUC__")
                    elseif target:has_tool("cc", "cxx", "clang", "clangxx") then
                        target:add("defines", "__clang__")
                    end
                end)
        ]])
        package:add("defines", "PSEUDO_DOUBLE_EXP_BITS=" .. package:config("pseudo_double_exp_bits"))
        package:add("defines", "PD_ERROR_CHECK=" .. (package:config("pd_error_check") and "1" or "0"))
        import("package.tools.xmake").install(package)
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
