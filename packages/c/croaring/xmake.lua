package("croaring")
    set_homepage("http://roaringbitmap.org/")
    set_description("Roaring bitmaps in C (and C++), with SIMD (AVX2, AVX-512 and NEON) optimizations: used by Apache Doris, ClickHouse, and StarRocks")
    set_license("Apache-2.0")

    add_urls("https://github.com/RoaringBitmap/CRoaring/archive/refs/tags/$(version).tar.gz",
             "https://github.com/RoaringBitmap/CRoaring.git")

    add_versions("v2.0.4", "3c962c196ba28abf2639067f2e2fd25879744ba98152a4e0e74556ca515eda33")

    add_configs("exceptions", {description = "Enable exception-throwing interface", default = false, type = "boolean"})
    add_configs("x64", {description = "Enable x64 optimizations even if hardware supports it (this disables AVX)", default = false, type = "boolean"})
    add_configs("avx", {description = "Enable AVX even if hardware supports it", default = false, type = "boolean"})
    add_configs("neon", {description = "Enable NEON even if hardware supports it", default = false, type = "boolean"})
    add_configs("avx512", {description = "Enable AVX512 even if compiler supports it", default = false, type = "boolean"})
    add_configs("c_as_cpp", {description = "Build library C files using C++ compilation", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
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
