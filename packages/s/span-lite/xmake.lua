package("span-lite")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/martinmoene/span-lite")
    set_description("span lite - A C++20-like span for C++98, C++11 and later in a single-file header-only library")
    set_license("BSL")

    add_urls("https://github.com/martinmoene/span-lite/archive/refs/tags/v$(version).zip",
             "https://github.com/martinmoene/span-lite.git")
    add_versions("0.10.3", "e9d4facd0c98b12b045de356c6c6c0c06d047d741fe61bde02ca9a68c82d7658")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DSPAN_LITE_OPT_BUILD_TESTS=OFF",
            "-SPAN_LITE_EXPORT_PACKAGE=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            using nonstd::span_lite::span;
            void good( span<int> arr ) {
                for ( size_t i = 0; i != arr.size(); ++i )
                {
                    std::cout << (i==0 ? "[":"") << arr[i] << (i!=arr.size()-1 ? ", ":"]\n");
                }
            }

        ]]}, {configs = {languages = "c++17"}, includes = "nonstd/span.hpp"}))
    end)
