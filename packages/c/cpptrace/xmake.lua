package("cpptrace")
    set_homepage("https://github.com/jeremy-rifkin/cpptrace")
    set_description("Lightweight, zero-configuration-required, and cross-platform stacktrace library for C++")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/cpptrace/-/archive/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/cpptrace.git")

    add_versions("v0.1", "411bf19e079b550c50e6d39c82e3cb8d4a7dd2e9a8107a8f1843929c4b4e63de")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("dbghelp")
    end

    on_install("linux", "macosx", "windows", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                cpptrace::print_trace();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"cpptrace/cpptrace.hpp"}}))
    end)
