package("pca9685")
    set_homepage("https://github.com/chaoticmachinery/pca9685")
    set_description("PCA9685 C++ Library. Works with SunFounder")
    set_license("LGPL-2.1")

    set_urls("https://github.com/chaoticmachinery/pca9685.git")

    add_versions("2017.12.07", "6f9794d888f77b863884c3eac933b75a07101347")

    on_install("linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("pca9685")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("PCA9685.cpp")
                add_headerfiles("PCA9685.h")
        ]])
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "PCA9685.h"
            void test() {
                PCA9685 pwm;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
