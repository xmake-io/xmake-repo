package("commata")

    set_kind("library", {headeronly = true})
    set_homepage("https://furfurylic.github.io/commata/CommataSpecification.xml")
    set_description("Just another header-only C++17 CSV parser")

    add_urls("https://github.com/furfurylic/commata.git")
    add_versions("2024.06.18", "43751b633978628b61fb206bb0d17140d6f3ef3f")

    on_install(function (package)
        os.cp("include/commata/*.hpp", package:installdir("include/commata"))
        os.cp("include/commata/detail/*.hpp", package:installdir("include/commata/detail"))
    end)

    on_test(function (package)
        -- assert(package:has_cxxfuncs("read", {includes = "commata/char_input.hpp",configs = {languages = "c++17"}}))
        assert(package:check_cxxsnippets({test = [[
            using commata::stored_table;
            void test() {
                stored_table table;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "commata/stored_table.hpp"}))
    end)
