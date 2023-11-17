package("autodiff")

    set_kind("library", {headeronly = true})
    set_homepage("https://autodiff.github.io")
    set_description("automatic differentiation made easier for C++")
    set_license("MIT")

    add_urls("https://github.com/autodiff/autodiff/archive/refs/tags/$(version).tar.gz",
             "https://github.com/autodiff/autodiff.git")

    add_versions("v1.0.3", "21b57ce60864857913cacb856c3973ae10f7539b6bb00bcc04f85b2f00db0ce2")

    add_deps("cmake", "eigen")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs =
        {
            "-DAUTODIFF_BUILD_TESTS=OFF",
            "-DAUTODIFF_BUILD_PYTHON=OFF",
            "-DAUTODIFF_BUILD_EXAMPLES=OFF",
            "-DAUTODIFF_BUILD_DOCS=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <autodiff/forward/dual.hpp>
            using namespace autodiff;
            void test() {
                dual x = 1.0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
