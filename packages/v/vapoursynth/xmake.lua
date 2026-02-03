package("vapoursynth")
    set_homepage("http://www.vapoursynth.com/")
    set_description("A video processing framework with simplicity in mind")
    set_license("LGPL-2.1")

    add_urls("https://github.com/vapoursynth/vapoursynth/archive/refs/tags/R$(version).tar.gz")
    add_urls("https://github.com/vapoursynth/vapoursynth.git", {alias = "git"})

    add_versions("73", "1bb8ffe31348eaf46d8f541b138f0136d10edaef0c130c1e5a13aa4a4b057280")

    add_versions("git:73", "R73")

    add_configs("vsscript", {description = "Build VSScript. Requires Python 3", default = false, type = "boolean"})
    add_configs("vspipe", {description = "Build vspipe. Requires VSScript", default = false, type = "boolean"})
    add_configs("python", {description = "Build the Python module. Requires Python and Cython", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zimg")

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(vapoursynth) require ndk version > 22")
    end)

    on_install(function (package)
        if package:is_plat("windows", "mingw") and package:config("shared") then
            package:add("defines", "VS_CORE_EXPORTS")
        end

        if package:has_tool("cxx", "cl") then
            io.replace("meson.build", "-Wno-ignored-attributes", "", {plain = true})
            io.replace("meson.build", "add_project_arguments(['-fno-math-errno', '-fno-trapping-math'], language: lang)", "", {plain = true})
        end
        if not package:config("python") then
            io.replace("meson.build", ", 'cython'", "", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Db_lto=" .. (package:config("lto") and "true" or "false"))
        table.insert(configs, "-Denable_vsscript=" .. (package:config("vsscript") and "true" or "false"))
        table.insert(configs, "-Denable_vspipe=" .. (package:config("vspipe") and "true" or "false"))
        table.insert(configs, "-Denable_python_module=" .. (package:config("python") and "true" or "false"))

        local opt = {}
        if package:is_plat("linux", "bsd") then
            opt.shflags = "-pthread"
        end
        import("package.tools.meson").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("getVapourSynthAPI", {includes = "vapoursynth/VapourSynth4.h"}))
    end)
