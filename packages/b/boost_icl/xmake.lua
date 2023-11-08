package("boost_icl")
    set_kind("library", {headeronly = true})
    set_homepage("http://boost.org/libs/icl")
    set_description("icl: Boost interval container library")

    add_urls("https://github.com/boostorg/icl/archive/refs/tags/boost-$(version).tar.gz")

    add_versions("1.83.0", "c36fe676d8785f1d884014394d29f3f41ccecabc")

    add_deps("boost_assert")
    
    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/icl/interval_set.hpp>
            
            void test() {
                boost::icl::interval_set<int> mySet;
                mySet.insert(42);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
