package("shaderwriter")

    set_homepage("https://github.com/DragonJoker/ShaderWriter")
    set_description("Library used to write shaders from C++, and export them in either GLSL, HLSL or SPIR-V.")

    set_urls("https://github.com/DragonJoker/ShaderWriter.git")
    add_versions("1.0", "c378a373e66735882903ffefc8e467dc07b46d27")

    add_deps("cmake")

    add_links("sdwShaderWriter", "sdwCompilerHlsl", "sdwCompilerGlsl", "sdwCompilerSpirV", "sdwShaderAST")

    on_install("windows", "macosx", "linux", function (package)
        local configs =
        {
            "-DSDW_BUILD_TESTS=OFF",
            "-DSDW_BUILD_EXPORTERS=ON",
            "-DSDW_BUILD_STATIC_SDW=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_BUILD_EXPORTER_GLSL_STATIC=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_BUILD_EXPORTER_HLSL_STATIC=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_BUILD_EXPORTER_SPIRV_STATIC=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_GENERATE_SOURCE=OFF",
            "-DPROJECTS_USE_PRECOMPILED_HEADERS=OFF",
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")
        }
        import("package.tools.cmake").install(package, configs)
        if not package:is_plat("windows") then
            -- fix sdwCompilerHlsl.a to libsdwCompilerHlsl.a
            local libdir = package:installdir("lib")
            for _, libfile in ipairs(os.files(path.join(libdir, "*.a"))) do
                os.mv(libfile, path.join(libdir, "lib" .. path.filename(libfile)))
            end
            for _, libfile in ipairs(os.files(path.join(libdir, "*.so"))) do
                os.mv(libfile, path.join(libdir, "lib" .. path.filename(libfile)))
            end
            for _, libfile in ipairs(os.files(path.join(libdir, "*.dylib"))) do
                os.mv(libfile, path.join(libdir, "lib" .. path.filename(libfile)))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <CompilerGlsl/compileGlsl.hpp>
            #include <CompilerSpirV/compileSpirV.hpp>
            #include <ShaderWriter/Intrinsics/Intrinsics.hpp>
            #include <ShaderWriter/Source.hpp>
            static void test()
            {
                sdw::ComputeWriter writer;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
