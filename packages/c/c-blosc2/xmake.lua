package("c-blosc2")
    set_homepage("https://www.blosc.org")
    set_description("A fast, compressed, persistent binary data store library for C.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Blosc/c-blosc2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Blosc/c-blosc2.git")

    add_versions("v2.22.0", "6c6fe90babfa09bd3c544643d3fc3ea9516f9cbc74e8b3342f0d50416862b76f")
    add_versions("v2.21.3", "4ac2e8b7413624662767b4348626f54ad621d6fbd315d0ba8be32a6ebaa21d41")
    add_versions("v2.21.1", "69bd596bc4c64091df89d2a4fbedc01fc66c005154ddbc466449b9dfa1af5c05")
    add_versions("v2.21.0", "de69eedd87a8301cdb665f3dab61e7c2b7e4b326a496f9ec88213fc8788d54d5")
    add_versions("v2.19.1", "cb645982acfeccc8676bc4f29859130593ec05f7f9acf62ebd4f1a004421fa28")
    add_versions("v2.18.0", "9fce013de33a3f325937b6c29fd64342c1e71de38df6bb9eda09519583d8aabe")
    add_versions("v2.17.1", "53c6ed1167683502f5db69d212106e782180548ca5495745eb580e796b7f7505")
    add_versions("v2.17.0", "f8d5b7167f6032bc286b4de63a7feae281d1845d962edcfa21d81a025eef2bb2")
    add_versions("v2.16.0", "9c2d4a92b43414239120cedf757cbdfbe1e5d9ba21c8779396c553fc0c883f3a")
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
        if package:config("lz4") then
            package:add("deps", "lz4", {configs = {cmake = true}})
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("zstd") then
            package:add("deps", "zstd", {configs = {cmake = true}})
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "include(InstallRequiredSystemLibraries)", "", {plain = true})

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

        if package:is_plat("windows") and package:config("shared") then
            io.replace(path.join(package:installdir(), "include/blosc2/blosc2-export.h"),
                "#define BLOSC_EXPORT\n",
                "#define BLOSC_EXPORT __declspec(dllimport)\n", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("blosc2_init", {includes = "blosc2.h"}))
    end)
