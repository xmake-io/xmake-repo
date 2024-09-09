package("mcfgthread")
    set_homepage("https://gcc-mcf.lhmouse.com/")
    set_description("Cornerstone of the MOST efficient std::thread on Windows for mingw-w64")
    set_license("GPL-3.0")

    add_urls("https://github.com/lhmouse/mcfgthread.git")
    add_urls("https://github.com/lhmouse/mcfgthread/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            return format("%d.%d-ga.%d", version:major(), version:minor(), version:patch())
    end})

    add_versions("1.8.4", "d2318ef761927860b7a8963308145065047d8ad2102313b26e6eb2d88d9ef1e3")

    add_patches("1.8.4", "patches/1.8.4/meson.patch", "45d8bd695d543dab79aa44d0dfe1bb90a417648feefdd2a181f61f474bf14d4a")

    add_configs("debug_checks", {description = "enable run-time assertions", default = false, type = "boolean"})

    add_syslinks("ntdll")

    add_deps("meson", "ninja")

    on_install("mingw", "msys", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Denable-debug-checks=" .. (package:config("debug_checks") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("_MCF_utc_now", {includes = "mcfgthread/clock.h"}))
    end)
