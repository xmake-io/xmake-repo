package("h5cpp")
    set_homepage("https://ess-dmsc.github.io/h5cpp/")
    set_description("C++ wrapper for the HDF5 C-library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/ess-dmsc/h5cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ess-dmsc/h5cpp.git")

    add_versions("v0.8.0", "cc0bb662c2eb5abc10185ccd86e3a7f68aa2463f02a8ecef570a1c9de508f87b")
    add_versions("v0.7.1", "e832fb729aaf328d0f30b34e577645f33fdaccda0e1b0c06cb9a3d412a728ad3")
    add_versions("v0.6.0", "72b459c92670628d730b3386fe6f4ac61218885afa904f234a181c2022a9f56f")
    add_versions("v0.5.1", "8fcab57ffbc2d799fe315875cd8fcf67e8b059cccc441ea45a001c03f6a9fd25")

    add_patches(">=0.5.1 <0.7.1", path.join(os.scriptdir(), "patches", "0.5.1", "fix-find-hdf5.patch"), "25f26ec6994d387571d7c068ba0405a34db45480a9c17fe3ea6402042e7de87c")
    add_patches(">=0.5.1 <0.8.0", path.join(os.scriptdir(), "patches", "0.5.1", "windows.patch"), "ce79d38e130ae15ba273892306295660446c3e3649e00c742d74c72d3ae0096d")
    add_patches(">=0.8.0", path.join(os.scriptdir(), "patches", "0.8.0", "windows-x86.patch"), "136086d9f956ebbbb46bad1445d670b7e6e842e84f69107dd5f273b048e54ef4")

    add_deps("cmake")
    add_deps("zlib")

    on_load(function (package)
        package:add("deps", "hdf5", { configs = {shared = package:config("shared")} })
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "H5CPP_BUILD_SHARED")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.rm("cmake/FindHDF5.cmake")
        if os.isfile("cmake/BuildInfo.cmake") then
            io.replace("cmake/BuildInfo.cmake", "OUTPUT_STRIP_TRAILING_WHITESPACE)", "OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)", {plain = true})
        end
        local configs = {
            "-DH5CPP_WITH_BOOST=OFF",
            "-DH5CPP_CONAN=DISABLE",
            "-DH5CPP_DISABLE_TESTS=ON",
            "-DH5CPP_BUILD_DOCS=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0074=NEW"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DH5CPP_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHDF5_USE_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
        local hdf5 = package:dep("hdf5")
        if hdf5 and not hdf5:is_system() then
            table.insert(configs, "-DHDF5_ROOT=" .. hdf5:installdir())
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = {"hdf5"}})
        package:addenv("PATH", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto type = hdf5::datatype::TypeTrait<int>::create();
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"h5cpp/hdf5.hpp"}}))
    end)
