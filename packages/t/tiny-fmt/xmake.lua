package("tiny-fmt")
    set_homepage("https://github.com/monjaris/tiny-fmt")
    set_description("A modern lightweight formatting/logging library with {fmt} core")
    set_license("MIT")

    add_urls("https://github.com/monjaris/tiny-fmt/archive/refs/tags/$(version).tar.gz", "https://github.com/monjaris/tiny-fmt.git")
    add_versions("12.2.0-tiny-3", "3177f643030f40bd87140d536db927e10d5a96238c65672b328ebde7455dbc08")


    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)


    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <tinyfmt/tfmt.hpp>

            void test()
            {
                auto s = tfmt::format("{}", 42);
                tfmt::print("{}", 120);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
