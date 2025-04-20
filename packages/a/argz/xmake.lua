package("argz")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/argz")
    set_description("A light weight C++ in memory argument parser")
    set_license("Apache-2.0")

    add_urls("https://github.com/stephenberry/argz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/argz.git")

    add_versions("v0.2.1", "1a9d85ef7e4722f81ce426c2cf8ceaa0a10cc42e7762cdf2465ae6484ece9c7e")

    add_includedirs("include/argz")

    add_deps("cmake")

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/Zc:preprocessor", "/GL", "/permissive-", "/Zc:lambda")
        end
        io.replace("CMakeLists.txt", "include(cmake/dev-mode.cmake)", "", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                constexpr std::string_view version = "1.2.3";
                argz::about about{ "My program description", version };
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"argz/argz.hpp"}}))
    end)
