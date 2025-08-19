package("dxil-spirv")
    set_homepage("https://github.com/HansKristian-Work/dxil-spirv")
    set_description("DXIL conversion to SPIR-V for D3D12 translation libraries")
    set_license("LGPL-2.1")

    add_urls("https://github.com/HansKristian-Work/dxil-spirv.git", {submodules = false})

    add_versions("2025.07.28", "bdb1bd679a0fa14f53585060c08e9dc2fd423da2")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("pic", {description = "Enable the position independent code.", default = true, type = "boolean", readonly = true})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("spirv-headers 3b9447dc98371e96b59a6225bd062a9867e1d203")

    if is_plat("android") then
        add_syslinks("log")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(dxil-spirv) require ndk version > 22")
        end)
    end

    on_install("!wasm", function (package)
        io.replace("third_party/CMakeLists.txt", "add_subdirectory(spirv-headers EXCLUDE_FROM_ALL)", "find_package(SPIRV-Headers REQUIRED)", {plain = true})
        io.replace("third_party/CMakeLists.txt", "target_link_libraries(glslang-spirv-builder PUBLIC dxil-spirv-headers)", "target_link_libraries(glslang-spirv-builder PUBLIC SPIRV-Headers::SPIRV-Headers)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDXIL_SPIRV_CLI=" .. (package:config("tools") and "ON" or "OFF"))

        local opt = {}
        local spirv_headers = package:dep("spirv-headers")
        if not spirv_headers:is_system() then
            opt.cxflags = "-I" .. spirv_headers:installdir("include/spirv/unified1")
        end
        import("package.tools.cmake").install(package, configs, opt)

        io.replace(package:installdir("include/dxil-spirv/dxil_spirv_c.h"), "\tbool supported;", "\tdxil_spv_bool supported;", {plain = true})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dxil_spv_get_version", {includes = "dxil-spirv/dxil_spirv_c.h"}))
    end)
