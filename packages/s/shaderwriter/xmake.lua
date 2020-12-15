package("shaderwriter")

    set_homepage("https://github.com/DragonJoker/ShaderWriter")
    set_description("Library used to write shaders from C++, and export them in either GLSL, HLSL or SPIR-V.")

    set_urls("https://github.com/DragonJoker/ShaderWriter.git")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
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
