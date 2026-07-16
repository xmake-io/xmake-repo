package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("2022.12.3", "8c82e737eea2f8ab3667e227142abd2fd221f038")
    add_versions("2025.3.15", "43ba1ef553c8993a43a67f1ce6e35983a2660d8c")

    add_deps("meson", "ninja")

    if is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreText", "Foundation", "AppKit")
    elseif is_plat("windows") then
        -- the windows meson build file links all of these with a todo to prune the list
        add_syslinks("user32", "kernel32", "gdi32", "comctl32", "uxtheme", "msimg32", "comdlg32", "d2d1", "dwrite", "ole32", "oleaut32", "oleacc", "uuid", "windowscodecs")
    elseif is_plat("linux") then
        add_deps("gtk3", "glib")
    end

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-Dexamples=false", "-Dtests=false"}
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uiInit", {includes = "ui.h"}))
    end)
