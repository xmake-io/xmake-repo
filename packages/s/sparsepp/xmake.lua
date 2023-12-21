package("sparsepp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/greg7mdp/sparsepp")
    set_description("A fast, memory efficient hash map for C++")

    add_urls("https://github.com/greg7mdp/sparsepp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/greg7mdp/sparsepp.git")
    add_versions("1.22", "5516c814fe56c692aaa36f49e696f4a6292f04b5ae79f4ab7bd121e2cc48b917")

    on_install("linux", "macosx", "bsd", "windows", "android", "iphoneos", "cross", "mingw", function (package)
        os.cp("sparsepp/*.h", package:installdir("include/sparsepp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                spp::sparse_hash_set<int> test;
                test.clear();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"sparsepp/spp.h"}}))
    end)
