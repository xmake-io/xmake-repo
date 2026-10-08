package("icey")
    set_homepage("https://0state.com/icey/")
    set_description("C++20 media stack for real-time video, signalling, TURN, and media servers")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/nilstate/icey/archive/refs/tags/$(version).tar.gz")
    add_versions("2.5.1", "2df5f802db160212de78a1bdfba01c9275b5d5d0ca8f58b00298779d50a5e02a")

    add_deps("cmake", "libuv", "llhttp", "minizip", "zlib")
    if is_host("windows") then
        add_deps("pkgconf")
    end

    on_load(function (package)
        package:add("deps", "openssl3", {configs = {shared = package:config("shared")}})
    end)

    on_install(function (package)
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
