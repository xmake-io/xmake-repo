package("openrestry-luajit")

    set_homepage("https://github.com/openresty/luajit2")
    set_description("OpenResty's Branch of LuaJIT 2")

    set_urls("https://github.com/openresty/luajit2/archive/refs/tags/$(version).zip",
        "https://github.com/openresty/luajit2.git")

    add_versions("v2.1-20230911", "26360e7828153f99ecc95cde61523fc406e3154ebaa21377c84331958c53c5d1")
    add_versions("v2.1-20230119", "0de62abafce957b4ed9b2417d5a1c065d9c53d3f4a28fcbe6b59f128d1a4fb37")
    add_versions("v2.1-20220310", "5d765a7a60cb698afcba91c52204cbe085687ac32f6b99abeca6c3719ecf82a8")

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
