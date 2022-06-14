package("luajit")

    set_homepage("http://luajit.org")
    set_description("A Just-In-Time Compiler (JIT) for the Lua programming language.")

    set_urls("http://luajit.org/download/LuaJIT-$(version).tar.gz",
             "https://github.com/LuaJIT/LuaJIT.git",
             "http://luajit.org/git/luajit-2.0.git",
             "http://repo.or.cz/luajit-2.0.git")

    add_versions("2.1.0-beta3", "1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3")

    add_configs("nojit", { description = "Disable JIT.", default = false, type = "boolean"})
    add_configs("fpu",   { description = "Enable FPU.", default = true, type = "boolean"})
    add_configs("gc64",  { description = "Enable GC64.", default = false, type = "boolean"})

    add_includedirs("include/luajit")
    if not is_plat("windows") then
        add_syslinks("dl")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
        if package:config("shared") then
            package:addenv("PATH", "lib")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "android", "iphoneos", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        configs.fpu     = package:config("fpu")
        configs.nojit   = package:config("nojit")
        configs.gc64    = package:config("gc64")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat(os.host()) then
            os.vrun("luajit -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_pcall", {includes = "luajit.h"}))
    end)
