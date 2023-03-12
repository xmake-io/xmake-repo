package("type_safe")
    set_kind("library", {headeronly = true})
    set_homepage("https://type_safe.foonathan.net")
    set_description("Zero overhead utilities for preventing bugs at compile time")
    set_license("MIT")

    add_urls("https://github.com/foonathan/type_safe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/foonathan/type_safe.git")
    add_versions("v0.2.2", "34d97123fb9bca04a333565c4a2498425d602ec0c759de4be1b8cfae77d05823")

    add_deps("cmake", "debug_assert")

    on_install(function (package)
        io.replace("CMakeLists.txt", [[ OR (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)]], "", { plain = true })
        local configs = {"-DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void only_unsigned(type_safe::unsigned_t val)
            {
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"type_safe/types.hpp"}}))
    end)
