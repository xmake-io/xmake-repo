package("string-view-lite")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/string-view-lite")
    set_description("string_view lite - A C++17-like string_view for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/string-view-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/string-view-lite.git")
    add_versions("v1.7.0", "265eaec08c4555259b46f5b03004dbc0f7206384edfac1cd5a837efaa642e01c")

    add_deps("cmake")
    on_install(function (package)
        local configs = {
            "-DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF",
            "-DSTRING_VIEW_LITE_OPT_BUILD_EXAMPLES=OFF",
        }

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
                #include <iostream>
                #include <nonstd/string_view.hpp>

                using namespace nonstd::literals;
                using namespace nonstd;

                void write(string_view sv) { std::cout << sv; }

                void test() {
                    write("hello");
                    write(std::string(", "));
                    write("world!"_sv);   // nonstd::string_view
                }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)

