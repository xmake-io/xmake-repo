package("effolkronium-random")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/effolkronium/random")
    set_description("Random for modern C++ with convenient API")
    set_license("MIT")

    add_urls("https://github.com/effolkronium/random/archive/refs/tags/$(version).tar.gz",
             "https://github.com/effolkronium/random.git")
    add_versions("v1.4.1", "ec6beb67496ad2ce722d311d3fa5efb7e847dac5fd1c16b8920b51562fe20f53")

    on_install(function (package)
        os.cp("include/effolkronium", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                auto num = effolkronium::random_static::get(-1, 1);
                bool overflow = (num < -1) || (num > 1);
                assert(!overflow);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"effolkronium/random.hpp", "assert.h"}}))
    end)
