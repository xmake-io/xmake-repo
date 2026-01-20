package("ordered_map")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Tessil/ordered-map")
    set_description("C++ hash map and hash set which preserve the order of insertion")
    set_license("MIT")

    set_urls("https://github.com/Tessil/ordered-map/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tessil/ordered-map.git")

    add_versions("v1.2.0", "3053e2d62db8a158c5941b75dacf397e1c695cd99dda4db78a32af76f4523423")
    add_versions("v1.1.0", "d6070502351646d68f2bbe6078c0da361bc1db733ee8a392e33cfb8b31183e28")
    add_versions("v1.0.0", "49cd436b8bdacb01d5f4afd7aab0c0d6fa57433dfc29d65f08a5f1ed1e2af26b")

    on_install(function (package)
        os.cp("include/tsl", package:installdir("include"))
        os.cp("tsl-ordered-map.natvis", package:installdir("include", "tsl"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test()
            {
                tsl::ordered_map<char, int> map = {{'d', 1}, {'a', 2}, {'g', 3}};
                map.insert({'b', 4});
                map['h'] = 5;
                map['e'] = 6;
                map.erase('a');

                // {d, 1} {g, 3} {b, 4} {h, 5} {e, 6}
                for(const auto& key_value : map) {
                    std::cout << "{" << key_value.first << ", " << key_value.second << "}" << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++14"}, includes = { "tsl/ordered_map.h"} }))
    end)
