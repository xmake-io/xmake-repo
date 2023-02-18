package("dav1d")

    set_homepage("https://www.videolan.org/projects/dav1d.html")
    set_description("dav1d is a new AV1 cross-platform decoder, open-source, and focused on speed, size and correctness.")
    set_license("BSD-2-Clause")

    add_urls("https://downloads.videolan.org/pub/videolan/dav1d/$(version)/dav1d-$(version).tar.xz")
    add_versions("0.9.0", "cfae88e8067c9b2e5b96d95a7a00155c353376fe9b992a96b4336e0eab19f9f6")
    add_versions("1.1.0", "fb57aae7875f28c30fb3dbae4a3683d27e2f91dde09ce5c60c22cef9bc58dfd1")

    add_deps("nasm", "meson", "ninja")
    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("windows", "macosx", "linux|x86_64", function (package)
        local configs = {"-Denable_tests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        if package:is_plat("windows") and package:is_cross() then
            table.insert(configs, "-Denable_asm=false") -- arm asm requires bash and gas-preprocessor
        end
        import("package.tools.meson").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("dav1d -v")
        end
        assert(package:has_cfuncs("dav1d_default_settings", {includes = "dav1d/dav1d.h"}))
    end)
