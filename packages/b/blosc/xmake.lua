package("blosc")

    set_homepage("https://www.blosc.org/")
    set_description("A blocking, shuffling and loss-less compression library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Blosc/c-blosc/archive/v$(version).tar.gz",
             "https://github.com/Blosc/c-blosc.git")
    add_versions("1.21.1", "f387149eab24efa01c308e4cba0f59f64ccae57292ec9c794002232f7903b55b")
    add_versions("1.20.1", "42c4d3fcce52af9f8e2078f8f57681bfc711706a3330cb72b9b39e05ae18a413")
    add_versions("1.5.0", "208ba4db0e5116421ed2fbbdf2adfa3e1d133d29a6324a0f47cf2d71f3810c92")

    add_deps("cmake", "zlib")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("macosx", "linux", "windows", "mingw", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_BENCHMARKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED=ON")
            table.insert(configs, "-DBUILD_STATIC=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED=OFF")
            table.insert(configs, "-DBUILD_STATIC=ON")
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
