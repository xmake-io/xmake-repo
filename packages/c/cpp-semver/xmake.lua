package("cpp-semver")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/z4kn4fein/cpp-semver")
    set_description("Semantic Versioning library for modern C++.")
    set_license("MIT")

    add_urls("https://github.com/z4kn4fein/cpp-semver/archive/refs/tags/$(version).tar.gz",
             "https://github.com/z4kn4fein/cpp-semver.git")

    add_versions("v0.3.1", "9168cc815d8b9a5b3d73d2a158efec467eff844f1cab929bc145312cfc3958ae")

    on_install(function (package)
        io.replace("include/semver/semver.hpp", "#include <vector>", "#include <vector>\n#include <cstdint>", {plain = true})
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <semver/semver.hpp>
            void test() {
                auto v1 = semver::version(3, 5, 2, "alpha", "build");
                auto v2 = semver::version::parse("3.5.2-alpha+build");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
