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
    
    add_configs("python", {description = "Python version.", default = "python 3.x", type = "string"})

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", package:config("python"))
    end)

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
