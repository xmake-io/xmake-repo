package("frozenca-btree")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/frozenca/BTree")
    set_description("A general-purpose high-performance lightweight STL-like modern C++ B-Tree")
    set_license("Apache-2.0")

    add_urls("https://github.com/frozenca/BTree.git")
    add_versions("2022.08.02", "c2318e18194018f092c3e30ddd7385a50216b3a0")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
                #include "fc_btree.h"
                #include <iostream>
                #include <string>

                static void test() {
                    namespace fc = frozenca;
                    fc::BTreeSet<int> btree;

                    btree.insert(3);
                    btree.insert(4);
                }
            ]]
        }, {configs = {languages = "c++20"}}))
    end)
