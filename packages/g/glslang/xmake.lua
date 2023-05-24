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
    add_versions("1.3.236+0", "77551c429f86c0e077f26552b7c1c0f12a9f235e")
    add_versions("1.3.239+0", "ca8d07d0bc1c6390b83915700439fa7719de6a2a")
    add_versions("1.3.246+1", "14e5a04e70057972eef8a40df422e30a3b70e4b5")

    add_patches("1.3.246+1", "https://github.com/KhronosGroup/glslang/commit/1e4955adbcd9b3f5eaf2129e918ca057baed6520.patch", "47893def550f1684304ef7c49da38f0a8fe35c190a3452d3bf58370b3ee7165d")

    add_configs("binaryonly", {description = "Only use binary program.", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Build with exception support.", default = false, type = "boolean"})
    add_configs("rtti",       {description = "Build with RTTI support.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

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

    on_install(function (package)
        package:addenv("PATH", "bin")
        io.replace("CMakeLists.txt", "ENABLE_OPT OFF", "ENABLE_OPT ON")
        io.replace("StandAlone/CMakeLists.txt", "target_link_libraries(glslangValidator ${LIBRARIES})", [[
            target_link_libraries(glslangValidator ${LIBRARIES} SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
        ]], {plain = true})
        io.replace("SPIRV/CMakeLists.txt", "target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt)", [[
            target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
        ]], {plain = true})
        -- glslang will add a debug lib postfix for win32 platform, disable this to fix compilation issues under windows
        io.replace("CMakeLists.txt", 'set(CMAKE_DEBUG_POSTFIX "d")', [[
            message(WARNING "Disabled CMake Debug Postfix for xmake package generation")
        ]], {plain = true})
        if package:is_plat("wasm") then
            -- wasm-ld doesn't support --no-undefined
            io.replace("CMakeLists.txt", [[add_link_options("-Wl,--no-undefined")]], "", {plain = true})
        end
        local configs = {"-DENABLE_CTEST=OFF", "-DBUILD_EXTERNAL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            if package:debug() then
                table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            end
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
