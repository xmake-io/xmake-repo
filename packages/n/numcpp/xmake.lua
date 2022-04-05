package("numcpp")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/dpilger26/NumCpp")
    set_description("C++ implementation of the Python Numpy library")
    set_license("MIT")

    add_urls("https://github.com/dpilger26/NumCpp/archive/refs/tags/Version_$(version).tar.gz",
             "https://github.com/dpilger26/NumCpp.git")
    add_versions("2.4.2", "8da0494552796b76e5e9ef691176fa7cb27bc52fec4019da20bfd8fb7ba00b91")

    add_deps("cmake")
    add_deps("boost")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nc::NdArray<int> a0 = {{1, 2}, {3, 4}};
                nc::NdArray<int> a1 = {{1, 2}, {3, 4}, {5, 6}};
                a1.reshape(2, 3);
                auto a2 = a1.astype<double>();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "NumCpp.hpp"}))
    end)
