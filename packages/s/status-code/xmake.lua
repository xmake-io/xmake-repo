package("status-code")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ned14/status-code")
    set_description("Proposed SG14 status_code for the C++ standard")
    set_license("Apache-2.0")

    add_urls("https://github.com/ned14/status-code.git", {submodules = false})

    add_versions("2025.05.21", "525e324b1b85fbd1bf74046d760068b7e27b8cda")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #if __has_include(<status-code/system_error2.hpp>)
            #  include <status-code/system_error2.hpp>
            #else
            #  include <system_error2.hpp>
            #endif
            void test() {
                system_error2::system_code sc;
                bool isFailure = sc.failure();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
