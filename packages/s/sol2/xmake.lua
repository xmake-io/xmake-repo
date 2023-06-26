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
            if package:version() and package:version():ge("3.3") then
                package:add("deps", "lua >=5.4")
            else
                package:add("deps", "lua")
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("includes_lua") then
            if package:version() and package:version():ge("3.3") then
                table.insert(configs, "-DSOL2_BUILD_LUA=FALSE")
                local lua = package:dep("lua"):fetch()
                if lua then
                    local includedirs = lua.includedirs or lua.sysincludedirs
                    if includedirs and #includedirs > 0 then
                        table.insert(configs, "-DLUA_INCLUDE_DIR=" .. table.concat(includedirs, " "))
                    end
                    local libfiles = lua.libfiles
                    if libfiles then
                        table.insert(configs, "-DLUA_LIBRARIES=" .. table.concat(libfiles, " "))
                    end
                end
            end
        end
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
