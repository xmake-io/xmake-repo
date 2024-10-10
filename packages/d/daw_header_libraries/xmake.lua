package("daw_header_libraries")
    set_kind("library", {headeronly = true})
    set_homepage("https://beached.github.io/header_libraries/")
    set_description("Various header libraries mostly future std lib, replacements for(e.g. visit), or some misc ")
    set_license("BSL-1.0")

    add_urls("https://github.com/beached/header_libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/beached/header_libraries.git")

    add_versions("v2.110.0", "6515bb7a130656adff9f1f17d6be69dbd7c40dbcebbe418e9d0cf15bbc71bffc")
    add_versions("v2.106.1", "393815fbf249ca1220a216899cae3d2672ca193f9db228a0b99925a9b0f90854")
    add_versions("v2.106.0", "7838ada09afa69e7a42d742991c4b24b32ba27681e7b4dadf7b1e45c168937b5")
    add_versions("v2.102.0", "bc80936b439da0ef8a432175732e94573b14069a778b83d5f26ce8847f11ebb8")
    add_versions("v2.96.1", "2a9a5c33baa9e3adc1d82fa13a56522638af13cc39372a0c1c8f5c5d984f1464")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local code = [[
            #include <daw/daw_carray.h>
            void test() {
                daw::carray<int, 6> t = {1, 2, 3, 4, 5, 6};
            }
        ]]
        if package:gitref() or package:version():ge("2.109.0") then
            code = [[
                #include <daw/daw_bounded_array.h>
                void test() {
                    daw::array<int, 6> t = { 1, 2, 3, 4, 5, 6 };
            }
            ]]
        end
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++17"}}))
    end)
