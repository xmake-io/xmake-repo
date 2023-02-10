package("ghc_filesystem")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gulrak/filesystem")
    set_description("An implementation of C++17 std::filesystem for C++11/C++14/C++17/C++20 on Windows, macOS, Linux and FreeBSD.")
    set_license("MIT")

    add_urls("https://github.com/gulrak/filesystem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gulrak/filesystem.git")
    add_versions("v1.5.10", "9b96a024679807879fdfb30e46e8e461293666aeeee5fbf7f5af75aeacdfea29")
    add_versions("v1.5.12", "7d62c5746c724d28da216d9e11827ba4e573df15ef40720292827a4dfd33f2e9")

    add_deps("cmake")
    on_install(function (package)
        local configs = {"-DGHC_FILESYSTEM_BUILD_TESTING=OFF", "-DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ghc/filesystem.hpp>
            namespace fs = ghc::filesystem;
            void test() {
                fs::path dir{"."};
                for (auto de : fs::directory_iterator(dir)) {
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
