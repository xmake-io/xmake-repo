package("cpp-lazy")
    set_homepage("https://github.com/MarcDirven/cpp-lazy")
    set_description("A fast C++11/14/17/20 header only library for lazy evaluation and function tools")
    
    set_urls("https://github.com/MarcDirven/cpp-lazy/archive/refs/tags/v$(version).zip")

    add_versions("7.0.2", "aced554a828ab8d2c426b9a9cc0a0d576752d83c5a8e77a28506575126c3e40e")

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
    ]]}, {includes = "Lz/Map.hpp"}))
    end)
