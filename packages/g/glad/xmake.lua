package("glad")
    set_homepage("https://glad.dav1d.de/")
    set_description("Multi-Language Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specs.")
    set_license("MIT")

    add_urls("https://github.com/Dav1dde/glad/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Dav1dde/glad.git")

    add_versions("v2.0.8", "44f06f9195427c7017f5028d0894f57eb216b0a8f7c4eda7ce883732aeb2d0fc")
    add_versions("v0.1.36", "8470ed1b0e9fbe88e10c34770505c8a1dc8ccb78cadcf673331aaf5224f963d2")
    add_versions("v0.1.34", "4be2900ff76ac71a2aab7a8be301eb4c0338491c7e205693435b09aad4969ecd")

    add_patches("0.1.36", "patches/0.1.36/utf8.patch", "13ec9c50ee0b5e465513e038b390362b9a3b8b62e5c5c08804b27ae35e9d86fb")

    add_configs("loader", {description = "Generate loader", default = true, type = "boolean"})
    add_configs("reproducible", {description = "Disable fetching the latest specification from Khronos", default = true, type = "boolean"})
    add_configs("profile", {description = "OpenGL profile", default = "compatibility", type = "string", values = {"core", "compatibility"}})
    add_configs("api", {description = "OpenGL API", default = "", type = "string"})
    add_configs("extensions", {description = "OpenGL extensions", default = "", type = "string"})
    add_configs("generator", {description = "Generator", default = "c", type = "string", values = {"c", "c-debug", "d", "nim", "pascal", "volt"}})
    add_configs("spec", {description = "OpenGL spec", default = "gl", type = "string"})

    add_configs("debug_layer", {description = "Enable the additional GLAD debug wrappers", default = false, type = "boolean"})
    add_configs("multicontext", {description = "Enable multicontext (MX)", default = false, type = "boolean"})
    add_configs("gl_profile", {description = "OpenGL profile", type = "string", values = {"core", "compatibility"}})
    add_configs("gl_version", {description = "OpenGL version", default = "3.3", type = "string"})
    add_configs("gles1_version", {description = "GLES1 version", default = "none", type = "string"})
    add_configs("gles2_version", {description = "GLES2 version", default = "none", type = "string"})
    add_configs("glsc2_version", {description = "GLSC2 version", default = "none", type = "string"})
    add_configs("egl_version", {description = "EGL version", default = "none", type = "string"})
    add_configs("glx_version", {description = "GLX version", default = "none", type = "string"})
    add_configs("wgl_version", {description = "WGL version", default = "none", type = "string"})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_check(function (package)
        if package:version():gt("1.0") then
            if package:config("debug_layer") and package:config("multicontext") then
                raise("The multicontext and debug_layer options are incompatible")
            end
            local gles1 = package:config("gles1_version")
            local gles2 = package:config("gles2_version")
            local egl = package:config("egl_version")
            local has_gles = (gles1 and gles1:lower() ~= "none") or (gles2 and gles2:lower() ~= "none")
            local has_egl = egl and egl:lower() ~= "none"
            if has_gles and not has_egl and (not package:config("api") or package:config("api") == "") then
                raise("Generating an OpenGLES spec requires a valid version of EGL")
            end
        end
    end)

    on_load(function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "python 3.x", {kind = "binary"})
        end
        if package:config("shared") then
            if package:version():gt("1.0") then
                package:add("defines", "GLAD_API_CALL_EXPORT")
            else
                package:add("defines", "GLAD_GLAPI_EXPORT")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        if package:version():gt("1.0") then
            local pytool = package:find_tool("python") or package:find_tool("python3")
            local venv_dir = path.join(os.curdir(), ".venv")
            os.vrunv(pytool.program, {"-m", "venv", venv_dir})
            local venv_python = is_host("windows") and path.join(venv_dir, "Scripts", "python.exe") or path.join(venv_dir, "bin", "python")
            if not os.isfile(venv_python) and is_host("windows") then
                venv_python = path.join(venv_dir, "python.exe")
            end
            os.vrunv(venv_python, {"-m", "pip", "install", "-r", "requirements.txt"})

            io.writefile("CMakeLists.txt", [[
cmake_minimum_required(VERSION 3.12)
project(glad LANGUAGES C)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GladConfig)
glad_add_library(glad
    ${GLAD_LOADER}
    ${GLAD_DEBUG}
    ${GLAD_MX}
    ${GLAD_REPRODUCIBLE}
    ${GLAD_LIB_TYPE}
    LANGUAGE C
    API ${GLAD_API}
    EXTENSIONS ${GLAD_EXTENSIONS}
)
install(TARGETS glad)
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include/" TYPE INCLUDE)
]])
            local configs = {}
            local py_path = venv_python:gsub("\\", "/")
            table.insert(configs, "-DPython_EXECUTABLE=" .. py_path)
            table.insert(configs, "-DPython3_EXECUTABLE=" .. py_path)
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:is_plat("windows") then
                table.insert(configs, "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=" .. (package:runtimes():startswith("MT") and "OFF" or "ON"))
            end
            table.insert(configs, "-DGLAD_SOURCES_DIR=" .. os.curdir())
            table.insert(configs, "-DGLAD_LIB_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
            local api = package:config("api")
            if not api or api == "" then
                local profile = package:config("gl_profile") or package:config("profile") or "compatibility"
                local spec_api = {
                    gl = package:config("gl_version"),
                    gles1 = package:config("gles1_version"),
                    gles2 = package:config("gles2_version"),
                    glsc2 = package:config("glsc2_version"),
                    egl = package:config("egl_version"),
                    glx = package:config("glx_version"),
                    wgl = package:is_plat("windows") and package:config("wgl_version") or "none"
                }
                local apis = {}
                for _, name in ipairs({"gl", "gles1", "gles2", "glsc2", "egl", "glx", "wgl"}) do
                    local ver = spec_api[name]
                    if ver and ver:lower() ~= "none" then
                        if name == "gl" then
                            table.insert(apis, name .. ":" .. profile .. "=" .. ver)
                        else
                            table.insert(apis, name .. "=" .. ver)
                        end
                    end
                end
                api = table.concat(apis, ";")
            end
            table.insert(configs, "-DGLAD_API=" .. api)

            local extensions = package:config("extensions")
            if extensions and extensions ~= "" then
                table.insert(configs, "-DGLAD_EXTENSIONS=" .. extensions:gsub(",", ";"))
            end

            if package:config("loader") then
                table.insert(configs, "-DGLAD_LOADER=LOADER")
            end

            if package:config("debug_layer") then
                table.insert(configs, "-DGLAD_DEBUG=DEBUG")
            end

            if package:config("multicontext") then
                table.insert(configs, "-DGLAD_MX=MX")
            end

            if package:config("reproducible") then
                table.insert(configs, "-DGLAD_REPRODUCIBLE=REPRODUCIBLE")
            end

            import("package.tools.cmake").install(package, configs)
        else
            local configs = {"-DGLAD_INSTALL=ON"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:is_plat("windows") then
                table.insert(configs, "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=" .. (package:runtimes():startswith("MT") and "OFF" or "ON"))
            end
            table.insert(configs, "-DGLAD_NO_LOADER=" .. (package:config("loader") and "OFF" or "ON"))
            table.insert(configs, "-DGLAD_REPRODUCIBLE=" .. (package:config("reproducible") and "ON" or "OFF"))
            table.insert(configs, "-DGLAD_PROFILE=" .. package:config("profile"))
            table.insert(configs, "-DGLAD_API=" .. package:config("api"))
            table.insert(configs, "-DGLAD_EXTENSIONS=" .. package:config("extensions"))
            table.insert(configs, "-DGLAD_GENERATOR=" .. package:config("generator"))
            table.insert(configs, "-DGLAD_SPEC=" .. package:config("spec"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        if package:version():gt("1.0") then
            local api = package:config("api")
            local gl_version = package:config("gl_version")
            if (not api or api == "" or api:find("gl", 1, true)) and (not gl_version or gl_version:lower() ~= "none") then
                assert(package:has_cfuncs("gladLoadGL", {includes = "glad/gl.h"}))
            end
        else
            assert(package:has_cfuncs("gladLoadGL", {includes = "glad/glad.h"}))
        end
    end)
