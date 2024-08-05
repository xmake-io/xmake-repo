package("uvw")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skypjack/uvw")
    set_description("Header-only, event based, tiny and easy to use libuv wrapper in modern C++")

    add_urls("https://github.com/skypjack/uvw.git")

    add_versions("2.10.0", "v2.10.0_libuv_v1.42")
    add_versions("3.0.0", "v3.0.0_libuv_v1.44")
    add_versions("3.4.0", "v3.4.0_libuv_v1.48")

    if on_check then
        on_check("android", function (package)
            if package:version():ge("3.4.0") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(uvw): deps(libuv) need ndk api level >= 24 after v1.47.0")
            end
        end)
    end

    add_deps("cmake", "libuv")

    on_install("!wasm", function (package) 
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:version():le("2.10.0") then
        assert(package:check_cxxsnippets({
            test = [[
            #include <uvw.hpp>
            void test() {
                auto loop = uvw::Loop::getDefault();
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
        else
        assert(package:check_cxxsnippets({
            test = [[
            #include <uvw.hpp>
            void test() {
                auto loop = uvw::loop::get_default();
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
        end
    end)
