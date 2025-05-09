package("mcfgthread")
    set_homepage("https://gcc-mcf.lhmouse.com/")
    set_description("Cornerstone of the MOST efficient std::thread on Windows for mingw-w64")
    set_license("GPL-3.0")

    add_urls("https://github.com/lhmouse/mcfgthread.git", {alias = "git"})
    add_urls("https://github.com/lhmouse/mcfgthread/archive/refs/tags/$(version).tar.gz", {
        alias = "github",
        version = function (version)
            return format("v%d.%d-ga.%d", version:major(), version:minor(), version:patch())
    end})

    add_versions("github:2.1.1", "73d4ea39e8eee30738ed3f4a35f6cc4e5c6cba62570908ee37d1fc0bf5a7d722")
    add_versions("github:1.9.1", "311d0816971c27d379a0a8b3528e4469d1221856e9ee59c76c6e65daa8845914")
    add_versions("github:1.8.4", "d2318ef761927860b7a8963308145065047d8ad2102313b26e6eb2d88d9ef1e3")

    add_versions("git:2.1.1", "v2.1-ga.1")

    add_patches("<=1.9.1", "patches/1.8.4/meson.patch", "89b98f9152719c44c2a7d8800b63ac621954fd0fe10884b9e90fc3298b76c6c9")

    add_configs("debug_checks", {description = "enable run-time assertions", default = false, type = "boolean"})

    add_syslinks("kernel32", "ntdll")

    add_deps("meson", "ninja")

    on_check(function (package)
        if package:version() and package:version():ge("2.1.1") then
            assert(xmake.version():ge("3.0.0"), "package(mcfgthread >=2.1.1) require xmake3")
        end
        if package:is_plat("windows") and package:has_tool("cxx", "cl") then
            raise('package(mcfgthread) does not support msvc, please use `add_requires("mcfgthread[toolchains=clang]")`')
        end
    end)

    on_load(function (package)
        -- also can use `add_packages("mcfgthread", {links = "mcfgthread-minimal"})`
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("links", "libmcfgthread")
            else
                package:add("links", "mcfgthread")
            end
        else
            package:add("links", "libmcfgthread")
        end
    end)

    on_install("windows", "mingw", "msys", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Denable-debug-checks=" .. (package:config("debug_checks") and "true" or "false"))
        import("package.tools.meson").install(package, configs)

        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "libmcfgthread.a"))
        else
            if package:is_plat("windows") then
                os.tryrm(path.join(package:installdir("lib"), "libmcfgthread.lib"))
                os.tryrm(path.join(package:installdir("lib"), "libmcfgthread-minimal.lib"))
            else
                os.tryrm(path.join(package:installdir("lib"), "libmcfgthread.dll.a"))
                os.tryrm(path.join(package:installdir("lib"), "libmcfgthread-minimal.dll.a"))
            end
            os.rm(package:installdir("bin/*.dll"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("_MCF_utc_now", {includes = "mcfgthread/clock.h"}))
    end)
