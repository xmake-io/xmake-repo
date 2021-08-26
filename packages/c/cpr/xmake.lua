package('cpr')

    set_homepage("https://whoshuu.github.io/cpr/")
    set_description("C++ Requests is a simple wrapper around libcurl inspired by the excellent Python Requests project.")

    set_urls("https://github.com/whoshuu/cpr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/whoshuu/cpr.git")
    add_versions("1.6.2", "c45f9c55797380c6ba44060f0c73713fbd7989eeb1147aedb8723aa14f3afaa3")

    add_deps("cmake", "libcurl")
    if is_plat("macosx") then
        add_frameworks("Security")
    end

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-DCPR_BUILD_TESTS=OFF", "-DCPR_FORCE_USE_SYSTEM_CURL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")) 
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF")) 
        import("package.tools.cmake").install(package, configs)
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
