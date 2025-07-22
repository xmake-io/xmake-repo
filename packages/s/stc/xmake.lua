package("stc")
    set_homepage("https://github.com/stclib/STC")
    set_description("A modern, user friendly, generic, type-safe and fast C99 container library: String, Vector, Sorted and Unordered Map and Set, Deque, Forward List, Smart Pointers, Bitset and Random numbers.")
    set_license("MIT")

    add_urls("https://github.com/stclib/STC/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stclib/STC.git")

    add_versions("v5.0", "d61353852b9d7ef69b56fa32edcbc7934f2153385f3778536234201ceebcc950")
    add_versions("v4.2", "f16c3185ba5693f0257e5b521f0b6b3c11041433a4abbbbc531370364eb75d0c")

    add_configs("checkscoped", {description = "Build checkscoped tool for c_guard* blocks", default = false, type = "boolean"})
    if is_plat("windows", "wasm") then
        add_configs("shared", {description = "Download shared binaries.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:version() and package:version():ge("5.0.0") then
            package:add("deps", "meson", "ninja")
            if package:config("checkscoped") then
                package:add("deps", "flex", {kind = "binary"})
            end
        else
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        if package:version() and package:version():ge("5.0.0") then
            local configs = {"-Dtests=disabled", "-Dexamples=disabled"}
            table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
            table.insert(configs, "-Dcheckscoped=" .. (package:config("checkscoped") and "enabled" or "disabled"))
            import("package.tools.meson").install(package, configs)
        else
            os.cp("include", package:installdir())
        end
    end)

    on_test(function (package)
        local opt = {}
        opt.configs = {
            defines = {"i_type=Floats", "i_val=float"}
        }
        if package:version() and package:version():ge("5.0.0") then
            opt.includes = "stc/vec.h"
        else
            opt.includes = "stc/cvec.h"
        end
        assert(package:has_cfuncs("Floats_push", opt))
    end)
