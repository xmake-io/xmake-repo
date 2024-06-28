package("ade")
    set_homepage("https://github.com/opencv/ade")
    set_description("ADE Framework is a graph construction, manipulation, and processing framework.")
    set_license("Apache-2.0")

    add_urls("https://github.com/opencv/ade/archive/refs/tags/$(version).tar.gz",
             "https://github.com/opencv/ade.git")

    add_versions("v0.1.2d", "edefba61a33d6cd4b78a9976cb3309c95212610a81ba6dade09882d1794198ff")
    add_versions("v0.1.2", "ac2e6a4acbe6e0b0942418687ec37c6cd55dcaec5112c7ca09abefe6ee539499")

    add_patches("0.1.2", "patches/0.1.2/cmake-mingw.patch", "59ac0ed938b82090e97de6dee358ba683b371908c3063b4d10146999a30eaaaa")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITH_STATIC_CRT=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ade::Graph x;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ade/graph.hpp"}))
    end)
