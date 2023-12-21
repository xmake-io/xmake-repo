package("tl_expected")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/TartanLlama/expected")
    set_description("C++11/14/17 std::expected with functional-style extensions")
    set_license("CC0")

    set_urls("https://github.com/TartanLlama/expected/archive/$(version).zip",
             "https://github.com/TartanLlama/expected.git")

    add_versions("v1.0.0", "c1733556cbd3b532a02b68e2fbc2091b5bc2cccc279e4f6c6bd83877aabd4b02")
    add_versions("v1.1.0", "4b2a347cf5450e99f7624247f7d78f86f3adb5e6acd33ce307094e9507615b78")

    on_install(function (package)
        os.cp("include/tl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tl::expected<int, int> e1 = 42;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"tl/expected.hpp"}}))
    end)

