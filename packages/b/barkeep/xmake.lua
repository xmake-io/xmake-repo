package("barkeep")
    set_kind("library", {headeronly = true})
    set_homepage("https://oir.github.io/barkeep/")
    set_description("Small C++ header to display async animations, counters, and progress bars")
    set_license("Apache-2.0")

    add_urls("https://github.com/oir/barkeep/archive/refs/tags/$(version).tar.gz",
             "https://github.com/oir/barkeep.git")

    add_versions("v0.1.5", "2577b09cfa7e5e117d13b765cfa4792f9e2b50719715786be275ae32dbf63b7c")
    add_versions("v0.1.4", "2dc1b2cf6f0e0c0de1a0f18a1d31a97bc698ed0cfdf186780daf5a17aa56dfa2")
    add_versions("v0.1.3", "211425e348b570547b49d11edfb6e3750701d97cc89f073771b16d6012530a66")

    add_configs("fmt", {description = "Use fmt format", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("fmt") then
            package:add("deps", "fmt")
            package:add("defines", "BARKEEP_ENABLE_FMT_FORMAT")
        else
            package:add("defines", "BARKEEP_ENABLE_STD_FORMAT")
        end
    end)

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/utf-8")
        end

        os.cp("barkeep", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto anim = barkeep::Animation({.message = "Working"});
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"barkeep/barkeep.h"}}))
    end)
