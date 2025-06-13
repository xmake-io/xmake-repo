package("taocpp-json")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/taocpp/json")
    set_description("C++ header-only JSON library")
    set_license("MIT")

    add_urls("https://github.com/taocpp/json.git", {submodules = false})
    add_versions("2025.03.11", "11a31e12eda35c1322f9cf6ebb4cca0653d579dc")

    add_deps("cmake")
    add_deps("pkgconf")
    add_deps("pegtl 54a2e32bf4593ed86782b4882702286cc8d621f9")

    on_install(function (package)
        io.replace("CMakeLists.txt",
            [[find_package(pegtl ${TAOCPP_JSON_PEGTL_MIN_VERSION} QUIET CONFIG)]], [[include(FindPkgConfig)
pkg_check_modules(pegtl REQUIRED pegtl)]], {plain = true})
        io.replace("CMakeLists.txt",
            [[target_link_libraries(taocpp-json INTERFACE taocpp::pegtl)]],
            [[target_include_directories(taocpp-json PRIVATE ${pegtl_INCLUDE_DIRS})]], {plain = true})
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
