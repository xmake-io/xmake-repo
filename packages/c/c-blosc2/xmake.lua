package("c-blosc2")
    set_homepage("https://www.blosc.org")
    set_description("A fast, compressed, persistent binary data store library for C.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Blosc/c-blosc2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Blosc/c-blosc2.git")

    add_versions("v2.15.2", "32d0cb011303878bc5307d06625bc6e5fc28e788377873016bc52681e4e9fee9")
    add_versions("v2.15.1", "6cf32fcfc615542b9ba35e021635c8ab9fd3d328fd99d5bf04b7eebc80f1fae2")
    add_versions("v2.15.0", "1e7d9d099963ad0123ddd76b2b715b5aa1ea4b95c491d3a11508e487ebab7307")
    add_versions("v2.14.4", "b5533c79aacc9ac152c80760ed1295a6608938780c3e1eecd7e53ea72ad986b0")
    add_versions("v2.14.3", "2b94c2014ba455e8136e16bf0738ec64c246fcc1a77122d824257caf64aaf441")
    add_versions("v2.13.2", "f2adcd9615f138d1bb16dc27feadab1bb1eab01d77e5e2323d14ad4ca8c3ca21")
    add_versions("v2.10.2", "069785bc14c006c7dab40ea0c620bdf3eb8752663fd55c706d145bceabc2a31d")

    add_configs("lz4", {description = "Enable LZ4 support.", default = true, type = "boolean"})
    add_configs("zlib", {description = "Enable Zlib support.", default = false, type = "boolean"})
    add_configs("zstd", {description = "Enable Zstd support.", default = false, type = "boolean"})
    add_configs("plugins", {description = "Build plugins programs from the blosc compression library", default = false, type = "boolean"})
    add_configs("lite", {description = "Build a lite version (only with BloscLZ and LZ4/LZ4HC) of the blosc library", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        for _, deps in ipairs({"lz4", "zlib", "zstd"}) do
            if package:config(deps) then
                package:add("deps", deps)
            end
        end
    end)

    on_install(function (package)
        local configs =
        {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_FUZZERS=OFF",
            "-DBUILD_BENCHMARKS=OFF",
            "-DBUILD_EXAMPLES=OFF",
        }
        if package:config("shared") then
            table.insert(configs, "-DBUILD_STATIC=OFF")
            table.insert(configs, "-DBUILD_SHARED=ON")
        else
            table.insert(configs, "-DBUILD_STATIC=ON")
            table.insert(configs, "-DBUILD_SHARED=OFF")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_PLUGINS=" .. (package:config("plugins") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_LITE=" .. (package:config("lite") and "ON" or "OFF"))

        for _, deps in ipairs({"lz4", "zlib", "zstd"}) do
            local upper = deps:upper()
            table.insert(configs, "-DPREFER_EXTERNAL_" .. upper .. "=ON")
            table.insert(configs, "-DDEACTIVATE_" .. upper .. (package:config(deps) and "=OFF" or "=ON"))
        end
        import("package.tools.cmake").install(package, configs)
        -- remove crt dll
        if package:is_plat("windows") then
            for _, dll in ipairs(os.files(path.join(package:installdir("bin"), "*.dll"))) do
                if not path.filename(dll):find("blosc2") then
                    os.rm(dll)
                end
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blosc2_init", {includes = "blosc2.h"}))
    end)
