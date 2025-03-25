package("woff2")
    set_homepage("https://github.com/google/woff2")
    set_description("Font compression reference code.")
    set_license("MIT")

    add_urls("https://github.com/google/woff2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/woff2.git")

    add_versions("v1.0.2", "add272bb09e6384a4833ffca4896350fdb16e0ca22df68c0384773c67a175594")

    add_deps("cmake", "brotli")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"brotli", "brotlienc", "brotlidec"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <woff2/output.h>
            void test() {
                uint8_t *ttf = new uint8_t[1024];
                woff2::WOFF2MemoryOut out(ttf, 1024);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
