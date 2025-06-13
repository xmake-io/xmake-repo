package("blobify")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/neobrain/blobify")
    set_description("C++17 library for all your binary de-/serialization needs")
    set_license("BSL-1.0")

    add_urls("https://github.com/neobrain/blobify.git", {submodules = false})
    add_versions("2023.12.07", "bcd0ad8eb7f67dafe6e01bf0b6a13d28876dcf59")

    add_deps("cmake")
    add_deps("boost_pfr", "magic_enum")

    on_install(function (package)
        io.replace("include/blobify/load.hpp", [[#include <magic_enum.hpp>]], [[#include <magic_enum/magic_enum.hpp>
#include <algorithm>]], {plain = true})
        io.replace("CMakeLists.txt", [[find_package(magic_enum REQUIRED)]], [[find_package(magic_enum CONFIG REQUIRED)]], {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <blobify/blobify.hpp>
            #include <blobify/stream_storage.hpp>
            #include <fstream>
            void test() {
                std::ifstream file("/path/to/bitmap.bmp");
                blob::istream_storage storage { file };
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
