package("h5cpp")
    set_homepage("https://ess-dmsc.github.io/h5cpp/")
    set_description("C++ wrapper for the HDF5 C-library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/ess-dmsc/h5cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ess-dmsc/h5cpp.git")
    add_versions("v0.5.1", "8fcab57ffbc2d799fe315875cd8fcf67e8b059cccc441ea45a001c03f6a9fd25")

    add_patches("v0.5.1", path.join(os.scriptdir(), "patches", "fix-find-hdf5.patch"), "30e9db5786cc3fba4202c64880ef0009dc77affa15154355803b96cf12948c95")

    add_deps("cmake")
    add_deps("zlib")

    on_load(function (package)
        package:add("deps", "hdf5", { configs = {shared = package:config("shared")} })
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.rm("cmake/FindHDF5.cmake")
        local configs = {
            "-DH5CPP_WITH_BOOST=OFF",
            "-DH5CPP_CONAN=DISABLE",
            "-DH5CPP_DISABLE_TESTS=ON",
            "-DH5CPP_BUILD_DOCS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DH5CPP_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "hdf5"})
        package:addenv("PATH", package:installdir("bin"))
    end)

    -- on_test(function (package)
    --     assert(package:check_cxxsnippets({test = [[
    --         void test() {
    --             auto type = hdf5::datatype::TypeTrait<int>::create();
    --         }
    --     ]]}, {configs = {languages = "c++17"}, includes = {"h5cpp/hdf5.hpp"}}))
    -- end)
