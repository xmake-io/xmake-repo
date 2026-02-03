package("easy2d")
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")
    set_description("A lightweight 2D game engine for Windows")
    set_license("MIT")

    add_urls("https://github.com/ChestnutYueyue/Easy2D/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChestnutYueyue/Easy2D.git")
    add_versions("v2.1.27", "787B792C80C9BCD091D5E7B36A3E8707D7230D7EE183A318190E33A71B328622")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})

    add_syslinks("user32", "gdi32", "shell32", "winmm", "imm32", "version", "ole32", "comdlg32", "dinput8", "d2d1", "dwrite", "dxguid")

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

        local libcxxflags = {}
        if package:is_plat("windows") then
            table.insert(libcxxflags, "/std:c++17")
            if not package:is_debug() then
                table.insert(libcxxflags, "/O2")
            end
        else
            if not package:is_debug() then
                table.insert(libcxxflags, "-O2")
            end
        end

        import("package.tools.xmake").install(package, configs, {cxxflags = libcxxflags})

        os.cp("Easy2D/include/easy2d", package:installdir("include"))
        os.cp("Easy2D/include/spdlog", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cxxincludes("easy2d/easy2d.h", {configs = {languages = "c++17", cxxflags = package:is_plat("windows") and "/utf-8" or "-finput-charset=UTF-8 -fexec-charset=UTF-8"}}))
    end)
