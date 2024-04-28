package("glad")
    set_homepage("https://glad.dav1d.de/")
    set_description("Multi-Language Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.")
    set_license("MIT")

    add_urls("https://github.com/Dav1dde/glad/archive/$(version).tar.gz",
             "https://github.com/Dav1dde/glad.git")

    add_versions("v2.0.6", "61a70234dc7da467cceb07fcdd6dec1213d6143a1b6b19ccc5d7b64cc247ea47")
    add_versions("v2.0.0", "98977626533c8a58550cc358a8859c17f25c303803d9fa9217b7105c3208aa6c")
    add_versions("v0.1.36", "8470ed1b0e9fbe88e10c34770505c8a1dc8ccb78cadcf673331aaf5224f963d2")
    add_versions("v0.1.34", "4be2900ff76ac71a2aab7a8be301eb4c0338491c7e205693435b09aad4969ecd")

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "cmake")
            package:add("deps", "python 3.x", {kind = "binary"})
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        if package:version():ge("2.0.0") then
            io.writefile("phony.c", "")
            io.writefile("CMakeLists.txt", [[
                project(glad C)
                set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}")
                add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)
                glad_add_library(glad_gl_core_33 REPRODUCIBLE API gl:core=3.3)
                add_library(glad phony.c)
                add_dependencies(glad glad_gl_core_33)
                install(TARGETS glad)
            ]])
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            local configs = {"-DGLAD_INSTALL=ON", "-DGLAD_REPRODUCIBLE=ON"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:is_plat("windows") then
                table.insert(configs, "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
            end
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gladLoadGL", {includes = "glad/glad.h"}))
    end)
