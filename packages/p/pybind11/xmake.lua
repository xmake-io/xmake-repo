package("pybind11")

    set_homepage("https://github.com/pybind/pybind11")
    set_description("Seamless operability between C++11 and Python.")

    set_urls("https://github.com/pybind/pybind11/archive/v$(version).zip",
             "https://github.com/pybind/pybind11.git")

    add_deps("python 3.x")

    add_versions("2.5.0", "1859f121837f6c41b0c6223d617b85a63f2f72132bae3135a2aa290582d61520")

    on_install(function (package)
        os.cp("include", package:installdir())
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
