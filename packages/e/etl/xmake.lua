package("etl")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.etlcpp.com")
    set_description("Embedded Template Library")
    set_license("MIT")

    add_urls("https://github.com/ETLCPP/etl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ETLCPP/etl.git")

    add_versions("20.38.0", "7e29ce81a2a2d5826286502a2ad5bde1f4b591d2c9e0ef7ccc335e75445223cd")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <etl/array.h>
            void test() {
                etl::array<int, 10> data = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
