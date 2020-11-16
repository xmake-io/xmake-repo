package("sol2")

    set_homepage("https://github.com/ThePhD/sol2")
    set_description("A C++ library binding to Lua.")

    set_urls("https://github.com/ThePhD/sol2/archive/$(version).tar.gz",
             "https://github.com/ThePhD/sol2.git")

    add_versions("v3.2.1", "b10f88dc1246f74a10348faef7d2c06e2784693307df74dcd87c4641cf6a6828")

    add_configs("includes_lua", {description = "Should this package includes the Lua package (set to false if you're shipping a custom Lua)", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("includes_lua") then
            package:add("deps", "lua")
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
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
    end)
