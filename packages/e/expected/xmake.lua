package("expected")

    set_homepage("https://github.com/TartanLlama/expected")
    set_description("C++11/14/17 std::expected with functional-style extensions")
    set_license("CC0")

    set_urls("https://github.com/TartanLlama/expected/archive/$(version).zip",
             "https://github.com/TartanLlama/expected.git")

    add_versions("v1.0.0", "c1733556cbd3b532a02b68e2fbc2091b5bc2cccc279e4f6c6bd83877aabd4b02")

    on_install(function (package)
        os.cp("include/tl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                tl::expected<int, int> e1 = 42;
            }
        ]]}, {configs = {languages = "c++11"}, includes = { "tl/expected.hpp"} }))
    end) 
