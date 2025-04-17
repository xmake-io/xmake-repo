package("reaction")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lumia431/reaction")
    set_description("A lightweight, header-only reactive programming framework leveraging modern C++20 features for building efficient dataflow applications.")
    set_license("MIT")

    add_urls("https://github.com/lumia431/reaction.git")
    add_versions("2025.04.16", "424f1956f2215b0817fd1b3b4217ee04b0c45e2a")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "if(GTest_FOUND)", "if(0)", {plain = true})
        os.tryrm("example")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <algorithm>
            #include <reaction/reaction.h>
            void test() {
                auto buyPrice = reaction::var(100.0);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
