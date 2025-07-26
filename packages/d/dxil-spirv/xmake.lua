package("dxil-spirv")
    set_homepage("https://github.com/HansKristian-Work/dxil-spirv")
    set_description("DXIL conversion to SPIR-V for D3D12 translation libraries")
    set_license("LGPL-2.1")

    add_urls("https://github.com/HansKristian-Work/dxil-spirv.git")

    add_versions("2025.07.14", "7f9e648ac31e185d398f543e832c12d599e1f92b")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    add_configs("pic", {description = "Enable the position independent code.", default = true, type = "boolean", readonly = true})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    -- TODO: unbundle spirv-headers

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "DXIL_SPV_PUBLIC_API=__declspec(dllimport)")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDXIL_SPIRV_CLI=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        io.replace(package:installdir("include/dxil-spirv/dxil_spirv_c.h"), "\tbool supported;", "\tdxil_spv_bool supported;", {plain = true})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dxil_spv_get_version", {includes = "dxil-spirv/dxil_spirv_c.h"}))
    end)
