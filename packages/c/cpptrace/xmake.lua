package("cpptrace")
    set_homepage("https://github.com/jeremy-rifkin/cpptrace")
    set_description("Lightweight, zero-configuration-required, and cross-platform stacktrace library for C++")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/cpptrace.git")

    add_versions("v0.1", "244bdf092ba7b9493102b8bb926be4ab355c40d773d4f3ee2774ccb761eb1dda")
    add_versions("v0.3.1", "3c4c5b3406c2b598e5cd2a8cb97f9e8e1f54d6df087a0e62564e6fb68fed852d")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("dbghelp")
    elseif is_plat("linux", "macosx") then
        add_deps("libdwarf")
    elseif is_plat("mingw") then
        add_deps("libdwarf")
        add_syslinks("dbghelp")
    end

    on_install("linux", "macosx", "windows", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        package:add("links", "cpptrace")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                cpptrace::generate_trace().print();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"cpptrace/cpptrace.hpp"}}))
    end)
