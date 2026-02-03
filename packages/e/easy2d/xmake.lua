package("easy2d")
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")
    set_description("A lightweight 2D game engine for Windows")
    set_license("MIT")

    add_urls("https://github.com/ChestnutYueyue/Easy2D/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChestnutYueyue/Easy2D.git")
    add_versions("v2.1.27", "787b792c80c9bcd091d5e7b36a3e8707d7230d7ee183a318190e33a71b328622")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})

    add_syslinks("user32", "gdi32", "shell32", "winmm", "imm32", "version", "ole32", "comdlg32", "dinput8", "d2d1", "dwrite", "dxguid")

    on_install("windows", "mingw", function(package)
        import("package.tools.xmake").install(package)

        os.cp("Easy2D/include/easy2d", package:installdir("include"))
        os.cp("Easy2D/include/spdlog", package:installdir("include"))
    end)

    on_test(function (package)
        local configs = {
            cxxflags = package:is_plat("windows") and "/utf-8" or "-finput-charset=UTF-8 -fexec-charset=UTF-8",
        }
        assert(package:has_cxxincludes("easy2d/easy2d.h", {configs = configs, includes = {"easy2d/easy2d.h"}}))
    end)
