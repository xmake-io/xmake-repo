package("libnpy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/llohse/libnpy")
    set_description("C++ library for reading and writing of numpy's .npy files")
    set_license("MIT")

    add_urls("https://github.com/llohse/libnpy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/llohse/libnpy.git")

    add_versions("v1.0.1", "43452a4db1e8c1df606c64376ea1e32789124051d7640e7e4e8518ab4f0fba44")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <string>
            #include <npy.hpp>
            void test() {
                const std::string path {"data.npy"};
                npy::npy_data d = npy::read_npy<double>(path);
                std::vector<double> data = d.data;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
