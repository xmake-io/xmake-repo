package("highfive")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/BlueBrain/HighFive")
    set_description("HighFive - Header-only C++ HDF5 interface")
    set_license("BSL-1.0")

    add_urls("https://github.com/BlueBrain/HighFive/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BlueBrain/HighFive.git")

    add_versions("v2.10.1", "60d66ba1315730494470afaf402bb40300a39eb6ef3b9d67263335a236069cce")
    add_versions("v2.10.0", "c29e8e1520e7298fabb26545f804e35bb3af257005c1c2df62e39986458d7c38")
    add_versions("v2.9.0", "6301def8ceb9f4d7a595988612db288b448a3c0546f6c83417dab38c64994d7e")
    add_versions("v2.6.1", "b5002c1221cf1821e02fb2ab891b0160bac88b43f56655bd844a472106ca3397")
    add_versions("v2.3.1", "41728a1204bdfcdcef8cbc3ddffe5d744c5331434ce3dcef35614b831234fcd7")

    add_patches("v2.6.1", path.join(os.scriptdir(), "patches", "fix-find-hdf5.patch"), "6a37e12f1796394d7691b36561829bf220336ec42a736c103509ac93537a36c9")
    add_patches("v2.3.1", path.join(os.scriptdir(), "patches", "fix-find-hdf5.patch"), "6a37e12f1796394d7691b36561829bf220336ec42a736c103509ac93537a36c9")

    add_deps("cmake")
    add_deps("hdf5")

    on_install("windows", "macosx", "linux", function (package)
        if package:version():eq("2.9.0") then
            io.replace("CMake/HighFiveTargetDeps.cmake", "find_package(HDF5 REQUIRED)", "find_package(HDF5 REQUIRED HINTS ${HDF5_ROOT})", {plain = true})
        end

        local configs = {"-DHIGHFIVE_UNIT_TESTS=OFF",
                         "-DHIGHFIVE_EXAMPLES=OFF",
                         "-DHIGHFIVE_BUILD_DOCS=OFF",
                         "-DHIGHFIVE_USE_BOOST=OFF"}
        local hdf5 = package:dep("hdf5")
        if hdf5 and not hdf5:is_system() then
            table.insert(configs, "-DHDF5_ROOT=" .. hdf5:installdir())
        end
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
