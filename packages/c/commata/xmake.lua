package("commata")
    set_kind("library", {headeronly = true})
    set_homepage("https://furfurylic.github.io/commata/CommataSpecification.xml")
    set_description("Just another header-only C++17 CSV parser")
    set_license("Unlicense")

    add_urls("https://github.com/furfurylic/commata/archive/refs/tags/$(version)-rc.2.zip",
             "https://github.com/furfurylic/commata.git")
    add_versions("v1.0.1", "4aec67cd6254baf1183e8a0faae691a7e0be21e888958cdc682237579804ea3d")
    add_versions("v1.0.0", "5f9ef542d10d5d04d296e609ae8931e09a157761c86630d71b2f397c6a205a75")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using commata::stored_table;
            void test() {
                stored_table table;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "commata/stored_table.hpp"}))
    end)
