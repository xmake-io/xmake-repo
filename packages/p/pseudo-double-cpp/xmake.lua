package("pseudo-double-cpp")
    set_homepage("https://github.com/royward/pseudo-double")
    set_description("A relatively fast C and C++ 64 bit floating point library written using only integer operations for cross platform consistency. Tested with gcc/clang/Visual Studio, on x86-64/ARMv8 (64 bit)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/royward/pseudo-double.git")

    add_versions("2024.01.17", "275b244eee40b987a209927d7942d4bf83d91c95")

    add_configs("pseudo_double_exp_bits", {description = "This sets the number of bits in the exponent, defaulting to 16 if not set.", default = "16", type = "string", values = {"8", "16", "32"}})
    add_configs("pd_error_check", {description = "This enables error checking in the library, defaulting to true if not set.", default = true, type = "boolean"})

    on_load(function (package)
        package:add("deps", "pseudo-double-c", {configs = {shared = package:config("shared"), pseudo_double_exp_bits = package:config("pseudo_double_exp_bits"), pd_error_check = package:config("pd_error_check")}})
    end)

    on_install("windows|x64", "linux|x86_64", "bsd", "android|arm64*", function (package)
        local configs = {}
        io.replace("PseudoDouble.h", "#include <stdexcept>", "#include <stdexcept>\n#include <string>", {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("pseudo-double-c")
            target("pseudo-double-cpp")
                set_kind("$(kind)")
                set_languages("c++11")
                add_packages("pseudo-double-c")

                if is_plat("windows") then
                    add_defines("_MSC_VER")
                end

                add_files("pseudo_double.cpp")
                add_headerfiles("(PseudoDouble.h)")
                
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
            #include <PseudoDouble.h>
            void test() {
                PseudoDouble a_2 = PD_create_fixed10(3,-1);
            }
        ]]}))
    end)
