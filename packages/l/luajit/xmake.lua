package("luajit")

    set_homepage("http://luajit.org")
    set_description("A Just-In-Time Compiler (JIT) for the Lua programming language.")

    set_urls("http://luajit.org/download/LuaJIT-$(version).tar.gz",
             "http://luajit.org/git/luajit-2.0.git",
             "http://repo.or.cz/luajit-2.0.git")

    add_versions("2.1.0-beta3", "1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3")

    add_configs("nojit", { description = "Disable JIT.", default = false, type = "boolean"})
    add_configs("fpu",   { description = "Enable FPU.", default = true, type = "boolean"})

    add_includedirs("include/luajit")
    if not is_plat("windows") then
        add_syslinks("dl")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "linux", "macosx", "bsd", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        configs.fpu     = package:config("fpu")
        configs.nojit   = package:config("nojit")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("luajit -e \"print('hello xmake!')\"")
        assert(package:has_cfuncs("lua_pcall", {includes = "luajit.h"}))
    end)
