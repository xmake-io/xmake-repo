package("glslang")

    set_homepage("https://github.com/KhronosGroup/glslang/")
    set_description("Khronos-reference front end for GLSL/ESSL, partial front end for HLSL, and a SPIR-V generator.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/glslang.git")
    add_versions("1.2.154+1", "bacaef3237c515e40d1a24722be48c0a0b30f75f")
    add_versions("1.2.162+0", "c594de23cdd790d64ad5f9c8b059baae0ee2941d")
    add_versions("1.2.189+1", "2fb89a0072ae7316af1c856f22663fde4928128a")
    add_versions("1.3.211+0", "9bb8cfffb0eed010e07132282c41d73064a7a609")
    add_versions("1.3.231+1", "5755de46b07e4374c05fb1081f65f7ae1f8cca81")

    add_configs("binaryonly", {description = "Only use binary program.", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Build with exception support.", default = false, type = "boolean"})
    add_configs("rtti",       {description = "Build with RTTI support.", default = false, type = "boolean"})

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("spirv-tools")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("binaryonly") then
            package:set("kind", "binary")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and package:config("binaryonly") then
            return package:find_tool("glslangValidator")
        end
    end)

    on_install("linux", "windows", "macosx", "mingw", function (package)
        package:addenv("PATH", "bin")
        io.replace("CMakeLists.txt", "ENABLE_OPT OFF", "ENABLE_OPT ON")
        io.replace("StandAlone/CMakeLists.txt", "target_link_libraries(glslangValidator ${LIBRARIES})", [[
            target_link_libraries(glslangValidator ${LIBRARIES} SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
        ]], {plain = true})
        io.replace("SPIRV/CMakeLists.txt", "target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt)", [[
            target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
        ]], {plain = true})
        local configs = {"-DENABLE_CTEST=OFF", "-DBUILD_EXTERNAL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
        table.insert(configs, "-DENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"spirv-tools"}})
        if not package:config("binaryonly") then
            package:add("links", "glslang", "MachineIndependent", "GenericCodeGen", "OGLCompiler", "OSDependent", "HLSL", "SPIRV", "SPVRemapper")
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("glslangValidator --version")
        end
        if not package:config("binaryonly") then
            assert(package:has_cxxfuncs("ShInitialize", {configs = {languages = "c++11"}, includes = "glslang/Public/ShaderLang.h"}))
        end
    end)
