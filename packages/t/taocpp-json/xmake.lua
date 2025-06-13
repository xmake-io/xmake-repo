package("taocpp-json")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/taocpp/json")
    set_description("C++ header-only JSON library")
    set_license("MIT")

    add_urls("https://github.com/taocpp/json.git")
    add_versions("2025.03.11", "11a31e12eda35c1322f9cf6ebb4cca0653d579dc")

    add_deps("cmake")
    add_deps("pegtl 54a2e32bf4593ed86782b4882702286cc8d621f9")

    on_install(function (package)
        local configs = {
            "-DTAOCPP_JSON_BUILD_TESTS=OFF",
            "-DTAOCPP_JSON_BUILD_EXAMPLES=OFF",
            "-DTAOCPP_JSON_BUILD_PERFORMANCE=OFF",
            "-DTAOCPP_JSON_INSTALL=ON"
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tao/json.hpp>
            void test() {
                const tao::json::value v = tao::json::from_file( "filename.json" );
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
