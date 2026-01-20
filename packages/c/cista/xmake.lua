package("cista")
    set_kind("library", {headeronly = true})
    set_homepage("https://cista.rocks")
    set_description("Cista is a simple, high-performance, zero-copy C++ serialization & reflection library.")
    set_license("MIT")

    add_urls("https://github.com/felixguendling/cista/archive/refs/tags/$(version).tar.gz",
             "https://github.com/felixguendling/cista.git")

    add_versions("v0.16", "55832c0e723568bd3abdfd70e7ba4dca777dfaada63f4da74f325f868f95694e")
    add_versions("v0.15", "f807d3282f68a74eed94d6e829763244ae22993169ab6ece7fd7c22bd2f08330")
    add_versions("v0.14", "9844a55fd3fd35a15614de01ff54e97ad0216d7b3d3952f14bfd6ebd7d6ff58f")

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:is_plat("android") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(cista): need ndk api level > 21 for android")
            end
            if package:is_plat("windows") and package:is_arch("x86") then
                assert(package:version():lt("0.16"), "package(cista): version >= 0.16 does not support windows|x86")
            end
        end)
    end

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "android", "iphoneos", "cross", function (package)
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
