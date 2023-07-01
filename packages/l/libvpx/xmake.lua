package("libvpx")
    set_homepage("http://www.webmproject.org/code/")
    set_description("VP8/VP9 Codec SDK")

    add_urls("https://github.com/webmproject/libvpx.git",
        "https://chromium.googlesource.com/webm/libvpx.git",
        "https://github.com/webmproject/libvpx/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.10.0", "85803ccbdbdd7a3b03d930187cb055f1353596969c1f92ebec2db839fa4f834a")
    add_versions("1.11.0", "965e51c91ad9851e2337aebcc0f517440c637c506f3a03948062e3d5ea129a83")
    add_versions("1.12.0", "f1acc15d0fd0cb431f4bf6eac32d5e932e40ea1186fe78e074254d6d003957bb")
    add_versions("1.13.0", "cb2a393c9c1fae7aba76b950bb0ad393ba105409fe1a147ccd61b0aaa1501066")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    if is_arch("x86.*") then
        add_deps("yasm")
    end

    on_install("linux", "macosx", "mingw", "freebsd", "cross", function (package)
        local configs = {}
        table.insert(configs, "--enable-" .. (package:config("shared") and "shared" or "static"))
        if package:is_cross() then
            table.insert(configs, "--target=" .. package:targetarch() .. "-" .. package:targetos())
        end
        table.insert(configs, "--prefix=" .. package:installdir())

        local source_dir = os.curdir()
        os.cd("$(buildir)")
        os.vrunv(path.join(source_dir, "configure"), configs)
        import("package.tools.make").install(package)
    end)

    on_install("wasm", function (package)
        local configs = {}
        table.join2(configs, {"--target=generic-gnu", "--disable-install-bins"})
        table.insert(configs, "--prefix=" .. package:installdir())
        
        local source_dir = os.curdir()
        os.cd("$(buildir)")
        os.vrunv("emconfigure " .. path.join(source_dir, "/configure"), configs)

        import("package.tools.make").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_enc_init_ver", {includes = "vpx/vpx_encoder.h"}))
    end)
