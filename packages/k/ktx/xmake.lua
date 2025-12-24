package("ktx")
    set_homepage("https://github.com/KhronosGroup/KTX-Software")
    set_description("KTX (Khronos Texture) Library and Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/KTX-Software.git", {submodules = false})

    add_versions("v4.4.2", "9412cb45045a503005acd47d98f9e8b47154634a50b4df21e17a1dfa8971d323")
    add_versions("v4.4.0", "3585d76edcdcbe3a671479686f8c81c1c10339f419e4b02a9a6f19cc6e4e0612")

    add_patches("4.4.2", "patches/4.4.2/dep-unbundle.patch", "8dbccc8fc21256da166ef6c3c952bd3ae099414910cb8a6575635a6e60810ab2")
    add_patches("4.4.0", "patches/4.4.0/dep-unbundle.patch", "2b883bcbfc19f80d72b812d68b606b6e2a4234d913ad92c45d8030bd94207a59")

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
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("astc-encoder", "zstd")
    -- TODO
    if is_plat("iphoneos") then
        add_includedirs("lib/ktx.framework/Headers")
        add_linkdirs("lib/ktx.framework")
        add_frameworkdirs("lib/ktx.framework")
        add_frameworks("ktx")
    end

    on_check(function (package)
        if is_subhost("windows") and os.arch() == "arm64" then
            raise("package(ktx) require python (from pkgconf) for building, but windows arm64 python binaries are unsupported")
        end
        if package:is_plat("linux") and package:is_arch("arm64") then
            raise("package(ktx) dep(astc-encoder) unsupported linux arm64")
        end
    end)

    on_load(function (package)
        if package:config("tools") then
            package:add("deps", "fmt", "cxxopts", {private = true})
        end
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

    on_install("!iphoneos and !wasm", function (package)
        if package:has_runtime("MD", "MT") then
            io.replace("CMakeLists.txt", "_DEBUG", "", {plain = true})
        end

        -- TODO: unbundle basisu & dfdutils
        -- io.replace("CMakeLists.txt", "external/dfdutils%g*.c\n", "")
        -- io.replace("CMakeLists.txt", "external%g*.cpp\n", "")
        io.writefile("external/basisu/zstd/zstd.c", "")
        io.replace("CMakeLists.txt", "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/external/basisu/zstd>", "", {plain = true})
        io.replace("CMakeLists.txt", "$ $<INSTALL_INTERFACE:external/basisu/zstd>", "", {plain = true})

        local file = io.open("CMakeLists.txt", "a")
        file:write([[
            include(FindPkgConfig)
            pkg_search_module("libzstd" REQUIRED IMPORTED_TARGET "libzstd")
            target_link_libraries(ktx PUBLIC PkgConfig::libzstd)
            target_link_libraries(ktx_read PUBLIC PkgConfig::libzstd)
        ]])
        file:close()

        if package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(external/fmt)", "find_package(fmt CONFIG REQUIRED)", {plain = true})
            io.replace("CMakeLists.txt", "add_subdirectory(external/cxxopts)", "find_package(cxxopts CONFIG REQUIRED)", {plain = true})
        end

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
