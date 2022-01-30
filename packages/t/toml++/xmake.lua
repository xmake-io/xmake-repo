package("toml++")
    set_kind("library", {headeronly = true})
    set_homepage("https://marzer.github.io/tomlplusplus/")
    set_description("toml++ is a header-only TOML config file parser and serializer for C++17 (and later!).")

    add_urls("https://github.com/marzer/tomlplusplus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/marzer/tomlplusplus.git")
    add_versions("v2.5.0", "2e246ee126cfb7bd68edd7285d5bb5c8c5296121ce809306ee71cfd6127c76a6")
    add_versions("v3.0.0", "934ad62e82ae5ee67bdef512b39d24ddba45e012fb94e22b39fa1fb192bdabab")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <sstream>
            #include <toml++/toml.h>
            using namespace std::string_view_literals;

            static void test() {
                static constexpr std::string_view some_toml = R"(
                    [library]
                    name = "toml++"
                    authors = ["Mark Gillard <mark.gillard@outlook.com.au>"]
                    cpp = 17
                )"sv;

                toml::table tbl = toml::parse(some_toml);
                std::cout << tbl << "\n";
            }
        ]]}, {configs = {languages = "c++17"}, includes = "toml++/toml.h"}))
    end)
