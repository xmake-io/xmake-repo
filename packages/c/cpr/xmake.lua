package('cpr')

    set_homepage("https://whoshuu.github.io/cpr/")
    set_description("C++ Requests is a simple wrapper around libcurl inspired by the excellent Python Requests project.")

    set_urls("https://github.com/whoshuu/cpr/archive/refs/tags/$(version).tar.gz")
    add_versions("1.6.2", "c45f9c55797380c6ba44060f0c73713fbd7989eeb1147aedb8723aa14f3afaa3")

    add_deps('libcurl')

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {'-DCPR_BUILD_TESTS=OFF'})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <cpr/cpr.h>
            static void test() {
                cpr::Response r = cpr::Get(cpr::Url{"https://www.baidu.com"});
                assert(r.status_code == 200);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
