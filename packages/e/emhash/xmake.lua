package("emhash")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ktprime/emhash")
    set_description("Fast and memory efficient c++ flat hash map/set")
    set_license("MIT")

    add_urls("https://github.com/ktprime/emhash.git")
    add_versions("2024.06.01", "3efa77ef32786a033b379071fe8af3dc705736ca")

    on_install(function (package)
        os.cp("*.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                emhash5::HashMap<int, int> m1(4);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "hash_table5.hpp"}))
    end)
