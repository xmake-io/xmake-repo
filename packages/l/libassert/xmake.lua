package("libassert")
    set_kind("library")
    set_homepage("https://github.com/jeremy-rifkin/libassert")
    set_description("The most over-engineered and overpowered C++ assertion library.")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/libassert.git")
    add_versions("2023.3.3", "9bd1faa21448953021b54cebce77862be5444b7e")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                DEBUG_ASSERT(1 * 2 == 2, "Test debug assert");
                ASSUME(4 % 2 == 0, "Test assume");
                ASSERT(2 + 2 == 4, "Test assert");
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"assert/assert/assert.hpp"}}))
    end)
