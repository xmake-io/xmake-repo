package("xtensor-io")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtensor-io")
    set_description("xtensor plugin to read and write images, audio files, numpy (compressed) npz and HDF5")
    set_license("BSD-3-Clause")
    add_urls("https://github.com/xtensor-stack/xtensor-io/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtensor-io.git")
    add_versions("0.13.0", "470bedee082adb0ef25ef7b54f9cfd3684e27b8489c42cf7980e0d90c14d04da")

    add_deps("cmake")
    add_deps("xtensor")
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xtensor/xarray.hpp>
            #include <xtensor-io/xio_binary.hpp>
            void test() {
                int freq = 2000;
                int sampling_freq = 44100;
                double duration = 1.0;
                xt::xarray<double> a1 = {0, 1, 2, 3};
                auto t = xt::arange(0.0, duration, 1.0 / sampling_freq);
                auto y = xt::sin(2.0 * xt::numeric_constants<double>::PI * freq * t);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
