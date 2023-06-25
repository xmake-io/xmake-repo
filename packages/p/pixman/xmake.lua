package("pixman")

    set_homepage("https://cairographics.org/")
    set_description("Low-level library for pixel manipulation.")

    add_urls("https://cairographics.org/releases/pixman-$(version).tar.gz", {alias = "cairographics"})
    add_urls("https://gitlab.freedesktop.org/pixman/pixman/-/archive/pixman-$(version)/pixman-pixman-$(version).tar.gz", {alias = "git_release"})
    add_urls("https://github.com/freedesktop/pixman/archive/refs/tags/pixman-$(version).tar.gz", {alias = "git_release"})
    add_urls("https://gitlab.freedesktop.org/pixman/pixman.git")
    add_urls("https://github.com/freedesktop/pixman.git")
    add_versions("git_release:0.40.0", "3a68a28318a78fffc61603c8385bb0010c3fb23d17cd1285d36a7148c87a3b91")
    add_versions("cairographics:0.40.0", "6d200dec3740d9ec4ec8d1180e25779c00bc749f94278c8b9021f5534db223fc")
    add_versions("git_release:0.42.0", "45c6462f6d6441923d4c17d06fa50ce066f0ceff0fc84af8d342df63c1079151")
    add_versions("cairographics:0.42.0", "07f74c8d95e4a43eb2b08578b37f40b7937e6c5b48597b3a0bb2c13a53f46c13")
    add_versions("git_release:0.42.2", "4191a5084bae000a61e3513b06027b6f8f559d17d61769ed9de27dfb0cec8699")
    add_versions("cairographics:0.42.2", "ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja")

    add_includedirs("include", "include/pixman-1")

    on_install("macosx", "linux", "windows|x64", "windows|x86", "wasm", function (package)
        local configs = {
            "-Dopenmp=disabled",
            "-Dlibpng=disabled",
            "-Dgtk=disabled"
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        io.replace("meson.build", "subdir('test')", "", {plain = true})
        io.replace("meson.build", "subdir('demos')", "", {plain = true})
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixman_image_create_solid_fill", {includes = "pixman.h"}))
    end)
