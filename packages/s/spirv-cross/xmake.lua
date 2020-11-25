package("spirv-cross")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Cross/")
    set_description("SPIRV-Cross is a practical tool and library for performing reflection on SPIR-V and disassembling SPIR-V back to high level languages.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Cross/archive/$(version).tar.gz", {version = function (version) return version:gsub("%.", "-") end})
    add_versions("2020.09.17", "a3351742fe1fae9a15e91abbfb5314d96f5f77927ed07f55124d6df830ac97a7")

    add_deps("cmake")
    add_links("spirv-cross-c", "spirv-cross-cpp", "spirv-cross-reflect", "spirv-cross-msl", "spirv-cross-util", "spirv-cross-hlsl", "spirv-cross-glsl", "spirv-cross-core")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DSPIRV_CROSS_ENABLE_TESTS=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DSPIRV_CROSS_SHARED=ON")
        else
            table.insert(configs, "-DSPIRV_CROSS_SHARED=OFF")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("spirv-cross --help")
        assert(package:has_cfuncs("spvc_get_version", {includes = "spirv_cross/spirv_cross_c.h"}))
    end)
