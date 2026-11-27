package("beman-transform-view")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bemanproject/transform_view")
    set_description("An updated version of std::ranges::transform_view that enables conditional borrowability")
    set_license("Apache-2.0 WITH LLVM-exception")

    add_urls("https://github.com/bemanproject/transform_view/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/bemanproject/transform_view.git")
    add_versions("0.2.2", "e84b3c6b863ae4f1ddbf36300a2ae0b9efcaacc20884dca049f8a5e2f42fef40")

    -- android is not listed: the header misses an <type_traits> include, which ndk libc++ does not provide transitively
    on_install("linux", "macosx", "windows", "mingw", "msys", function (package)
        os.cp("include/beman/transform_view/*.hpp", package:installdir("include/beman/transform_view"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <beman/transform_view/transform_view.hpp>
            #include <string>
            void test() {
                const std::string s = "abc";
                auto v = s | beman::transform_view::views::transform([](char c) { return char(c - 32); });
                (void)v.front();
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
