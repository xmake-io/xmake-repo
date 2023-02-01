package("libui")
    set_homepage("https://libui-ng.github.io/libui-ng/")
    set_description("A portable GUI library for C")

    set_urls("https://github.com/libui-ng/libui-ng.git")
    add_versions("2022.12.3", "8c82e737eea2f8ab3667e227142abd2fd221f038")

    add_deps("meson", "ninja")

    if is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreText", "Foundation", "AppKit")
    elseif is_plat("windows") then
        add_syslinks("user32", "ole32", "gdi32", "d2d1", "dwrite", "comctl32", "windowscodecs")
    elseif is_plat("linux") then
        add_deps("gtk+3", "glib")
    end

    on_install("linux", "macosx", "windows", function (package)
        local configs = {"-Dexamples=false", "-Dtests=false"}
        table.insert(configs, "--default-library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uiInit", {includes = "ui.h"}))
    end)
