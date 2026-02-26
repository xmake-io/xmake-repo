package("nanovdb")
    set_kind("library", {headeronly = true})
    set_homepage("https://developer.nvidia.com/nanovdb")
    set_description("Developed by NVIDIA, NanoVDB adds real-time rendering GPU support for OpenVDB.")
    set_license("Apache-2.0")

    add_urls("https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openvdb.git")

    add_versions("v12.1.0", "ebb9652ad1d67274e2c85e6736cced5f04e313c5671ae1ae548f174cc76e9e64")

    add_configs("openvdb", {description = "Build with OpenVDB support", default = false, type = "boolean"})
    add_configs("blosc", {description = "Build with BLOSC support", default = false, type = "boolean"})
    add_configs("zlib", {description = "Build with ZLIB support", default = false, type = "boolean"})
    add_configs("tbb", {description = "Build with TBB support", default = false, type = "boolean"})
    add_configs("magicaVoxel", {description = "Build with MagicaVoxel support", default = false, type = "boolean"})
    add_configs("cuda", {description = "Build with CUDA support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("blosc") then
            package:add("deps", "blosc")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("tbb") then
            package:add("deps", "tbb")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DUSE_CCACHE=OFF",
            "-DUSE_NANOVDB=ON",
            "-DOPENVDB_BUILD_CORE=OFF",
            "-DOPENVDB_BUILD_BINARIES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DNANOVDB_USE_OPENVDB=" .. (package:config("openvdb") and "ON" or "OFF"))
        table.insert(configs, "-DNANOVDB_USE_BLOSC=" .. (package:config("blosc") and "ON" or "OFF"))
        table.insert(configs, "-DNANOVDB_USE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DNANOVDB_USE_TBB=" .. (package:config("tbb") and "ON" or "OFF"))
        table.insert(configs, "-DNANOVDB_USE_MAGICAVOXEL=" .. (package:config("magicaVoxel") and "ON" or "OFF"))
        table.insert(configs, "-DNANOVDB_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))

        local cuda = package:dep("cuda")
        if not is_plat("windows") and package:config("cuda") and cuda then
            local fetch = cuda:fetch()
            if fetch and fetch.includedirs and #fetch.includedirs ~= 0 then
                -- /usr/local/cuda/include -> /usr/local/cuda/bin
                table.insert(configs, "-DCMAKE_CUDA_COMPILER=" .. path.join(path.directory(fetch.includedirs[1]), "bin/nvcc"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto handle = nanovdb::io::readGrid("data/sphere.nvdb"); // reads first grid from file
                auto* grid = handle.grid<float>(); // get a (raw) pointer to a NanoVDB grid of value type float
                if (!grid)
                    throw std::runtime_error("File did not contain a grid with value type float");

                auto acc = grid->getAccessor(); // create an accessor for fast access to multiple values
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"nanovdb/util/IO.h"}}))
    end)
