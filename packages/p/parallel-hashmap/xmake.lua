package("parallel-hashmap")

    set_kind("library", {headeronly = true})
    set_homepage("https://greg7mdp.github.io/parallel-hashmap/")
    set_description("A family of header-only, very fast and memory-friendly hashmap and btree containers.")
    set_license("Apache-2.0")

    add_urls("https://github.com/greg7mdp/parallel-hashmap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/greg7mdp/parallel-hashmap.git")
    add_versions("1.33", "f6e4d0508c4d935fa25dcbaec63fbe0d7503435797e275ec109e8a3f1462a4cd")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
              #include <iostream>
              #include <string>
              #include <parallel_hashmap/phmap.h>

              using phmap::flat_hash_map;
              static void test() {
                flat_hash_map<std::string, std::string> email = {
                    { "tom",  "tom@gmail.com"},
                    { "jeff", "jk@gmail.com"},
                    { "jim",  "jimg@microsoft.com"}
                };
                for (const auto& n : email)
                    std::cout << n.first << "'s email is: " << n.second << "\n";
                email["bill"] = "bg@whatever.com";
                std::cout << "bill's email is: " << email["bill"] << "\n";
              }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)
