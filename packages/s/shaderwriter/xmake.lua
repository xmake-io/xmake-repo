package("shaderwriter")

    set_homepage("https://github.com/DragonJoker/ShaderWriter")
    set_description("Library used to write shaders from C++, and export them in either GLSL, HLSL or SPIR-V.")

    set_urls("https://github.com/DragonJoker/ShaderWriter.git")
    add_versions("0.1", "a5ef99ff141693ef28cee0e464500888cabc65ad")
    add_versions("1.0", "7d506b6864edb5f357ed8993512f5a3618a4ddc1")
    add_versions("1.1", "e7ddabe2b9ec6279951f4dcfe6a803d42d0e9052")
    add_versions("2.0", "9e7488290713f88149038ef56fdc4034c3a1dd7f")

    add_deps("cmake")

    add_links("sdwShaderWriter", "sdwCompilerHlsl", "sdwCompilerGlsl", "sdwCompilerSpirV", "sdwShaderAST")

    on_install("windows", "macosx", "linux", function (package)
        local configs =
        {
            "-DSDW_BUILD_TESTS=OFF",
            "-DSDW_BUILD_EXPORTERS=ON",
            "-DSDW_BUILD_STATIC_SDW=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_BUILD_STATIC_SDAST=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_GENERATE_SOURCE=OFF",
            "-DSDW_BUILD_VULKAN_LAYER=OFF",
            "-DPROJECTS_USE_PRECOMPILED_HEADERS=OFF",
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test()
            {
                sdw::ComputeWriter writer;
            }
        ]]}, {configs = {languages = "c++17"},
            includes = {
                "CompilerGlsl/compileGlsl.hpp",
                "CompilerSpirV/compileSpirV.hpp",
                "ShaderWriter/Intrinsics/Intrinsics.hpp",
                "ShaderWriter/Source.hpp"}}))
    end)
