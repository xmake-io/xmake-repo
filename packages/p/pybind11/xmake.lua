package("pybind11")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/pybind/pybind11")
    set_description("Seamless operability between C++11 and Python.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pybind/pybind11/archive/$(version).zip",
             "https://github.com/pybind/pybind11.git")
    add_versions("v2.5.0", "1859f121837f6c41b0c6223d617b85a63f2f72132bae3135a2aa290582d61520")
    add_versions("v2.6.2", "0bdb5fd9616fcfa20918d043501883bf912502843d5afc5bc7329a8bceb157b3")
    add_versions("v2.7.1", "350ebf8f4c025687503a80350897c95d8271bf536d98261f0b8ed2c1a697070f")
    add_versions("v2.8.1", "90907e50b76c8e04f1b99e751958d18e72c4cffa750474b5395a93042035e4a3")
    add_versions("v2.9.1", "ef9e63be55b3b29b4447ead511a7a898fdf36847f21cec27a13df0db051ed96b")
    add_versions("v2.9.2", "d1646e6f70d8a3acb2ddd85ce1ed543b5dd579c68b8fb8e9638282af20edead8")
    add_versions("v2.10.0", "225df6e6dea7cea7c5754d4ed954e9ca7c43947b849b3795f87cb56437f1bd19")

    add_deps("cmake", "python 3.x")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package, {"-DPYBIND11_TEST=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <pybind11/pybind11.h>
            int add(int i, int j) {
                return i + j;
            }
            PYBIND11_MODULE(example, m) {
                m.def("add", &add, "A function which adds two numbers");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
