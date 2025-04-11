package("manif")
    set_kind("library", {headeronly = true})
    set_homepage("https://artivis.github.io/manif")
    set_description("A small C++11 header-only library for Lie theory.")
    set_license("MIT")

    add_urls("https://github.com/artivis/manif/archive/refs/tags/$(version).tar.gz",
             "https://github.com/artivis/manif.git")

    add_versions("0.0.5", "246a781c54a5c57179d48096faca0d108944e120f69d8fd7fb69e3cb4a0a67fb")

    add_deps("cmake")
    add_deps("eigen", "tl_optional")

    on_install(function (package)
        local configs = {"-DUSE_SYSTEM_WIDE_TL_OPTIONAL=ON"}
        io.replace("CMakeLists.txt", "find_package(tl-optional 1.0.0 QUIET)", "find_package(tl-optional)", {plain = true})
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto state = manif::SE3d::Identity();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"manif/manif.h"}}))
    end)
