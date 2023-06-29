package("hopscotch-map")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tessil/hopscotch-map")
    set_description("A C++ implementation of a fast hash map and hash set using hopscotch hashing")

    set_urls("https://github.com/Tessil/hopscotch-map/archive/$(version).zip",
             "https://github.com/Tessil/hopscotch-map.git")

    add_versions("v2.3.1", "0a77f4835379e74bb7a1c043f3b3c498272acca1c70b03dd5a0444fddf28b316")
    add_versions("v2.3.0", "56ce4ff67215656065ee1a08948533baf9447c4440196ea5133c024856006938")

    on_install(function (package)
        os.cp("include/tsl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                tsl::hopscotch_map<int, int> map;
                map[1] = 3;
                map[2] = 4;

                tsl::hopscotch_set<int> set;
                set.insert({1, 9, 0});
                set.insert({2, -1, 9});
            }
        ]]}, {configs = {languages = "c++11"}, includes = { "tsl/hopscotch_map.h", "tsl/hopscotch_set.h"} }))
    end)
