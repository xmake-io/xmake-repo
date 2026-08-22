package("glslang")
    set_homepage("https://github.com/KhronosGroup/glslang/")
    set_description("Khronos-reference front end for GLSL/ESSL, partial front end for HLSL, and a SPIR-V generator.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/glslang.git")

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_versions("1.2.154+1", "bacaef3237c515e40d1a24722be48c0a0b30f75f")
    add_versions("1.2.162+0", "c594de23cdd790d64ad5f9c8b059baae0ee2941d")
    add_versions("1.2.189+1", "2fb89a0072ae7316af1c856f22663fde4928128a")
    add_versions("1.3.211+0", "9bb8cfffb0eed010e07132282c41d73064a7a609")
    add_versions("1.3.231+1", "5755de46b07e4374c05fb1081f65f7ae1f8cca81")
    add_versions("1.3.236+0", "77551c429f86c0e077f26552b7c1c0f12a9f235e")
    add_versions("1.3.239+0", "ca8d07d0bc1c6390b83915700439fa7719de6a2a")
    add_versions("1.3.246+1", "14e5a04e70057972eef8a40df422e30a3b70e4b5")
    add_versions("1.3.250+1", "d1517d64cfca91f573af1bf7341dc3a5113349c0")
    add_versions("1.3.261+1", "76b52ebf77833908dc4c0dd6c70a9c357ac720bd")
    add_versions("1.3.268+0", "36d08c0d940cf307a23928299ef52c7970d8cee6")
    add_versions("1.3.275+0", "a91631b260cba3f22858d6c6827511e636c2458a")
    add_versions("1.3.280+0", "ee2f5d09eaf8f4e8d0d598bd2172fce290d4ca60")
    add_versions("1.3.283+0", "e8dd0b6903b34f1879520b444634c75ea2deedf5")
    add_versions("1.3.290+0", "fa9c3deb49e035a8abcabe366f26aac010f6cbfb")
    add_versions("1.4.309+0", "7200bc12a8979d13b22cd52de80ffb7d41939615")
    add_versions("1.4.335+0", "b5782e52ee2f7b3e40bb9c80d15b47016e008bc9")

    add_patches("1.3.246+1", "https://github.com/KhronosGroup/glslang/commit/1e4955adbcd9b3f5eaf2129e918ca057baed6520.patch", "47893def550f1684304ef7c49da38f0a8fe35c190a3452d3bf58370b3ee7165d")

    add_configs("binaryonly",  {description = "Only use binary program.", default = false, type = "boolean"})
    add_configs("exceptions",  {description = "Build with exception support.", default = false, type = "boolean"})
    add_configs("spirv_tools", {description = "Enable SPIRV-Tools integration (Optimizer).", default = false, type = "boolean"})
    add_configs("hlsl",        {description = "Enable HLSL support.", default = true, type = "boolean"})
    add_configs("rtti",        {description = "Build with RTTI support.", default = false, type = "boolean"})
    add_configs("tools",       {description = "Build the glslangValidator tool.", default = false, type = "boolean"})
    add_configs("default_resource_limits", {description = "Build with default resource limits.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_binary() or package:config("binaryonly") then
            package:config_set("tools", true)
            package:set("kind", "binary")
        end
        if package:config("spirv_tools") or package:config("tools") then
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        if package:config("spirv_tools") then
            package:add("deps", "spirv-tools")
        end

        if package:config("tools") then
            package:addenv("PATH", "bin")
        end
        package:add("links", "glslang", "MachineIndependent", "GenericCodeGen", "OGLCompiler", "OSDependent", "SPIRV", "SPVRemapper")
        if package:config("hlsl") then
            package:add("links", "HLSL")
        end
        if package:config("default_resource_limits") then
            package:add("links", "glslang-default-resource-limits")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and package:is_binary() then
            return package:find_tool("glslangValidator")
        end
    end)

    on_install(function (package)
        if package:config("spirv_tools") then
            io.replace("StandAlone/CMakeLists.txt", "target_link_libraries(glslangValidator ${LIBRARIES})", [[
                target_link_libraries(glslangValidator ${LIBRARIES} SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
            ]], {plain = true})
            io.replace("SPIRV/CMakeLists.txt", "target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt)", [[
                target_link_libraries(SPIRV PRIVATE MachineIndependent SPIRV-Tools-opt SPIRV-Tools-link SPIRV-Tools-reduce SPIRV-Tools)
            ]], {plain = true})
        end

        -- glslang will add a debug lib postfix for win32 platform, disable this to fix compilation issues under windows
        io.replace("CMakeLists.txt", 'set(CMAKE_DEBUG_POSTFIX "d")', [[
            message(WARNING "Disabled CMake Debug Postfix for xmake package generation")
        ]], {plain = true})

        if package:is_plat("wasm") then
            -- wasm-ld doesn't support --no-undefined
            io.replace("CMakeLists.txt", [[add_link_options("-Wl,--no-undefined")]], "", {plain = true})
        end

        local configs = {"-DENABLE_CTEST=OFF", "-DGLSLANG_TESTS=OFF", "-DBUILD_EXTERNAL=OFF", "-DENABLE_PCH=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and not package:config("binaryonly") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_HLSL=" .. (package:config("hlsl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_GLSLANG_BINARIES=" .. (package:config("tools") and "ON" or "OFF"))

        local packagedeps = {}
        if package:config("spirv_tools") then
            table.insert(configs, "-DENABLE_OPT=ON")
            table.insert(configs, "-DALLOW_EXTERNAL_SPIRV_TOOLS=ON")
            table.insert(packagedeps, "spirv-tools")
        else
            table.insert(configs, "-DENABLE_OPT=OFF")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})

        if package:is_binary() then
            os.rm(package:installdir("*|bin"))
        else
            os.cp("glslang/MachineIndependent/**.h", package:installdir("include", "glslang", "MachineIndependent"))
            os.cp("glslang/Include/**.h", package:installdir("include", "glslang", "Include"))

            -- https://github.com/KhronosGroup/glslang/releases/tag/12.3.0
            if package:config("tools") then
                local bindir = package:installdir("bin")
                local glslangValidator = path.join(bindir, "glslangValidator" .. (is_host("windows") and ".exe" or ""))
                if not os.isfile(glslangValidator) then
                    local glslang = path.join(bindir, "glslang" .. (is_host("windows") and ".exe" or ""))
                    os.trycp(glslang, glslangValidator)
                end
            end
        end
    end)

    on_test(function (package)
        if not package:is_cross() and package:config("tools") then
            os.vrun("glslangValidator --version")
        end

        if not package:is_binary() then
            assert(package:has_cxxfuncs("ShInitialize", {configs = {languages = "c++11"}, includes = "glslang/Public/ShaderLang.h"}))
        end
    end)
