package("ktx")
    set_homepage("https://github.com/KhronosGroup/KTX-Software")
    set_description("KTX (Khronos Texture) Library and Tools")

    add_urls("https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/$(version).tar.gz")
    add_versions("v4.3.2", "74a114f465442832152e955a2094274b446c7b2427c77b1964c85c173a52ea1f")

    add_configs("tools", {description = "Create KTX tools", default = false, type = "boolean"})
    add_configs("decoder", {description = "ETC decoding support", default = false, type = "boolean"})
    add_configs("opencl", {description = "Compile with OpenCL support so applications can choose to use it.", default = false, type = "boolean"})
    add_configs("embed", {description = "Embed bitcode in binaries.", default = false, type = "boolean"})
    add_configs("ktx1", {description = "Enable KTX 1 support.", default = true, type = "boolean"})
    add_configs("ktx2", {description = "Enable KTX 2 support.", default = true, type = "boolean"})
    add_configs("vulkan", {description = "Enable Vulkan texture upload.", default = false, type = "boolean"})
    add_configs("opengl", {description = "Enable OpenGL texture upload.", default = false, type = "boolean"})
    -- This project .def file export 64-bit symbols only
    if is_plat("wasm", "iphoneos") or (is_plat("windows") and is_arch("x86")) then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DKTX_FEATURE_TESTS=OFF", "-DKTX_LOADTEST_APPS_USE_LOCAL_DEPENDENCIES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DKTX_FEATURE_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))

        table.insert(configs, "-DKTX_FEATURE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_ETC_UNPACK=" .. (package:config("decoder") and "ON" or "OFF"))
        table.insert(configs, "-DBASISU_SUPPORT_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_EMBED_BITCODE=" .. (package:config("embed") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_KTX1=" .. (package:config("ktx1") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_KTX2=" .. (package:config("ktx2") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_VK_UPLOAD=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DKTX_FEATURE_GL_UPLOAD=" .. (package:config("opengl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows", "mingw") and (not package:config("shared")) then
            package:add("defines", "KHRONOS_STATIC")
        end
        if package:config("ktx1") then
            package:add("defines", "KTX_FEATURE_KTX1")
        end
        if package:config("ktx2") then
            package:add("defines", "KTX_FEATURE_KTX2")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ktxErrorString", {includes = "ktx.h"}))
    end)
