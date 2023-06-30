package("libvpx")
    set_homepage("http://www.webmproject.org/code/")
    set_description("Mirror only. Please do not send pull requests.")

    add_urls("https://github.com/webmproject/libvpx.git",
        "https://chromium.googlesource.com/webm/libvpx",
        "https://github.com/webmproject/libvpx/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.10.0", "85803ccbdbdd7a3b03d930187cb055f1353596969c1f92ebec2db839fa4f834a")
    add_versions("1.11.0", "965e51c91ad9851e2337aebcc0f517440c637c506f3a03948062e3d5ea129a83")
    add_versions("1.12.0", "f1acc15d0fd0cb431f4bf6eac32d5e932e40ea1186fe78e074254d6d003957bb")
    add_versions("1.13.0", "cb2a393c9c1fae7aba76b950bb0ad393ba105409fe1a147ccd61b0aaa1501066")

    add_deps("autoconf", "automake", "yasm")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-" .. (package:config("shared") and "shared" or "static"))

        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_enc_init_ver", {includes = "vpx/vpx_encoder.h"}))
    end)
