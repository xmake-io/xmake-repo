package("fribidi")
    set_homepage("https://github.com/fribidi/fribidi")
    set_description("The Free Implementation of the Unicode Bidirectional Algorithm.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/fribidi/fribidi.git")
    add_urls("https://github.com/fribidi/fribidi/releases/download/v$(version)/fribidi-$(version).tar.xz", {
        version = function (version)
            return version:gsub("v", "")
    end})

    add_versions("v1.0.16", "1b1cde5b235d40479e91be2f0e88a309e3214c8ab470ec8a2744d82a5a9ea05c")
    add_versions("v1.0.15", "0bbc7ff633bfa208ae32d7e369cf5a7d20d5d2557a0b067c9aa98bcbf9967587")
    add_versions("v1.0.14", "76ae204a7027652ac3981b9fa5817c083ba23114340284c58e756b259cd2259a")
    add_versions("v1.0.10", "7f1c687c7831499bcacae5e8675945a39bacbad16ecaa945e9454a32df653c01")
    add_versions("v1.0.11", "30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d")
    add_versions("v1.0.12", "0cd233f97fc8c67bb3ac27ce8440def5d3ffacf516765b91c2cc654498293495")
    add_versions("v1.0.13", "7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux") then
        add_extsources("apt::libfribidi-dev", "pacman::fribidi")
    end

    add_includedirs("include", "include/fribidi")

    add_deps("meson", "ninja")

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "FRIBIDI_LIB_STATIC")
        end

        if package:is_plat("windows") and package:is_cross() then
            package:add("deps", "fribidi~host", {private = true, host = true})
        end
    end)

    on_install(function (package)
        local opt = {}
        if package:is_plat("windows") and package:is_cross() then
            local host_includedirs = package:dep("fribidi"):installdir("include/fribidi")
            opt.cxflags = "-I" .. host_includedirs
            os.vcp(path.join(host_includedirs, "fribidi-unicode-version.h"), package:installdir("include/fribidi"))

            io.replace("meson.build", "subdir('gen.tab')", "", {plain = true})
            io.replace("lib/meson.build", "fribidi_unicode_version_h,", "", {plain = true})
            io.replace("lib/meson.build", "generated_tab_include_files,", "", {plain = true})
        end

        local configs = {"-Ddocs=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dbin=" .. (package:config("tools") and "true" or "false"))
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fribidi_debug_status", {includes = "fribidi/fribidi-common.h"}))
    end)
