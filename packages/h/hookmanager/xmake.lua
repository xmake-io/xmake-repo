package("hookmanager")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/cngege/HookManager")
    set_description("A header_only HookManager lib for C++.")
    set_license("MIT")

    add_urls("https://github.com/cngege/HookManager/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cngege/HookManager.git")

    add_versions("v0.3.1", "783dfc861232bf6f00ca7e626f38ab19eebc5833dba8344c1cdfcaf20ab28bb9")
	
	add_configs("use_lighthook", {description = "Use lighthook as the underlying hook executor.", default = false, type = "boolean"})
    add_configs("use_minhook", {description = "Use minhook as the underlying hook executor.", default = false, type = "boolean"})
    add_configs("use_detours", {description = "Use detours as the underlying hook executor.", default = false, type = "boolean"})
    
	
    on_load(function (package)
        if package:config("use_lighthook") then
            package:add("deps", "lighthook")
			package:add("defines", "USE_LIGHTHOOK")
        elseif package:config("use_minhook") then
            package:add("deps", "minhook")
			package:add("defines", "USE_MINHOOK")
		elseif package:config("use_detours") then
			package:add("deps", "microsoft-detours")
			package:add("defines", "USE_DETOURS")
        end
    end)
	
	on_install("windows", function (package)
        os.cp("HookManager/HookManager.hpp", package:installdir("include","HookManager"))
    end)

    on_test(function (package)
		package:add("deps", "lighthook")
		package:add("defines", "USE_LIGHTHOOK")
        assert(package:check_cxxsnippets({test = [[
            void test() {
                HookInstance* h = HookManager::getInstance();
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"HookManager/HookManager.hpp"}}))
    end)
