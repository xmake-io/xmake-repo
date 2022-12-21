package("sol2")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ThePhD/sol2")
    set_description("A C++ library binding to Lua.")

    set_urls("https://github.com/ThePhD/sol2/archive/$(version).tar.gz",
             "https://github.com/ThePhD/sol2.git")

    add_versions("v3.3.0", "b82c5de030e18cb2bcbcefcd5f45afd526920c517a96413f0b59b4332d752a1e")
    add_versions("v3.2.3", "f74158f92996f476786be9c9e83f8275129bb1da2a8d517d050421ac160a4b9e")
    add_versions("v3.2.2", "141790dae0c1821dd2dbac3595433de49ba72545845efc3ec7d88de8b0a3b2da")
    add_versions("v3.2.1", "b10f88dc1246f74a10348faef7d2c06e2784693307df74dcd87c4641cf6a6828")

    add_configs("includes_lua", {description = "Should this package includes the Lua package (set to false if you're shipping a custom Lua)", default = true, type = "boolean"})
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::sol2")
    elseif is_plat("linux") then
        add_extsources("pacman::sol2")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("includes_lua") then
            package:add("deps", "lua")
        end
    end)

    on_install(function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("includes_lua") then
            assert(package:check_cxxsnippets({test = [[
                #include <sol/sol.hpp>
                #include <cassert>
                void test() {
                    sol::state lua;
                    int x = 0;
                    lua.set_function("beep", [&x]{ ++x; });
                    lua.script("beep()");
                    assert(x == 1);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
