package("daw_header_libraries")
    set_kind("library", {headeronly = true})
    set_homepage("https://beached.github.io/header_libraries/")
    set_description("Various header libraries mostly future std lib, replacements for(e.g. visit), or some misc ")

    add_urls("https://github.com/beached/header_libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/beached/header_libraries.git")

    add_versions("v2.96.1", "2a9a5c33baa9e3adc1d82fa13a56522638af13cc39372a0c1c8f5c5d984f1464")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <daw/daw_carray.h>
            void test() {
                daw::carray<int, 6> t = {1, 2, 3, 4, 5, 6};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
