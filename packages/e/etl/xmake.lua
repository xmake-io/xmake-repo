package("etl")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.etlcpp.com")
    set_description("Embedded Template Library")
    set_license("MIT")

    add_urls("https://github.com/ETLCPP/etl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ETLCPP/etl.git")

    add_versions("20.38.17", "5b490aca3faad3796a48bf0980e74f2a67953967fad3c051a6d4981051cb0b9a")
    add_versions("20.38.16", "6d05e33d6e7eb2c8d4654c77dcd083adc70da29aba808f471ba7c6e2b8fcbf03")
    add_versions("20.38.13", "e606083e189a8fe6211c30c8c579b60c29658a531b5cafbb511daab1a2861a69")
    add_versions("20.38.11", "c73b6b076ab59e02398a9f90a66198a9f8bf0cfa91af7be2eebefb3bb264ba83")
    add_versions("20.38.10", "562f9b5d9e6786350b09d87be9c5f030073e34d7bf0a975de3e91476ddd471a3")
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
