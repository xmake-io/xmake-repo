package("ktx")
    set_homepage("https://github.com/KhronosGroup/KTX-Software")
    set_description("KTX (Khronos Texture) Library and Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/KTX-Software.git", {submodules = false})

    add_versions("v4.4.0", "3585d76edcdcbe3a671479686f8c81c1c10339f419e4b02a9a6f19cc6e4e0612")

    add_configs("tools", {description = "Create KTX tools", default = false, type = "boolean"})
    add_configs("decoder", {description = "ETC decoding support", default = false, type = "boolean"})
    add_configs("opencl", {description = "Compile with OpenCL support so applications can choose to use it.", default = false, type = "boolean"})
    add_configs("embed", {description = "Embed bitcode in binaries.", default = false, type = "boolean"})
    add_configs("ktx1", {description = "Enable KTX 1 support.", default = true, type = "boolean"})
    add_configs("ktx2", {description = "Enable KTX 2 support.", default = true, type = "boolean"})
    add_configs("vulkan", {description = "Enable Vulkan texture upload.", default = false, type = "boolean"})
    add_configs("opengl", {description = "Enable OpenGL texture upload.", default = is_plat("wasm"), type = "boolean"})
    -- This project .def file export 64-bit symbols only
    if is_plat("wasm", "iphoneos") or (is_plat("windows", "mingw") and is_arch("x86", "i386")) then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "KHRONOS_STATIC")
        end
        if package:config("ktx1") then
            package:add("defines", "KTX_FEATURE_KTX1")
        end
        if package:config("ktx2") then
            package:add("defines", "KTX_FEATURE_KTX2")
        end
    end)

    on_install(function (package)
        local configs = {"-DKTX_FEATURE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if not package:gitref() and package:version():startswith("v") then
            table.insert(configs, "-DKTX_GIT_VERSION_FULL=" .. package:version())
        end

        table.insert(configs, "-DKTX_FEATURE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_ETC_UNPACK=" .. (package:config("decoder") and "ON" or "OFF"))
        table.insert(configs, "-DBASISU_SUPPORT_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_EMBED_BITCODE=" .. (package:config("embed") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_KTX1=" .. (package:config("ktx1") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_KTX2=" .. (package:config("ktx2") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_VK_UPLOAD=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_GL_UPLOAD=" .. (package:config("opengl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ktxErrorString", {includes = "ktx.h"}))
    end)
