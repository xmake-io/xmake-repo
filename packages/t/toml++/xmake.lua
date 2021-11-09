package("toml++")

    set_homepage("https://marzer.github.io/tomlplusplus/")
    set_description("toml++ is a header-only TOML config file parser and serializer for C++17 (and later!).")

    set_urls("https://github.com/marzer/tomlplusplus/archive/refs/tags/v$(version).zip")
    add_versions("2.5.0", "887dfb7025d532a3485e1269ce5102d9e628ddce8dd055af1020c7b10ee14248")

    on_load(function (package)
        package:add("deps", "cmake")
    end)

    on_install(function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
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