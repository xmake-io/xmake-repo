package("icey")
    set_homepage("https://0state.com/icey/")
    set_description("C++20 media stack for real-time video, signalling, TURN, and media servers")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/nilstate/icey/archive/refs/tags/$(version).tar.gz")
    add_versions("2.5.1", "2df5f802db160212de78a1bdfba01c9275b5d5d0ca8f58b00298779d50a5e02a")
    add_patches("2.5.1", "patches/address-cstdint.patch", "a3cbfdeaf427990c6205fdd77abe9074484a1f294d8e4178580e2c7346ee1fcb")
    add_patches("2.5.1", "patches/avfoundation-ios.patch", "124b887958ce6fb28dbc2212ca86e62ad59f948d9cb92dbb5b15c32ca9fdb60a")
    add_patches("2.5.1", "patches/minizip-targets.patch", "61924725ceec347b3ef14f181e341d1aec6b34b362dba4249fe8686fb05e21b8")
    add_patches("2.5.1", "patches/zip-directory-attribute.patch", "7920e6891623da7a4defa3a862072d316ec27d6e3d15080e572e21e95f367716")

    add_deps("cmake", "libuv", "llhttp", "minizip", "zlib")
    if is_host("windows") then
        add_deps("pkgconf")
    end

    on_load(function (package)
        if package:is_plat("wasm") then
            package:add("deps", "openssl3")
        else
            package:add("deps", "openssl3", {configs = {shared = package:config("shared")}})
        end
    end)

    if on_check then
        on_check("android", function (package)
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(icey) requires Android API level >= 24 for libuv")
        end)
    end

    on_install("!wasm", function (package)
        local configs = {
            "-DUSE_SYSTEM_DEPS=ON",
            "-DBUILD_TESTS=OFF",
            "-DBUILD_SAMPLES=OFF",
            "-DBUILD_APPLICATIONS=OFF",
            "-DBUILD_FUZZERS=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DBUILD_PERF=OFF",
            "-DBUILD_ALPHA=OFF",
            "-DWITH_FFMPEG=OFF",
            "-DWITH_OPENCV=OFF",
            "-DWITH_LIBDATACHANNEL=OFF",
            "-DENABLE_NATIVE_ARCH=OFF",
            "-DENABLE_LTO=OFF",
            "-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE",
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF")
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "icy/time.h"
            void test() { (void)icy::time::now(); }
        ]]}, {configs = {languages = "cxx20"}}))
    end)
