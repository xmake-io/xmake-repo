package("xtensor-io")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor-io")
    set_description("xtensor plugin to read and write images, audio files, numpy (compressed) npz and HDF5")

    add_urls("https://github.com/xtensor-stack/xtensor-io/archive/refs/tags/$(version).tar.gz",
        "https://github.com/xtensor-stack/xtensor-io.git")

    add_versions("0.3.0", "5b09583942bbe202c235a8b333e4abe8286566862e4663a62793a499c28adc22")

    add_deps("cmake")
    add_deps("xtensor", "openimageio", "zlib", "libsndfile", "highfive", "blosc")

    on_install(function (package)
        local configs = {"-DDOWNLOAD_GBENCHMARK=OFF", 
                         "-DHAVE_OIIO=ON",
                         "-DHAVE_SndFile=ON",
                         "-DHAVE_ZLIB=ON",
                         "-DHAVE_HighFive=ON",
                         "-DHAVE_Blosc=ON",
                         "-DBUILD_TESTS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "xtensor-io/ximage.hpp"
            void test() {
                auto img_arr = xt::load_image("test.png");
                // write xarray out to JPEG image
                xt::dump_image("dumptest.jpg", img_arr + 5);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
