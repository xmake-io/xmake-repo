package("daw_json_link")
    set_kind("library", {headeronly = true})
    set_homepage("https://beached.github.io/daw_json_link/")
    set_description("Fast, convenient JSON serialization and parsing in C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/beached/daw_json_link/archive/refs/tags/$(version).tar.gz",
             "https://github.com/beached/daw_json_link.git")

    add_versions("v3.24.0", "7cecb2acde88028043e343ed4da7cde84c565a38125d3edb90db90daf881240a")
    add_versions("v3.23.2", "fd1234a14c126c79076e0b6e6eceae42afd465c419dc7a7393c69c28aa7f53d4")
    add_versions("v3.20.1", "046638bc4437d138cc8bdc882027d318ca3e267f33d1b419c5bdecb45b595a47")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android@linux,macosx", "iphoneos", "cross", function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(daw_json_link): need ndk api level > 21 for android")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <daw/json/daw_json_link.h>
            void test() {
                std::string json_data = "[1, 2, 3, 4, 5]";
                auto const obj = daw::json::from_json_array<int>(json_data);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
