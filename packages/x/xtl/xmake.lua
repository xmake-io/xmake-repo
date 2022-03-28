package("xtl")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/xtensor-stack/xtl/")
    set_description("Basic tools (containers, algorithms) used by other quantstack packages")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xtensor-stack/xtl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xtensor-stack/xtl.git")
    add_versions("0.7.2", "95c221bdc6eaba592878090916383e5b9390a076828552256693d5d97f78357c")
    add_versions("0.7.3", "f4a81e3c9ca9ddb42bd4373967d4859ecfdca1aba60b9fa6ced6c84d8b9824ff")
    add_versions("0.7.4", "3c88be0e696b64150c4de7a70f9f09c00a335186b0b0b409771ef9f56bca7d9a")

    add_deps("cmake")
    add_deps("nlohmann_json")
    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                xtl::xcomplex<double> c0;
                xtl::xcomplex<double> c1(1.);
                xtl::xcomplex<double> c2(1., 2.);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "xtl/xcomplex.hpp"}))
    end)
