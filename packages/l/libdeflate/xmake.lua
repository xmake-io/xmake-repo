package("libdeflate")

    set_homepage("https://github.com/ebiggers/libdeflate")
    set_description("libdeflate is a library for fast, whole-buffer DEFLATE-based compression and decompression.")
    set_license("MIT")

    add_urls("https://github.com/ebiggers/libdeflate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ebiggers/libdeflate.git")
    add_versions("v1.8", "50711ad4e9d3862f8dfb11b97eb53631a86ee3ce49c0e68ec2b6d059a9662f61")
    add_versions("v1.10", "5c1f75c285cd87202226f4de49985dcb75732f527eefba2b3ddd70a8865f2533")
    add_versions("v1.13", "0d81f197dc31dc4ef7b6198fde570f4e8653c77f4698fcb2163d820a9607c838")
    add_versions("v1.15", "58b95040df7383dc0413defb700d9893c194732474283cc4c8f144b00a68154b")
    add_versions("v1.17", "fa4615af671513fa2a53dc2e7a89ff502792e2bdfc046869ef35160fcc373763")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "LIBDEFLATE_DLL")
        end
    end)

    on_install("windows", "macosx", "linux", "android", "mingw", "bsd", function (package)
        if package:is_plat("windows") and package:is_arch("arm.*") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            assert(tonumber(vs) > 2019, "libdeflate requires Visual Studio 2022 and later for arm targets")
        end
        local configs = {"-DLIBDEFLATE_BUILD_GZIP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBDEFLATE_BUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLIBDEFLATE_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdeflate_alloc_compressor", {includes = "libdeflate.h"}))
    end)
