package("lightningscanner")

    set_homepage("https://localcc.github.io/LightningScanner/")
    set_description("A lightning-fast memory signature/pattern scanner, capable of scanning gigabytes of data per second.")
    set_license("MIT")

    add_urls("https://github.com/localcc/LightningScanner/archive/refs/tags/$(version).tar.gz",
             "https://github.com/localcc/LightningScanner.git")
    add_versions("v1.0.0", "30052ca62fee13ca28d500802298822ac6d32252")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = { "-DLIGHTNING_SCANNER_INSTALL=ON", "-DLIGHTNING_SCANNER_BUILD_BENCH=OFF", "-DLIGHTNING_SCANNER_BUILD_DOCS=OFF", "-DLIGHTNING_SCANNER_BUILD_TESTS=OFF" }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <LightningScanner/LightningScanner.hpp>

            void test() {
                auto scanner = LightningScanner::Scanner("4b ac ?? ef");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
