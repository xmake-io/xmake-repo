package("rsm-mmio")
    set_homepage("https://github.com/Ryan-rsm-McKenzie/mmio")
    set_description("A cross-platform memory-mapped io library for C++")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/mmio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Ryan-rsm-McKenzie/mmio.git")
    add_versions("2.0.0", "360dddf74a97bd0a7eb41378cc59f2a69871dabfd36c55bf027429ac54930d5b")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            target("rsm-mmio")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                add_includedirs("include/")
                add_headerfiles("include/(**.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                mmio::mapped_file_source f;
                assert(!f.is_open());
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"mmio/mmio.hpp", "assert.h"}}))
    end)
