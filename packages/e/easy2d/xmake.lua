package("easy2d")
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")
    set_description("A lightweight 2D game engine for Windows")
    set_license("MIT")

    add_urls("https://github.com/ChestnutYueyue/Easy2D/archive/refs/tags/v$(version).zip")
    add_versions("2.1.27", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

    add_configs("shared", {
        description = "Build shared library.",
        default = false,
        type = "boolean"
    })

    add_platforms("windows", "mingw")
    add_syslinks("user32", "gdi32", "shell32", "winmm", "imm32", "version", "ole32", "comdlg32", "dinput8", "d2d1", "dwrite", "dxguid", "windowscodecs", "mfplat", "mfreadwrite", "shlwapi", "xaudio2_8")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        else
            configs.kind = "static"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("easy2d.h", {includes = package:installdir("include")}))
        assert(package:has_links("easy2d", {linksdirs = package:installdir("lib")}))
    end)