package("infoware")
    set_homepage("https://github.com/ThePhD/infoware")
    set_description("C++ Library for pulling system and hardware information, without hitting the command line.")
    set_license("CC0-1.0")

    add_urls("https://github.com/ThePhD/infoware.git")
    add_versions("2023.04.12", "d64a0c948593c0555115f60c79225c0b9ae09510")

    add_configs("x11", {description = "Use X11 for display detection", default = false, type = "boolean"})
    add_configs("d3d", {description = "Use D3D for GPU detection", default = false, type = "boolean"})
    add_configs("opencl", {description = "Use OpenCL for GPU detection", default = false, type = "boolean"})
    add_configs("opengl", {description = "Use OpenGL for GPU detection", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("gdi32", "version", "ole32", "oleaut32", "wbemuuid", "ntdll")
    end

    add_deps("cmake")

    on_install(function (package)
        if package:config("x11") then
            package:add("deps", "libx11")
        end
        if package:config("opencl") then
            package:add("deps", "opencl")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DINFOWARE_USE_X11=" .. (package:config("x11") and "ON" or "OFF"))
        table.insert(configs, "-DINFOWARE_USE_D3D=" .. (package:config("d3d") and "ON" or "OFF"))
        table.insert(configs, "-DINFOWARE_USE_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DINFOWARE_USE_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <infoware/cpu.hpp>
            void test() {
                auto quantities = iware::cpu::quantities();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
