package("moonjit")

    set_homepage("https://github.com/moonjit/moonjit")
    set_description("A Just-In-Time Compiler (JIT) for the Lua programming language.")

    set_urls("https://github.com/moonjit/moonjit/archive/$(version).tar.gz",
             "https://github.com:moonjit/moonjit.git")

    add_versions("2.2.0", "83deb2c880488dfe7dd8ebf09e3b1e7613ef4b8420de53de6f712f01aabca2b6")

    add_configs("nojit", { description = "Disable JIT.", default = false, type = "boolean"})
    add_configs("fpu",   { description = "Enable FPU.", default = true, type = "boolean"})

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
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:is_plat(os.host()) then
            os.vrun("luajit -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_pcall", {includes = "luajit.h"}))
    end)
