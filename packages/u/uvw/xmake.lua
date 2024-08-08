package("uvw")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skypjack/uvw")
    set_description("Header-only, event based, tiny and easy to use libuv wrapper in modern C++")
    set_license("MIT")

    local versions = {
        ["v3.4.0"] = "v1.48.0",
        ["v3.3.0"] = "v1.47.0",
        ["v3.2.0"] = "v1.46.0",
        ["v3.1.0"] = "v1.45.0",
        ["v3.0.0"] = "v1.44.1",
        ["v2.12.1"] = "v1.44.1",
        ["v2.11.0"] = "v1.43.0",
        ["v2.10.0"] = "v1.42.0",
    }
    
    add_urls("https://github.com/skypjack/uvw.git")
    add_urls("https://github.com/skypjack/uvw/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            local v = tostring(version)
            return format("%s_libuv_%s", v, string.sub(versions[v], 1, -3))
        end})

    add_versions("v3.4.0", "c16600573871a5feeb524234b378ab832c8971b2a68d030c6bd0e3077d416ade")
    add_versions("v3.3.0", "aabb17d3d8f0b3481b44e981c889dd4a2a6a3f1a96a4d01055e669f4b7d37d0e")
    add_versions("v3.2.0", "bd5aed741765950074b1ea2507291dce81e528abdf56c406991ad4a27d8d1714")
    add_versions("v3.1.0", "0a612bd243150fbbe1365cdaf48203d32061c1d14f93825a31876b183922f93b")
    add_versions("v3.0.0", "aca0ffcbcc27a3cca2c9be608b99a75db85c91e9f1735e2abb5269e8c22c6e61")
    add_versions("v2.12.1", "3460842778e91e7d2fae4201e49e4521e9d94fbbf3891ae6c52d3c9fc0673598")
    add_versions("v2.11.0", "3af4efa2842299490ec764f2148f85f4426dfb4f8d8aa436cc2d049db2b7b514")
    add_versions("v2.10.0", "30b0ba97a94d5e652490c6b1b32c95e608263f21cf3bc606308d09b3e3a114bf")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            if package:version():ge("3.1.0") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(uvw): deps(libuv) need ndk api level >= 24 after v1.45.0")
            end
        end)
    end

    on_load(function (package)
        package:add("deps", "libuv " .. versions[package:version_str()])
    end)

    on_install("!wasm", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        local code
        if package:version() and package:version():lt("3.0.0") then
            code = [[
                void test() {
                    auto loop = uvw::Loop::getDefault();
                }
            ]]
        else
            code = [[
                void test() {
                    auto loop = uvw::loop::get_default();
                }
            ]]
        end
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++17"}, includes = "uvw.hpp"}))
    end)
