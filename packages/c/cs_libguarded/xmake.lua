package("cs_libguarded")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.copperspice.com/")
    set_description("Header-only library for multithreaded programming")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/copperspice/cs_libguarded.git")
    add_versions("2023.08.02", "1940568f8f21c2ef3d57551682dfc038772df6f6")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <CsLibGuarded/cs_cow_guarded.h>
            void test() {
                libguarded::cow_guarded<int, std::timed_mutex> data(0);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
