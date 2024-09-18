package("luajit")
    set_homepage("http://luajit.org")
    set_description("A Just-In-Time Compiler (JIT) for the Lua programming language.")
    set_license("MIT")

    set_urls("https://github.com/LuaJIT/LuaJIT.git",
             "http://repo.or.cz/luajit-2.0.git")

    add_versions("v2.1.0-beta3", "8271c643c21d1b2f344e339f559f2de6f3663191")

    add_configs("nojit", { description = "Disable JIT.", default = false, type = "boolean"})
    add_configs("fpu",   { description = "Enable FPU.", default = true, type = "boolean"})
    add_configs("gc64",  { description = "Enable GC64.", default = false, type = "boolean"})

    add_includedirs("include/luajit")
    if not is_plat("windows") then
        add_syslinks("dl")
    end

    if on_check then
        on_check(function (package)
            if package:is_arch("arm.*") then
                raise("package(luajit/arm64) unsupported arch")
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
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat(os.host()) then
            os.vrun("luajit -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_pcall", {includes = "luajit.h"}))
    end)
