package("stduuid")
    set_kind("library")
    set_homepage("https://github.com/mariusbancila/stduuid")
    set_description("A C++17 cross-platform implementation for UUIDs")
    set_license("MIT")

    add_urls("https://github.com/mariusbancila/stduuid/archive/refs/tags/v$(version).zip")
    add_versions("1.2.3", "0f867768ce55f2d8fa361be82f87f0ea5e51438bc47ca30cd92c9fd8b014e84e")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DUUID_BUILD_TESTS=OFF")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "uuid.h"
            using namespace uuids;
            void test() {
                uuid empty;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
