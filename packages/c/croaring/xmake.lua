package("croaring")
    set_homepage("http://roaringbitmap.org/")
    set_description("Roaring bitmaps in C (and C++), with SIMD (AVX2, AVX-512 and NEON) optimizations: used by Apache Doris, ClickHouse, and StarRocks")
    set_license("Apache-2.0")

    add_urls("https://github.com/RoaringBitmap/CRoaring/archive/refs/tags/$(version).tar.gz",
             "https://github.com/RoaringBitmap/CRoaring.git")

    add_versions("v4.5.0", "8f945ad82ce1be195c899c57e0734a5c0ea2685c3127bf9033d4391d054f94ab")
    add_versions("v4.4.2", "11cc5d37b2d719e02936c71db83d3a5d1f3d27c59005348f4ee6417a63617b77")
    add_versions("v4.4.0", "5fd485bfdb83261143e6d0ad8967bf779cf99eda6747ac198d861f3b8e4a1e46")
    add_versions("v4.3.12", "9f1602d7ff83e84ce0a5928129bb957a1eeacd3b092b39e21f5f0b931682b8d6")
    add_versions("v4.3.6", "d9c63e6fa06630cd626be004a226bea15eb4acba6740a46f58c6b189fa5d49b3")
    add_versions("v4.3.5", "fd5afacb174322ce45bea333076440e615fb8cc2751b537c8051ac2d39f52b1e")
    add_versions("v4.1.7", "ea235796c074c3a8a8c3e5c84bb5f09619723b8e4913cf99cc349f626c193569")
    add_versions("v4.1.5", "7eafa9fd0dace499e80859867a6ba5a010816cf6e914dd9350ad1d44c0fc83eb")
    add_versions("v4.1.1", "42804cc2bb5c9279ec4fcaa56d2d6b389da934634abcce8dbc4e4c1d60e1468d")
    add_versions("v4.1.0", "0596c6e22bcccb56f38260142b435f1f72aef7721fa370fd9f2b88380245fc1d")
    add_versions("v4.0.0", "a8b98db3800cd10979561a1388e4e970886a24015bd6cfabb08ba7917f541b0d")
    add_versions("v3.0.1", "a1cac9489b1c806c5594073e5db36475e247604282a47b650f4166c185ab061f")
    add_versions("v2.0.4", "3c962c196ba28abf2639067f2e2fd25879744ba98152a4e0e74556ca515eda33")

    add_configs("exceptions", {description = "Enable exception-throwing interface", default = false, type = "boolean"})
    add_configs("x64", {description = "Enable x64 optimizations even if hardware supports it (this disables AVX)", default = false, type = "boolean"})
    add_configs("avx", {description = "Enable AVX even if hardware supports it", default = false, type = "boolean"})
    add_configs("neon", {description = "Enable NEON even if hardware supports it", default = false, type = "boolean"})
    add_configs("avx512", {description = "Enable AVX512 even if compiler supports it", default = false, type = "boolean"})
    add_configs("c_as_cpp", {description = "Build library C files using C++ compilation", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        if os.isfile("tools/cmake/FindOptions.cmake") and package:has_tool("cxx", "clang") then
            io.replace("tools/cmake/FindOptions.cmake", "if(MSVC)\nadd_definitions", "if(0)\nadd_definitions", {plain = true})
            io.replace("tools/cmake/FindOptions.cmake", "if(MSVC_VERSION GREATER 1910)", "if(0)", {plain = true})
        end
        if package:is_plat("bsd") then
            -- https://man.freebsd.org/cgi/man.cgi?query=bswap64
            io.replace("include/roaring/portability.h", "byteswap.h", "sys/endian.h", {plain = true})
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DENABLE_ROARING_TESTS=OFF", "-DROARING_USE_CPM=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DROARING_BUILD_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DROARING_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DROARING_BUILD_C_AS_CPP=" .. (package:config("c_as_cpp") and "ON" or "OFF"))
        table.insert(configs, "-DROARING_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        if package:config("x64") then
            table.insert(configs, "-DROARING_DISABLE_X64=OFF")
        else
            package:add("defines", "ROARING_DISABLE_X64=1")
            table.insert(configs, "-DROARING_DISABLE_X64=ON")
        end
        if package:config("avx") then
            table.insert(configs, "-DROARING_DISABLE_AVX=OFF")
        else
            package:add("defines", "ROARING_DISABLE_AVX=1")
            table.insert(configs, "-DROARING_DISABLE_AVX=ON")
        end
        if package:config("neon") then
            table.insert(configs, "-DROARING_DISABLE_NEON=OFF")
        else
            package:add("defines", "DISABLENEON=1")
            table.insert(configs, "-DROARING_DISABLE_NEON=ON")
        end
        if package:config("avx512") then
            table.insert(configs, "-DROARING_DISABLE_AVX512=OFF")
        else
            package:add("defines", "CROARING_COMPILER_SUPPORTS_AVX512=0")
            table.insert(configs, "-DROARING_DISABLE_AVX512=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("roaring_bitmap_create", {includes = "roaring/roaring.h"}))
    end)
