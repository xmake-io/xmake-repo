package("cpp-semver-easz")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/easz/cpp-semver")
    set_description("cpp-semver - Semantic Versioning in C++ header-only C++11")
    set_license("MIT")

    add_urls("https://github.com/easz/cpp-semver.git", {submodules = false})
    add_versions("2021.12.10", "7b9141d99044e4d363eb3b0a81cfb1546a33f9dd")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <cpp-semver.hpp>
            void test() {
                const std::string ver1 = "1.0.0 || 1.5 - 3.0";
                const std::string ver2 = ">1.1 <2.0";
                const bool intersected = semver::intersects(ver1, ver2);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
