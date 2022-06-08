package("shaderwriter")

    set_homepage("https://github.com/DragonJoker/ShaderWriter")
    set_description("Library used to write shaders from C++, and export them in either GLSL, HLSL or SPIR-V.")

    set_urls("https://github.com/DragonJoker/ShaderWriter/archive/refs/tags/$(version).tar.gz",
        "https://github.com/DragonJoker/ShaderWriter.git")
    add_versions("v1.0.0", "30729d7f610c4ff24e9b46702c9729b3f68b637fc72d38bd1a1664ba39dd9329")
    add_versions("v1.1.0", "02e25288c238792f79b32ec402e514951709116023277b3dc02072add0352134")
    add_versions("v2.0.0", "79315247617ebb5a6b15fa3062c3d3bff48b83692a9f13760d53ce98c722fff3")
    add_versions("v2.1.0", "2821ec26b5969f652c2746ff145d93b2981355d7db417db544b41d6710521059")
    add_versions("v2.2.0", "a9fca4453be9f8d2b57a6deb5af4679eb10af518bb4db0426292e95238e93c79")
    add_versions("v2.3.0", "d88ecccb74e02d302bcd40cde4ccf706e249b352494253312f21cca2fedd0113")

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
        ]]}, {configs = {languages = "cxx20"},
            includes = {
                "CompilerGlsl/compileGlsl.hpp",
                "CompilerSpirV/compileSpirV.hpp",
                "ShaderWriter/Intrinsics/Intrinsics.hpp",
                "ShaderWriter/Source.hpp"}}))
    end)
