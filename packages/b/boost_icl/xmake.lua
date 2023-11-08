package("boost_icl")
    set_kind("library", {headeronly = true})
    set_homepage("http://boost.org/libs/icl")
    set_description("icl: Boost interval container library")

    add_urls("https://github.com/boostorg/icl/archive/refs/tags/boost-$(version).zip",
             "https://github.com/boostorg/icl/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/icl.git")

    add_versions("v1.83.0", "e6c06ddee1e2320f11c4ec5cd2661c4abe9bca53")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/icl/interval_set.hpp>
            
            void test() {
                interval_set<int> mySet;
                mySet.insert(42);
                bool has_answer = contains(mySet, 42);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
