package("cpr")

    set_homepage("https://docs.libcpr.org/")
    set_description("C++ Requests is a simple wrapper around libcurl inspired by the excellent Python Requests project.")
    set_license("MIT")

    set_urls("https://github.com/libcpr/cpr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libcpr/cpr.git")
    add_versions("1.6.2", "c45f9c55797380c6ba44060f0c73713fbd7989eeb1147aedb8723aa14f3afaa3")
    add_versions("1.7.2", "aa38a414fe2ffc49af13a08b6ab34df825fdd2e7a1213d032d835a779e14176f")
    add_versions("1.8.3", "0784d4c2dbb93a0d3009820b7858976424c56578ce23dcd89d06a1d0bf5fd8e2")

    add_deps("cmake", "libcurl")
    if is_plat("mingw") then
        add_syslinks("pthread")
    end
    on_install("linux", "macosx", "windows", "mingw@windows", function (package)
        local configs = {"-DCPR_BUILD_TESTS=OFF", "-DCPR_ENABLE_SSL=ON", "-DCPR_FORCE_USE_SYSTEM_CURL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local shflags
        if package:config("shared") and package:is_plat("macosx") then
            shflags = {"-framework", "CoreFoundation", "-framework", "Security", "-framework", "SystemConfiguration"}
        end
        import("package.tools.cmake").install(package, configs, {shflags = shflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <cpr/cpr.h>
            static void test() {
                cpr::Response r = cpr::Get(cpr::Url{"https://xmake.io"});
                assert(r.status_code == 200);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
