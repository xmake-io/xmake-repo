package("sdl3webgpu")
    set_description("An extension for the SDL3 library for using WebGPU native.")
    set_homepage("https://github.com/eliemichel/sdl3webgpu")
    set_license("MIT")

    -- Version 1.0.0 is too old for the current wgpu-native, we have to fetch a newer version from a more recent commit
    add_urls("https://github.com/eliemichel/sdl3webgpu.git")

    add_versions("2025.05.01", "4fa9d70935e41c075f664b231ee10a64262a8ac7")

    add_deps("wgpu-native", "libsdl3")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreVideo", "IOKit", "QuartzCore", is_plat("macosx") and "Cocoa" or "UIKit")
    end

    on_install("windows|x64", "windows|x86", "linux|x86_64", "macosx|x86_64", "macosx|arm64", function (package)
        if package:is_plat("macosx", "iphoneos") then
            os.mv("sdl3webgpu.c", "sdl3webgpu.m")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            add_requires("wgpu-native", "libsdl3")

            target("sdl3webgpu")
                set_kind("$(kind)")
                set_languages("c11")
                add_headerfiles("sdl3webgpu.h")

                add_mxflags("-fno-objc-arc")

                add_packages("wgpu-native")
                add_packages("libsdl3")

                if is_plat("macosx", "iphoneos") then
                    add_frameworks("CoreVideo", "IOKit", "QuartzCore", is_plat("macosx") and "Cocoa" or "UIKit")
                    add_files("sdl3webgpu.m")
                else
                    add_files("sdl3webgpu.c")
                end

                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end

        ]])

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SDL_GetWGPUSurface", {includes = "sdl3webgpu.h"}))
    end)
