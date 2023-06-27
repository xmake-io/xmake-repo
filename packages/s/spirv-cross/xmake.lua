package("spirv-cross")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Cross/")
    set_description("SPIRV-Cross is a practical tool and library for performing reflection on SPIR-V and disassembling SPIR-V back to high level languages.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Cross.git")
    add_versions("1.2.154+1", "e6f5ce6b8998f551f3400ad743b77be51bbe3019")
    add_versions("1.2.162+0", "6d10da0224bd3214c9a507832e62d9fb6ae9620d")
    add_versions("1.2.189+1", "0e2880ab990e79ce6cc8c79c219feda42d98b1e8")
    add_versions("1.3.231+1", "f09ba2777714871bddb70d049878af34b94fa54d")

    add_deps("cmake")
    add_links("spirv-cross-c", "spirv-cross-cpp", "spirv-cross-reflect", "spirv-cross-msl", "spirv-cross-util", "spirv-cross-hlsl", "spirv-cross-glsl", "spirv-cross-core")

    on_install("windows", "linux", "macosx", "mingw", function (package)
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
        if not package:is_cross() then
            os.vrun("spirv-cross --help")
        end
        assert(package:has_cfuncs("spvc_get_version", {includes = "spirv_cross/spirv_cross_c.h"}))
    end)
