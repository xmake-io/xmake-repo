package("blaze")

    set_kind("library", {headeronly = true})
    set_homepage("https://bitbucket.org/blaze-lib/blaze/")
    set_description("A high performance C++ math library.")
    set_license("BSD-3-Clause")

    add_urls("https://bitbucket.org/blaze-lib/blaze/downloads/blaze-$(version).tar.gz")
    add_versions("3.8", "dfaae1a3a9fea0b3cc92e78c9858dcc6c93301d59f67de5d388a3a41c8a629ae")
    add_versions("3.8.1", "a084c6d1acc75e742a1cdcddf93d0cda0d9e3cc4014c246d997a064fa2196d39")

    add_patches("3.8.0", path.join(os.scriptdir(), "patches", "3.8", "fix-vm-build.patch"), "d6e98c62279ab4b6a93b297e63312b974551e3fcfcd51f613bfebd05e7421cf1")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"none", "mkl", "openblas"}})

    add_deps("cmake")
    on_load("windows|x64", "linux", "macosx", function (package)
        if package:config("blas") == "mkl" then
            package:add("deps", "mkl")
        elseif package:config("blas") == "openblas" then
            package:add("deps", "openblas")
        end
    end)

    on_install("windows|x64", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "BLAS REQUIRED", "BLAS", {plain = true})
        local configs = {}
        if package:config("blas") == "none" then
            table.insert(configs, "-DUSE_LAPACK=OFF")
            table.insert(configs, "-DBLAZE_BLAS_MODE=OFF")
        else
            table.insert(configs, "-DUSE_LAPACK=OFF")
            table.insert(configs, "-DBLAZE_BLAS_MODE=ON")
        end
        if package:config("blas") == "mkl" then
            table.insert(configs, "-DBLAZE_BLAS_INCLUDE_FILE=<mkl_cblas.h>")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                blaze::StaticVector<int,3UL> a{ 4, -2, 5 };
                blaze::DynamicVector<int> b( 3UL );
                b[2] = -3;
                blaze::DynamicVector<int> c = a + b;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "blaze/Math.h"}))
    end)
