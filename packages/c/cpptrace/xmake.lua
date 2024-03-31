package("cpptrace")
    set_homepage("https://github.com/jeremy-rifkin/cpptrace")
    set_description("Lightweight, zero-configuration-required, and cross-platform stacktrace library for C++")
    set_license("MIT")

    add_urls("https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jeremy-rifkin/cpptrace.git")

    add_versions("v0.5.1", "27b9f862ec6185f570ee59c07fdd12bebb55a986191518e896621317d2654f26")
    add_versions("v0.1", "244bdf092ba7b9493102b8bb926be4ab355c40d773d4f3ee2774ccb761eb1dda")
    add_versions("v0.3.1", "3c4c5b3406c2b598e5cd2a8cb97f9e8e1f54d6df087a0e62564e6fb68fed852d")
    add_versions("v0.4.0", "eef368f5bed2d85c976ea90b325e4c9bfc1b9618cbbfa15bf088adc8fa98ff89")

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
        if not package:config("shared") then
            package:add("defines", "CPPTRACE_STATIC_DEFINE")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local code
        if package:version():le("0.1") then
            code = [[
                void test() {
                    cpptrace::print_trace();
                }
            ]]
        else
            code = [[
                void test() {
                    cpptrace::generate_trace().print();
                }
            ]]
        end

        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++11"}, includes = {"cpptrace/cpptrace.hpp"}}))
    end)
