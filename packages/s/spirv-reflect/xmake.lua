package("spirv-reflect")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Reflect")
    set_description("SPIRV-Reflect is a lightweight library that provides a C/C++ reflection API for SPIR-V shader bytecode in Vulkan applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Reflect.git")
    add_versions("1.2.154+1", "5de48fe8d3ef434e846d64ed758adc5d26335ae5")
    add_versions("1.2.162+0", "481e34d666031eae28423f3b723a1a8c717d7636")
    add_versions("1.2.189+1", "272e050728de8d4a4ce9e7101c1244e6ff56e5b0")

    add_deps("spirv-headers")

    on_install("windows", "linux", "macosx", function (package)
        io.gsub("spirv_reflect.h", "#include \"%.%/include%/spirv%/unified1%/spirv.h\"", "#include \"spirv/unified1/spirv.h\"")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("spirv-headers")
            target("spirv-reflect")
                set_kind("static")
                add_packages("spirv-headers")
                add_files("spirv_reflect.c")
                add_headerfiles("spirv_reflect.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spvReflectGetCodeSize", {includes = "spirv_reflect.h"}))
    end)
