package("pybind11")

    set_homepage("https://github.com/pybind/pybind11")
    set_description("Seamless operability between C++11 and Python.")

    add_urls("https://github.com/pybind/pybind11/archive/$(version).zip",
             "https://github.com/pybind/pybind11.git")
    add_versions("v2.5.0", "1859f121837f6c41b0c6223d617b85a63f2f72132bae3135a2aa290582d61520")
    add_versions("v2.6.2", "0bdb5fd9616fcfa20918d043501883bf912502843d5afc5bc7329a8bceb157b3")

    add_deps("cmake", "python 3.x")

    on_install(function (package)
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
