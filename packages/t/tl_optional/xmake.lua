package("tl_optional")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/TartanLlama/optional")
    set_description("C++11/14/17 std::optional with functional-style extensions and support for references.")
    set_license("CC0")

    set_urls("https://github.com/TartanLlama/optional/archive/refs/tags/$(version).zip",
             "https://github.com/TartanLlama/optional.git")

    add_versions("v1.1.0", "a336bb10f51945369c1dd6dc6d2a7086602ab9cab52c98a7a6224bfd782bc0c7")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DOPTIONAL_BUILD_PACKAGE=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                tl::optional<int> e1 = 42;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"tl/optional.hpp"}}))
    end)

