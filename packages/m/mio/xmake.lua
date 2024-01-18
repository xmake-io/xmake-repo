package("mio")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mandreyel/mio")
    set_description("Cross-platform C++11 header-only library for memory mapped file IO")
    set_license("MIT")

    add_urls("https://github.com/mandreyel/mio.git")
    add_versions("2021.9.21", "3f86a95c0784d73ce6815237ec33ed25f233b643")
    add_versions("2023.3.3", "8b6b7d878c89e81614d05edca7936de41ccdd2da")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "bsd", "iphoneos", "android", function (package)
        import("package.tools.cmake").install(package, {"-Dmio.tests=OFF"})
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({
            test = [[
              #include <string>
              #include <vector>
              #include <algorithm>
              #include <mio/mmap.hpp>

              static void test() {
                mio::mmap_source mmap(mio::invalid_handle, 0, mio::map_entire_file);
              }
            ]]
        }, {configs = {languages = "c++11"}}))
    end)
