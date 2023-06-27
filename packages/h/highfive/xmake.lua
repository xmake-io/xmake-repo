package("highfive")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/BlueBrain/HighFive")
    set_description("HighFive - Header-only C++ HDF5 interface")

    add_urls("https://github.com/BlueBrain/HighFive/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BlueBrain/HighFive.git")

    add_versions("v2.6.1", "b5002c1221cf1821e02fb2ab891b0160bac88b43f56655bd844a472106ca3397")
    add_versions("v2.3.1", "41728a1204bdfcdcef8cbc3ddffe5d744c5331434ce3dcef35614b831234fcd7")

    add_patches("v2.6.1", path.join(os.scriptdir(), "patches", "fix-find-hdf5.patch"), "6a37e12f1796394d7691b36561829bf220336ec42a736c103509ac93537a36c9")
    add_patches("v2.3.1", path.join(os.scriptdir(), "patches", "fix-find-hdf5.patch"), "6a37e12f1796394d7691b36561829bf220336ec42a736c103509ac93537a36c9")

    add_deps("cmake")
    add_deps("hdf5")

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DHIGHFIVE_UNIT_TESTS=OFF",
                         "-DHIGHFIVE_EXAMPLES=OFF",
                         "-DHIGHFIVE_BUILD_DOCS=OFF",
                         "-DHIGHFIVE_USE_BOOST=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <highfive/H5File.hpp>
        using namespace HighFive;
        void test() {
            File file("/tmp/new_file.h5", File::ReadWrite | File::Create | File::Truncate);
            std::vector<int> data(50, 1);
            DataSet dataset = file.createDataSet<int>("/dataset_one",  DataSpace::From(data));
            dataset.write(data);
        }
        ]]}, {configs = {languages = "c++17"}}))
    end)
