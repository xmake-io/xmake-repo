package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("3-12-22", "8c82e737eea2f8ab3667e227142abd2fd221f038")

    add_deps {
        "meson", "ninja"
    }

    on_install(function (package)
        import("package.tools.meson").install(package, {
            "-Dexamples=false",
            "-Dtests=false",
            "--default-library=static",
        })
    end)
