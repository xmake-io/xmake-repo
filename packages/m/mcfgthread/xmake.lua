package("mcfgthread")
    set_homepage("https://gcc-mcf.lhmouse.com/")
    set_description("Cornerstone of the MOST efficient std::thread on Windows for mingw-w64")
    set_license("GPL-3.0")

    add_urls("https://github.com/lhmouse/mcfgthread/archive/refs/tags/$(version).tar.gz", {version = function (version) return version:gsub("-alpha", ".alpha-1") end})
    add_urls("https://github.com/lhmouse/mcfgthread.git")

    add_versions("1.8-alpha", "4f2b7939f1806b4fb3739d1add63397638e0872c09a1f35c402597aafbc70f32")

    add_patches("1.8-alpha", path.join(os.scriptdir(), "patches", "1.8.alpha-1", "meson.patch"), "db0faa7499218357021f3a5d737653bb42a3bf9840b27aae946cc1fe9bf99a50")

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
