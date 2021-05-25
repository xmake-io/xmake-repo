package("dav1d")

    set_homepage("https://www.videolan.org/projects/dav1d.html")
    set_description("dav1d is a new AV1 cross-platform decoder, open-source, and focused on speed, size and correctness.")
    set_license("BSD-2-Clause")

    add_urls("https://downloads.videolan.org/pub/videolan/dav1d/$(version)/dav1d-$(version).tar.xz")
    add_versions("0.9.0", "cfae88e8067c9b2e5b96d95a7a00155c353376fe9b992a96b4336e0eab19f9f6")

    add_deps("nasm", "meson")
    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("windows", "macosx", "linux|x86_64", function (package)
        local configs = {"--libdir=lib", "-Denable_tests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dav1d -v")
        assert(package:has_cfuncs("dav1d_default_settings", {includes = "dav1d/dav1d.h"}))
    end)
