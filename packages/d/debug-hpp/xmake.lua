package("debug-hpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/archibate/debug-hpp")
    set_description("printing everything including STL containers without pain")
    set_license("Unlicense")

    add_urls("https://github.com/archibate/debug-hpp.git")
    add_versions("2024.09.06", "ec10419581bc49e7368a853d7c0b607ac663f05c")

    on_install(function (package)
        os.cp("debug.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <debug.hpp>

            void test() {
                debug(), "hello world";
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
