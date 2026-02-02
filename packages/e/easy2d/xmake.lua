package("easy2d")
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")
    set_description("A lightweight 2D game engine for Windows")
    set_license("MIT")

    set_urls("https://github.com/ChestnutYueyue/Easy2D.git")
    add_versions("master")

    add_configs("shared", {
        description = "Build shared library.",
        default = false,
        type = "boolean"
    })

    local win_base_libs = {"user32", "gdi32", "shell32", "winmm", "imm32", "version", "ole32", "comdlg32", "dinput8", "d2d1", "dwrite", "dxguid"}
    local mingw_extra_libs = {"windowscodecs", "mfplat", "mfreadwrite", "shlwapi", "xaudio2_8"}
    add_syslinks(win_base_libs)
    on_load("mingw", function(package)
        package:add("syslinks", mingw_extra_libs)
    end)

    on_load("windows", "mingw", function(package)
        if package:config("shared") then
            package:add("defines", "EASY2D_SHARED")
        end
    end)

    on_install("windows", "mingw", function(package)
        local configs = {}
        configs.mode = package:is_debug() and "debug" or "release"
        if package:config("shared") then
            configs.kind = "shared"
        else
            configs.kind = "static"
        end
        if  package:is_plat("windows") then
            configs.cxxflags = "/std:c++17 /utf-8"
        else 
            configs.cxxflags = "-finput-charset=UTF-8 -fexec-charset=UTF-8"
        end
        
        import("package.tools.xmake").install(package, configs)

        os.cp("Easy2D/include/easy2d/*", package:installdir("include/easy2d"))
        os.cp("Easy2D/include/spdlog/*", package:installdir("include/spdlog"))
    end)

    on_test(function(package)
        assert(package:has_cxxincludes("easy2d/easy2d.h", {configs = {languages = "c++17", cxxflags = "/utf-8"}}))
    end)