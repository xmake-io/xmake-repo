package("beman-utf-view")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bemanproject/utf_view")
    set_description("UTF transcoding views (P2728): to_utf8, to_utf16, to_utf32, null_term and the charN_t casts")
    set_license("BSL-1.0")

    add_urls("https://github.com/bemanproject/utf_view/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/bemanproject/utf_view.git")
    add_versions("0.3.0", "30271d95952dddce5fd711732faba32670a485bdecb0f9906100960b1c2b6c0b")

    add_deps("beman-transform-view")

    on_install("linux", "windows", "mingw", "msys", function (package)
        os.cp("include/beman/utf_view/*.hpp", package:installdir("include/beman/utf_view"))
        os.cp("include/beman/utf_view/detail/*.hpp", package:installdir("include/beman/utf_view/detail"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <beman/utf_view/utf_view.hpp>
            #include <ranges>
            #include <string>
            #include <string_view>
            void test() {
                std::u8string_view in = u8"hi";
                std::u32string out = in | beman::utf_view::to_utf32 | std::ranges::to<std::u32string>();
                (void)out;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
