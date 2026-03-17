package("dav1d")
    set_homepage("https://www.videolan.org/projects/dav1d.html")
    set_description("dav1d is a new AV1 cross-platform decoder, open-source, and focused on speed, size and correctness.")
    set_license("BSD-2-Clause")

    add_urls("https://downloads.videolan.org/pub/videolan/dav1d/$(version)/dav1d-$(version).tar.xz",
             "https://code.videolan.org/videolan/dav1d.git")

    add_versions("1.5.0", "14bd6f5157808ed9aedcafbe50df689d304fd4810ac20be6eec1ab037436afd6")
    add_versions("1.4.3", "42fe524bcc82ea3a830057178faace22923a79bad3d819a4962d8cfc54c36f19")
    add_versions("1.1.0", "fb57aae7875f28c30fb3dbae4a3683d27e2f91dde09ce5c60c22cef9bc58dfd1")
    add_versions("0.9.0", "cfae88e8067c9b2e5b96d95a7a00155c353376fe9b992a96b4336e0eab19f9f6")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    add_deps("meson", "ninja")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(dav1d) require ndk version > 22")
        end)
    end

    on_load(function (package)
        if package:is_arch("x64", "x86", "x86_64", "i386") then
            package:add("deps", "nasm")
        end
    end)

    on_install(function (package)
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end

        import("package.tools.meson")

        local configs = {"-Denable_tests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Denable_tools=" .. (package:config("tools") and "true" or "false"))

        local opt = {}
        opt.envs = meson.buildenvs(package)
        -- add gas-preprocessor to PATH
        if package:is_plat("windows") and package:is_arch("arm.*") then
            opt.envs.PATH = path.join(os.programdir(), "scripts") .. path.envsep() .. opt.envs.PATH
        end
        meson.install(package, configs, opt)
    end)

    on_test(function (package)
        if package:config("tools") and (not package:is_cross()) then
            os.vrun("dav1d -v")
        end
        assert(package:has_cfuncs("dav1d_default_settings", {includes = "dav1d/dav1d.h"}))
    end)
