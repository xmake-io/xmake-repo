package("libmorton")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Forceflow/libmorton")
    set_description("C++ header-only library with methods to efficiently encode/decode Morton codes in/from 2D/3D coordinates")
    set_license("MIT")

    add_urls("https://github.com/Forceflow/libmorton/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Forceflow/libmorton.git")

    add_versions("v0.2.12", "48ec3e4ad1d9348052dcb64bff012ff95db226da3fec5522ae6e674fabbd686f")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libmorton/morton.h>
            void test() {
                libmorton::morton2D_32_encode(0, 0);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
