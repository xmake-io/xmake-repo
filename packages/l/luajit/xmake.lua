package("luajit")
    set_homepage("http://luajit.org")
    set_description("A Just-In-Time Compiler (JIT) for the Lua programming language.")
    set_license("MIT")

    set_urls("https://github.com/LuaJIT/LuaJIT.git")

    add_versions("v2.1.0-20260109", "707c12bf00dafdfd3899b1a6c36435dbbf6c7022")
    add_versions("v2.1.0-beta3", "8271c643c21d1b2f344e339f559f2de6f3663191")

    add_patches("v2.1.0-20260109", "patches/v2.1.0-20260109/fix-bsd.patch", "e60b6f1ddeaaf503123c025433d1906b3bd3cefbd0237c9170f33a3d535ffb05")

    add_configs("nojit", { description = "Disable JIT.", default = false, type = "boolean"})
    add_configs("fpu",   { description = "Enable FPU.", default = true, type = "boolean"})
    add_configs("gc64",  { description = "Enable GC64.", default = false, type = "boolean"})

    add_includedirs("include", "include/luajit")
    if not is_plat("windows") then
        add_syslinks("dl")
    end

    if on_check then
        on_check(function (package)
            if package:version() then
                if package:version():eq("v2.1.0-beta3") then
                    if package:is_arch("arm.*") then
                        raise("package(luajit/arm64) unsupported arch")
                    end
                end
            end
        end)
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
        if package:config("shared") then
            package:addenv("PATH", "lib")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "android", "iphoneos", function (package)
        local configs = {}
        configs.fpu     = package:config("fpu")
        configs.nojit   = package:config("nojit")
        configs.gc64    = package:config("gc64")
        if package:is_plat("macosx") and not package:is_arch("arm.*") then
            configs.gc64 = true
        end
        if package:version():eq("v2.1.0-beta3") then
            os.cp(path.join(package:scriptdir(), "port", "v2.1.0-beta3", "xmake.lua"), "xmake.lua")
        else
            os.cp(path.join(package:scriptdir(), "port", "v2.1.0-20260109", "xmake.lua"), "xmake.lua")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat(os.host()) and not package:is_cross() then
            os.vrun("luajit -e \"print('hello xmake!')\"")
        end
        assert(package:check_csnippets("int main() { lua_State* L = luaL_newstate(); return 0; }", {includes = {"lua.h", "lauxlib.h", "lualib.h"}}))
    end)
