package("spirv-reflect")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Reflect")
    set_description("SPIRV-Reflect is a lightweight library that provides a C/C++ reflection API for SPIR-V shader bytecode in Vulkan applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Reflect.git")
    add_versions("1.2.154+1", "5de48fe8d3ef434e846d64ed758adc5d26335ae5")
    add_versions("1.2.162+0", "481e34d666031eae28423f3b723a1a8c717d7636")
    add_versions("1.2.189+1", "272e050728de8d4a4ce9e7101c1244e6ff56e5b0")
    add_versions("1.3.231+1", "b68b5a8a5d8ab5fce79e6596f3a731291046393a")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("spirv-headers")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.gsub("spirv_reflect.h", "#include \"%.%/include%/spirv%/unified1%/spirv.h\"", "#include \"spirv/unified1/spirv.h\"")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("spirv-headers")
            target("spirv-reflect-static")
                set_kind("static")
                add_packages("spirv-headers", {public = true})
                add_files("spirv_reflect.c")
                add_headerfiles("spirv_reflect.h")
            target("spirv-reflect")
                set_kind("binary")
                set_languages("c++11")
                add_deps("spirv-reflect-static")
                add_includedirs(".")
                add_files("main.cpp", "examples/arg_parser.cpp", "examples/common.cpp", "common/output_stream.cpp")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spvReflectGetCodeSize", {includes = "spirv_reflect.h"}))
    end)
