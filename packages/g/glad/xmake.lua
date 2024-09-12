package("glad")
    set_homepage("https://glad.dav1d.de/")
    set_description("Multi-Language Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.")
    set_license("MIT")

    add_urls("https://github.com/Dav1dde/glad/archive/$(version).tar.gz",
             "https://github.com/Dav1dde/glad.git")

    add_versions("v0.1.34", "4be2900ff76ac71a2aab7a8be301eb4c0338491c7e205693435b09aad4969ecd")
    add_versions("v0.1.36", "8470ed1b0e9fbe88e10c34770505c8a1dc8ccb78cadcf673331aaf5224f963d2")

    add_patches("0.1.36", "patches/0.1.36/utf8.patch", "13ec9c50ee0b5e465513e038b390362b9a3b8b62e5c5c08804b27ae35e9d86fb")

    if is_plat("linux") then
        add_syslinks("dl")
    end
    on_load("windows", "linux", "macosx", "mingw", function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
            package:add("deps", "python 3.x", {kind = "binary"})
        end
    end)

    add_configs("reproducible", {description = "Disable fetching the latest specification from Khronos", default = true, type = "boolean"})
    add_configs("profile", {description = "OpenGL profile", default = "compatibility", type = "string", values = {"core", "compatibility"}})
    add_configs("api", {description = "OpenGL API", default = "", type = "string"})
    add_configs("extensions", {description = "OpenGL extensions", default = "", type = "string"})
    add_configs("generator", {description = "Generator", default = "c", type = "string", values = {"c", "c-debug", "d", "nim", "pascal", "volt"}})
    add_configs("spec", {description = "OpenGL spec", default = "gl", type = "string"})

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DGLAD_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DGLAD_REPRODUCIBLE=" .. (package:config("reproducible") and "ON" or "OFF"))
        table.insert(configs, "-DGLAD_PROFILE=" .. package:config("profile"))
        table.insert(configs, "-DGLAD_API=" .. package:config("api"))
        table.insert(configs, "-DGLAD_EXTENSIONS=" .. package:config("extensions"))
        table.insert(configs, "-DGLAD_GENERATOR=" .. package:config("generator"))
        table.insert(configs, "-DGLAD_SPEC=" .. package:config("spec"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gladLoadGL", {includes = "glad/glad.h"}))
    end)
