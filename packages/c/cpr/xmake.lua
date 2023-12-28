package("cpr")

    set_homepage("https://docs.libcpr.org/")
    set_description("C++ Requests is a simple wrapper around libcurl inspired by the excellent Python Requests project.")
    set_license("MIT")

    set_urls("https://github.com/libcpr/cpr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libcpr/cpr.git")
    add_versions("1.6.2", "c45f9c55797380c6ba44060f0c73713fbd7989eeb1147aedb8723aa14f3afaa3")
    add_versions("1.7.2", "aa38a414fe2ffc49af13a08b6ab34df825fdd2e7a1213d032d835a779e14176f")
    add_versions("1.8.3", "0784d4c2dbb93a0d3009820b7858976424c56578ce23dcd89d06a1d0bf5fd8e2")
    add_versions("1.9.4", "2fbb27716c010d8a28e52d5bc8f108e0d073ca3b3f5a48a2696b0231ea5196d5")
    add_versions("1.10.2", "044e98079032f7abf69c4c82f90ee2b4e4a7d2f28245498a5201ad6e8d0b1d08")
    add_versions("1.10.3", "d7f2574bd9dae8adb0ce6cf1afab119b509c297fffcb4204a1bb3e4e731074f2")
    add_versions("1.10.5", "c8590568996cea918d7cf7ec6845d954b9b95ab2c4980b365f582a665dea08d8")

    add_configs("ssl", {description = "Enable SSL.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("mingw") then
        add_syslinks("pthread")
    end
    add_links("cpr")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "libcurl", {configs = {libssh2 = true, zlib = true}})
            package:add("deps", "libssh2")
        else
            package:add("deps", "libcurl")
        end
    end)

    on_install("linux", "macosx", "windows", "mingw@windows", function (package)
        local configs = {"-DCPR_BUILD_TESTS=OFF",
                         "-DCPR_FORCE_USE_SYSTEM_CURL=ON",
                         "-DCPR_USE_SYSTEM_CURL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCPR_ENABLE_SSL=" .. (package:config("ssl") and "ON" or "OFF"))
        local shflags
        if package:config("shared") and package:is_plat("macosx") then
            shflags = {"-framework", "CoreFoundation", "-framework", "Security", "-framework", "SystemConfiguration"}
        end
        local packagedeps = {"libcurl"}
        if package:config("ssl") then
            table.insert(packagedeps, "libssh2")
        end
        if package:is_plat("windows") then
            -- fix find_package issue on windows
            io.replace("CMakeLists.txt", "find_package%(CURL COMPONENTS .-%)", "find_package(CURL)")
        end
        import("package.tools.cmake").install(package, configs, {shflags = shflags, packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            #include <cpr/cpr.h>
            static void test() {
                cpr::Response r = cpr::Get(cpr::Url{"https://xmake.io"});
                assert(r.status_code == 200);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)


