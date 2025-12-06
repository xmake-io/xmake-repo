package("glslang-nihui")
    set_homepage("https://github.com/nihui/glslang/")
    set_description("nihui's fork of KhronosGroup/glslang for C++14 compatibility. Mainly for Tencent/ncnn")
    set_license("Apache-2.0")

    add_urls("https://github.com/nihui/glslang.git")

    add_versions("20250916", "cpp14-2")  -- 8cd77a808d0bffa442ae9462d5e3a8141892ba5a
    add_versions("20250503", "a9ac7d5f307e5db5b8c4fbf904bdba8fca6283bc")

    add_configs("binaryonly",   {description = "Only use binary program.", default = false, type = "boolean"})
    add_configs("spv_remapper", {description = "Enable building of SPVRemapper.", default = false, type = "boolean"})
    add_configs("spirv_tools",  {description = "Enable SPIRV-Tools integration (Optimizer).", default = false, type = "boolean"})
    add_configs("hlsl",         {description = "Enable HLSL support.", default = false, type = "boolean"})
    add_configs("rtti",         {description = "Build with RTTI support.", default = false, type = "boolean"})
    add_configs("exceptions",   {description = "Build with exception support.", default = false, type = "boolean"})
    add_configs("tools",        {description = "Build the glslangValidator tool.", default = false, type = "boolean"})
    add_configs("default_resource_limits", {description = "Build with default resource limits.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("binaryonly") then
            package:set("kind", "binary")
            package:config_set("tools", true)
        end
        if package:config("spirv_tools") or package:config("tools") then
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        if package:config("spirv_tools") then
            package:add("deps", "spirv-tools")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and package:config("binaryonly") then
            return package:find_tool("glslangValidator")
        end
    end)

    on_install(function (package)
        package:addenv("PATH", "bin")

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
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            if package:is_debug() then
                table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            end
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
        table.insert(configs, "-DENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_HLSL=" .. (package:config("hlsl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SPVREMAPPER=" .. (package:config("spv_remapper") and "ON" or "OFF"))
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
        if not package:config("binaryonly") then
            package:add("links", "glslang", "MachineIndependent", "GenericCodeGen", "OGLCompiler", "OSDependent", "SPIRV")
            if package:config("spv_remapper") then
                package:add("links", "SPVRemapper")
            end
            if package:config("hlsl") then
                package:add("links", "HLSL")
            end
        end
        if package:config("default_resource_limits") then
            package:add("links", "glslang-default-resource-limits")
        end

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
    end)

    on_test(function (package)
        if not package:is_cross() and package:config("tools") then
            os.vrun("glslangValidator --version")
        end

        if not package:config("binaryonly") then
            assert(package:has_cxxfuncs("ShInitialize", {configs = {languages = "c++11"}, includes = "glslang/Public/ShaderLang.h"}))
        end
    end)
