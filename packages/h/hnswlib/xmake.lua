package("hnswlib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nmslib/hnswlib")
    set_description("Header-only C++/python library for fast approximate nearest neighbors")
    set_license("Apache-2.0")

    add_urls("https://github.com/nmslib/hnswlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nmslib/hnswlib.git")

    add_versions("v0.9.0", "65dfb6639cb7d1acbdaeec1429b978fb657a9bf368ebb8353109167394537823")

    on_install(function (package)
        os.cp("hnswlib", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                hnswlib::L2Space space(4);
                hnswlib::HierarchicalNSW<float> index(&space, 100, 16, 200);
                float data[4] = {1.f, 2.f, 3.f, 4.f};
                index.addPoint(data, 0);
                auto result = index.searchKnn(data, 1);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "hnswlib/hnswlib.h"}))
    end)
