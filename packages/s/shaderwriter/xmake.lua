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
    add_versions("2.6", "ab06f63bb941ac60437120e3221c024555a2bcaa")
    add_versions("2.6.1", "047ca8f5a2d2ad2fa569bd53a8325939a9d17f6c")
    add_versions("2.7", "c8af31d7589c729c450c8d08f56677bd2d355cfb")
    add_versions("2.8.1", "52dc29e13be29dd84c538584712526fa079e1e6b")
    add_versions("2.9", "c7bd2d7dcbb8d6d6219f14b31072805d3b4b8df0")

    add_patches("2.7", "patches/fix-msse2.patch", "a38f9c8cd271f89363102ba04fb07bbb14c5cf1fa7af30978f5c4592ffcb5726")
    add_patches("2.8.1", "patches/fix-msse2.patch", "a38f9c8cd271f89363102ba04fb07bbb14c5cf1fa7af30978f5c4592ffcb5726")
    add_patches("2.9", "patches/fix-msse2.patch", "a38f9c8cd271f89363102ba04fb07bbb14c5cf1fa7af30978f5c4592ffcb5726")
    add_patches("2.7", "patches/gcc16-algo.patch", "3dca08417b1fe4937688882962306ee5b10c67346bd0cce5100702088b98da88")

    add_deps("cmake")

    on_install("windows", "macosx", "linux", function (package)
        local function safe_replace(filepath, old, new, opt)
            local content = io.readfile(filepath)
            if not content then return end
            if not content:find(old, 1, true) then return end
            io.replace(filepath, old, new, opt)
        end
        
        local function ensure_algorithm_include(filepath)
            local content = io.readfile(filepath)
            if not content then return end
            if content:find("#include <algorithm>", 1, true) then return end
            io.writefile(filepath, "#include <algorithm>\n" .. content)
        end

        local configs =
        {
            "-DSDW_BUILD_TESTS=OFF",
            "-DSDW_BUILD_EXPORTERS=ON",
            "-DSDW_BUILD_STATIC_SDW=".. (package:config("shared") and "OFF" or "ON"),
            "-DSDW_GENERATE_SOURCE=OFF",
            "-DSDW_BUILD_VULKAN_LAYER=OFF",
            "-DSDW_UNITY_BUILD=ON",
            "-DPROJECTS_USE_PRECOMPILED_HEADERS=OFF",
            "-DPROJECTS_ALLOW_DEBUG_INSTALL_HEADERS=ON",
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")
        }

        ensure_algorithm_include("source/ShaderAST/Visitors/TransformSSA.cpp")

        ensure_algorithm_include("source/ShaderAST/Visitors/ResolveConstants.cpp")
        safe_replace("CMakeLists.txt", "-m64", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test()
            {
                sdw::ComputeWriter writer;
            }
        ]]}, {configs = {languages = "c++23", cxflags = "-fconcepts"},
            includes = {
                "CompilerGlsl/compileGlsl.hpp",
                "CompilerSpirV/compileSpirV.hpp",
                "ShaderWriter/Intrinsics/Intrinsics.hpp",
                "ShaderWriter/Source.hpp",
                "algorithm"}}))
    end)
