package("shaderwriter")

    set_homepage("https://github.com/DragonJoker/ShaderWriter")
    set_description("Library used to write shaders from C++, and export them in either GLSL, HLSL or SPIR-V.")

    set_urls("https://github.com/DragonJoker/ShaderWriter.git")
    add_versions("0.1", "a5ef99ff141693ef28cee0e464500888cabc65ad")
    add_versions("1.0", "7d506b6864edb5f357ed8993512f5a3618a4ddc1")
    add_versions("1.1", "e7ddabe2b9ec6279951f4dcfe6a803d42d0e9052")
    add_versions("2.0", "9e7488290713f88149038ef56fdc4034c3a1dd7f")
    add_versions("2.1", "eec963d7c0d9a88741ed357bcc931a8de763ddb7")
    add_versions("2.2", "eec963d7c0d9a88741ed357bcc931a8de763ddb7")
    add_versions("2.3", "8e7769ddf4b008b0c7de3140126fcfb30607879e")
    add_versions("2.4", "ec31f19f88fe15af476b48da7499aac9d4089a8f")
    add_versions("2.5", "4b456bb6f36103936f4862edff397af943a40621")
    add_versions("2.6", "d040c89bb543b2e1d646714e36a190816b8e06ef")

    add_deps("cmake")

    add_links("sdwShaderWriter", "sdwCompilerHlsl", "sdwCompilerGlsl", "sdwCompilerSpirV", "sdwShaderAST")

    on_install("windows", "macosx", "linux", function (package)
        local configs =
        {
            "-DSDW_BUILD_TESTS=OFF",
            "-DSDW_BUILD_EXPORTERS=ON",
            "-DSDW_BUILD_STATIC_SDW=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_GENERATE_SOURCE=OFF",
            "-DSDW_BUILD_VULKAN_LAYER=OFF",
            "-DSDW_UNITY_BUILD=ON",
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
        ]]}, {configs = {languages = "cxx20", cxflags = "-fconcepts"},
            includes = {
                "CompilerGlsl/compileGlsl.hpp",
                "CompilerSpirV/compileSpirV.hpp",
                "ShaderWriter/Intrinsics/Intrinsics.hpp",
                "ShaderWriter/Source.hpp"}}))
    end)
