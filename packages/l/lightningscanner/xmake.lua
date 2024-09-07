package("lightningscanner")
    set_homepage("https://localcc.github.io/LightningScanner/")
    set_description("A lightning-fast memory signature/pattern scanner, capable of scanning gigabytes of data per second.")
    set_license("MIT")

    add_urls("https://github.com/localcc/LightningScanner/archive/refs/tags/$(version).tar.gz",
             "https://github.com/localcc/LightningScanner.git")

    add_versions("v1.0.2", "09d2f0d8b84e64542bce6096922efb8c7a6683038f2f11321931928a815055ac")
    add_versions("v1.0.0", "747ec772a9068c9818c174ab46f9900e105d3550820c0afa7ba6f38341779c01")

    add_deps("cmake")

    on_install("windows|x64", "windows|x86", "linux", "macosx|x86_64", "bsd", function (package)
        local configs = { "-DLIGHTNING_SCANNER_INSTALL=ON", "-DLIGHTNING_SCANNER_BUILD_BENCH=OFF", "-DLIGHTNING_SCANNER_BUILD_DOCS=OFF", "-DLIGHTNING_SCANNER_BUILD_TESTS=OFF" }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
