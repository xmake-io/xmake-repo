package("tiny-optional")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Sedeniono/tiny-optional")
    set_description("Replacement for std::optional that does not unnecessarily waste memory")
    set_license("BSL-1.0")

    add_urls("https://github.com/Sedeniono/tiny-optional/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Sedeniono/tiny-optional.git")

    add_versions("v1.2.0", "d4ce47d0c9c4f89ab41e4e0b96d25bfb98c0cc02da3d7b312337e5e4e6e1c9e8")

    on_install("*|!arm*", "!wasm", "!cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tiny::optional<double> x;
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"tiny/optional.h"}}))
    end)
