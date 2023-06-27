package("blosc")

    set_homepage("https://www.blosc.org/")
    set_description("A blocking, shuffling and loss-less compression library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Blosc/c-blosc/archive/$(version).tar.gz",
             "https://github.com/Blosc/c-blosc.git")
    add_versions("v1.21.4", "e72bd03827b8564bbb3dc3ea0d0e689b4863871ce3861d946f2efd7a186ecf3e")
    add_versions("v1.21.1", "f387149eab24efa01c308e4cba0f59f64ccae57292ec9c794002232f7903b55b")
    add_versions("v1.20.1", "42c4d3fcce52af9f8e2078f8f57681bfc711706a3330cb72b9b39e05ae18a413")
    add_versions("v1.5.0", "208ba4db0e5116421ed2fbbdf2adfa3e1d133d29a6324a0f47cf2d71f3810c92")

    add_configs("lz4", {description = "Enable LZ4 support.", default = false, type = "boolean"})
    add_configs("snappy", {description = "Enable Snappy support.", default = false, type = "boolean"})
    add_configs("zlib", {description = "Enable Zlib support.", default = true, type = "boolean"})
    add_configs("zstd", {description = "Enable Zstd support.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("macosx", "linux", "windows", "mingw", function (package)
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") and enabled then
                package:add("deps", name)
            end
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_FUZZERS=OFF", "-DBUILD_BENCHMARKS=OFF", "-DPREFER_EXTERNAL_COMPLIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED=ON")
            table.insert(configs, "-DBUILD_STATIC=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED=OFF")
            table.insert(configs, "-DBUILD_STATIC=ON")
        end
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DDEACTIVATE_" .. name:upper() .. "=" .. (enabled and "OFF" or "ON"))
                table.insert(configs, "-DPREFER_EXTERNAL_" .. name:upper() .. "=ON")
            end
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        if package:is_plat("windows", "mingw") then
            -- special concern for legacy versions which keep producing the shared library
            local version = package:version()
            if package:config("shared") then
                os.trycp("build/install/bin", package:installdir())
                os.trymv(path.join(package:installdir("lib"), "blosc.dll"), package:installdir("bin"))
            elseif version:le("1.10") then
                os.rm(path.join(package:installdir("lib"), "blosc.lib"))
                os.rm(path.join(package:installdir("lib"), "blosc.dll"))
                os.mv(path.join(package:installdir("lib"), "libblosc.lib"), path.join(package:installdir("lib"), "blosc.lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stdio.h>
            #define SIZE 100*100*100
            void test() {
                static float data[SIZE];
                static float data_out[SIZE];
                static float data_dest[SIZE];
                int isize = SIZE*sizeof(float), osize = SIZE*sizeof(float);
                int dsize = SIZE*sizeof(float), csize;
                for (int i = 0; i < SIZE; i++){
                    data[i] = i;
                }
                blosc_init();
                csize = blosc_compress(5, 1, sizeof(float), isize, data, data_out, osize);
                dsize = blosc_decompress(data_out, data_dest, dsize);
                blosc_destroy();
            }
        ]]}, {configs = {languages = "c++11"},
              includes = {"blosc.h"}}))
    end)
