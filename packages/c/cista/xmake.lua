package("cista")
    set_kind("library", {headeronly = true})
    set_homepage("https://cista.rocks")
    set_description("Cista is a simple, high-performance, zero-copy C++ serialization & reflection library.")
    set_license("MIT")

    add_urls("https://github.com/felixguendling/cista/archive/refs/tags/$(version).tar.gz",
             "https://github.com/felixguendling/cista.git")

    add_versions("v0.14", "9844a55fd3fd35a15614de01ff54e97ad0216d7b3d3952f14bfd6ebd7d6ff58f")

    add_deps("cmake")

    on_install("windows|x64", "windows|x86","linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(cista): need ndk api level > 21 for android")
        end
        import("package.tools.cmake").install(package, {"-DCISTA_INSTALL=ON"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <cista/serialization.h>
            namespace data = cista::raw;
            struct my_struct {
                int a_{0};
                struct inner {
                    data::string b_;
                } j;
            };
            void test() {
                std::vector<unsigned char> buf;
                {
                    my_struct obj{1, {data::string{"test"}}};
                    buf = cista::serialize(obj);
                }
                auto deserialized = cista::deserialize<my_struct>(buf);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
