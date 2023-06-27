package("cpp-lazy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/MarcDirven/cpp-lazy")
    set_description("A fast C++11/14/17/20 header only library for lazy evaluation and function tools")
    
    set_urls("https://github.com/MarcDirven/cpp-lazy/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/MarcDirven/cpp-lazy.git")

    add_versions("v7.0.2", "7a5c2a42ce5c98343676d09761959b9821ec125dbff7b9f2028792c117de0b09")

    add_deps("fmt")

    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
        void test() {
            int arr[]{1, 2, 3, 4};
            auto mapper{lz::map(arr, [](const int i) { return i + 1; })};
        }
    ]]}, {includes = "Lz/Map.hpp", configs = {languages = "c++11"}}))
    end)
