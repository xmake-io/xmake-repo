package("remotery")
    set_homepage("https://github.com/Celtoys/Remotery")
    set_description("Single C file, Realtime CPU/GPU Profiler with Remote Web Viewer")
    set_license("Apache-2.0")

    add_urls("https://github.com/Celtoys/Remotery.git")
    add_versions("2023.08.02", "4e65390c4289bbb3494accf1aa36e58733aca2bf")

    add_configs("cuda", {description = "Assuming CUDA headers/libs are setup, allow CUDA profiling", default = false, type = "boolean"})
    add_configs("dx11", {description = "Assuming Direct3D 11 headers/libs are setup, allow D3D11 GPU profiling", default = false, type = "boolean"})
    add_configs("dx12", {description = "Allow D3D12 GPU profiling", default = false, type = "boolean"})
    add_configs("opengl", {description = "Allow OpenGL GPU profiling (dynamically links OpenGL libraries on available platforms)", default = false, type = "boolean"})
    add_configs("metal", {description = "Allow Metal profiling of command buffers", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    on_install("windows|x64", "linux", "macosx", "bsd", "mingw|x86_64", "msys", "android", "iphoneos", "cross", function (package)
        local configs = {}
        if package:config("cuda") then
            configs.cuda = true
            package:add("defines", "RMT_USE_CUDA=1")
        end
        if package:config("dx11") then
            configs.dx11 = true
            package:add("defines", "RMT_USE_D3D11=1")
        end
        if package:config("dx12") then
            configs.dx12 = true
            package:add("defines", "RMT_USE_D3D12=1")
        end
        if package:config("opengl") then
            configs.opengl = true
            package:add("defines", "RMT_USE_OPENGL=1")
        end
        if package:config("metal") then
            configs.metal = true
            package:add("defines", "RMT_USE_METAL=1")
        end

        io.replace("lib/Remotery.c", [[#pragma comment(lib, "ws2_32.lib")]], "", {plain = true})
        io.replace("lib/Remotery.c", [[#pragma comment(lib, "winmm.lib")]], "", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)

        os.cp("vis", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("_rmt_Settings", {includes = "Remotery.h"}))
    end)
