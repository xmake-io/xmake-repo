package("ndarray")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ndarray/ndarray")
    set_description("NumPy-friendly multidimensional arrays in C++")

    set_urls("https://github.com/ndarray/ndarray/archive/refs/tags/$(version).tar.gz")
    add_versions("1.6.4", "a125dfcb3c5bdfd1ef9055cd4f2c3de60ad02abc53279dd25e28d155e786ebe0")

    add_deps("boost")

    on_install("macosx", "linux", "windows", "mingw", "cross", "bsd", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ndarray.h>
            #include <cassert>
            static void test() {
                using namespace ndarray;
                Array<double,3,3> a = allocate(makeVector(5,6,8));
                for (Array<double,3,3>::Iterator i = a.begin(); i != a.end(); ++i) {
                    for (Array<double,3,3>::Reference::Iterator j = i->begin(); j != i->end(); ++j) {
                        for (Array<double,3,3>::Reference::Reference::Iterator k = j->begin(); k != j->end(); ++k) {
                            assert(*k == a[i - a.begin()][j - i->begin()][k - j->begin()]);
                        }
                    }
                }
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
