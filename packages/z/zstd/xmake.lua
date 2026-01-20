package("zstd")
    set_homepage("https://www.zstd.net/")
    set_description("Zstandard - Fast real-time compression algorithm")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/facebook/zstd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/facebook/zstd.git")

    add_versions("v1.5.7", "37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3")
    add_versions("v1.4.5", "734d1f565c42f691f8420c8d06783ad818060fc390dee43ae0a89f86d0a4f8c2")
    add_versions("v1.5.0", "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867")
    add_versions("v1.5.2", "f7de13462f7a82c29ab865820149e778cbfe01087b3a55b5332707abf9db4a6e")
    add_versions("v1.5.5", "98e9c3d949d1b924e28e01eccb7deed865eefebf25c2f21c702e5cd5b63b85e1")
    add_versions("v1.5.6", "30f35f71c1203369dc979ecde0400ffea93c27391bfd2ac5a9715d2173d92ff7")

    add_patches("1.5.6", "patches/1.5.6/fix-rc-build.patch", "c898c652a4f48ce63b0b9da03406eb988de453f0c7b93f43f42f4e1e394eb17c")

    add_configs("cmake", {description = "Use cmake buildsystem", default = true, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("contrib", {description = "Build contrib", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        -- Some downstream cmake package need patch: find_package(zstd CONFIG REQUIRED)
        -- https://github.com/facebook/zstd/issues/3271
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
        if package:is_binary() then
            package:config_set("tools", true)
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ZSTD_DLL_IMPORT=1")
        end
    end)

    on_install(function (package)
        if not package:config("cmake") then
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {ver = package:version_str()})
            return
        end

        os.cd("build/cmake")

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DZSTD_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DZSTD_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DZSTD_BUILD_PROGRAMS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DZSTD_BUILD_CONTRIB=" .. (package:config("contrib") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            -- Some custom Findzstd.cmake will match zstd.lib
            local lib = package:installdir("lib/zstd_static.lib")
            if os.isfile(lib) then
                os.cp(lib, path.join(package:installdir("lib"), "zstd.lib"))
                package:add("links", "zstd")
            end
        end
    end)

    on_test(function (package)
        if package:is_library() then
            assert(package:has_cfuncs("ZSTD_compress", {includes = {"zstd.h"}}))
            assert(package:has_cfuncs("ZSTD_decompress", {includes = {"zstd.h"}}))
        end
        if not package:is_cross() and package:config("tools") then
            os.vrun("zstd --version")
        end
    end)
