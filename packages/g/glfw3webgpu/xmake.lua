package("glfw3webgpu")
    set_description("An extension for the GLFW library for using WebGPU native.")
    set_homepage("https://github.com/eliemichel/glfw3webgpu")
    set_license("MIT")
    
    add_urls("https://github.com/eliemichel/glfw3webgpu/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eliemichel/glfw3webgpu.git")

    add_versions("v1.0.1", "b98c63f1905f0e4cf99229de8b7e5c2693fdf3b8d684b5a43d60f21f67d33e6b")

    add_deps("wgpu-native", "glfw")

    if is_plat("macosx", "iphoneos") then
        add_frameworks("Metal", "Foundation")
    end

    on_install(function (package)
        if package:is_plat("macosx", "iphoneos") then
            os.mv("glfw3webgpu.c", "glfw3webgpu.m")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")

            add_requires("wgpu-native", "glfw")

            target("glfw3webgpu")
                set_kind("$(kind)")
                set_languages("c11")
                add_headerfiles("glfw3webgpu.h")
                
                add_mxflags("-fno-objc-arc")
                
                add_packages("wgpu-native")
                add_packages("glfw")
                
                if is_plat("iphoneos", "macosx") then
                    add_frameworks("Metal", "Foundation")
                    add_files("glfw3webgpu.m")
                else
                    add_files("glfw3webgpu.c")
                end
                
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("glfwGetWGPUSurface", {includes = "glfw3webgpu.h"}))
    end)
