package("gulrak-filesystem")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gulrak/filesystem")
    set_description("An implementation of C++17 std::filesystem for C++11 /C++14/C++17/C++20 on Windows, macOS, Linux and FreeBSD.")
    set_license("MIT")

    add_urls("https://github.com/gulrak/filesystem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gulrak/filesystem.git")

    add_versions("v1.5.14", "e783f672e49de7c5a237a0cea905ed51012da55c04fbacab397161976efc8472")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DGHC_FILESYSTEM_BUILD_TESTING=OFF",
            "-DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF",
            "-DGHC_FILESYSTEM_WITH_INSTALL=ON",
            "-DGHC_FILESYSTEM_BUILD_STD_TESTING=OFF"
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto exists = ghc::filesystem::exists("output_dir");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ghc/filesystem.hpp"}))
    end)
