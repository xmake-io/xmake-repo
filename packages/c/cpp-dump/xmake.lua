package("cpp-dump")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/philip82148/cpp-dump")
    set_description("A C++ library for debugging purposes that can print any variable, even user-defined types.")
    set_license("MIT")

    add_urls("https://github.com/philip82148/cpp-dump/archive/refs/tags/$(version).tar.gz",
             "https://github.com/philip82148/cpp-dump.git")

    add_versions("v0.5.0", "31fa8b03c9ee820525137be28f37b36e2abe7fd91df7d67681cb894db2230fe6")

    on_install(function (package)
        os.cp("hpp", package:installdir("include/cpp-dump"))
        os.cp("dump.hpp", package:installdir("include/cpp-dump"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include "cpp-dump/dump.hpp"
            void test() {
                std::vector<std::vector<int>> my_vector{{3, 5, 8, 9, 7}, {9, 3, 2, 3, 8}};
                cpp_dump(my_vector);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
