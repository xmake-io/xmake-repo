package("hookmanager")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cngege/HookManager")
    set_description("A header_only HookManager lib for C++.")
    set_license("MIT")

    add_urls("https://github.com/cngege/HookManager/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cngege/HookManager.git")

    add_versions("v0.3.2", "35f4e658182bfe8d70eaab6af15fee6b182367e0cc7a7163c49ddb1c64024183")

    add_configs("lighthook", {description = "Use lighthook as the underlying hook executor.", default = true, type = "boolean"})
    add_configs("minhook", {description = "Use minhook as the underlying hook executor.", default = false, type = "boolean"})
    add_configs("detours", {description = "Use detours as the underlying hook executor.", default = false, type = "boolean"})

    on_load("windows|x64", function (package)
        if package:config("lighthook") then
            package:add("deps", "lighthook")
            package:add("defines", "USE_LIGHTHOOK")
        elseif package:config("minhook") then
            package:add("deps", "minhook")
            package:add("defines", "USE_MINHOOK")
        elseif package:config("detours") then
            package:add("deps", "microsoft-detours")
            package:add("defines", "USE_DETOURS")
        end
    end)

    on_install("windows|x64", function (package)
        os.cp("include/HookManager/HookManager.hpp", package:installdir("include/HookManager"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "HookManager/HookManager.hpp"
            void test() {
                auto* h = HookManager::getInstance();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
