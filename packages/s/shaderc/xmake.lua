package("shaderc")
    set_homepage("https://github.com/google/shaderc")
    set_description("A collection of tools, libraries, and tests for Vulkan shader compilation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/shaderc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/shaderc.git")

    add_versions("v2025.3", "a8e4a25e5c2686fd36981e527ed05e451fcfc226bddf350f4e76181371190937")
    add_versions("v2024.1", "eb3b5f0c16313d34f208d90c2fa1e588a23283eed63b101edd5422be6165d528")
    add_versions("v2024.0", "c761044e4e204be8e0b9a2d7494f08671ca35b92c4c791c7049594ca7514197f")
    add_versions("v2022.2", "517d36937c406858164673db696dc1d9c7be7ef0960fbf2965bfef768f46b8c0")

    add_configs("binaryonly", {description = "Only use binary program.", default = false, type = "boolean"})
    add_configs("exceptions", {description = "Enable exception handling", default = true, type = "boolean"})
    if is_plat("windows", "wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("binaryonly") then
            package:set("kind", "binary")
        end

        if package:version():ge("2022.3") then
            package:add("deps", "glslang")
        else
            -- real version: glslang <1.3.231.0
            package:add("deps", "glslang <=1.3.211")
        end
        package:add("deps", "spirv-tools", "spirv-headers")

        if package:config("shared") then
            package:add("links", "shaderc_shared")
        else
            package:add("links", "shaderc_combined")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and package:is_binary() then
            return package:find_tool("glslc")
        end
    end)

    on_install(function (package)
        local opt = {}
        opt.packagedeps = {"glslang", "spirv-tools", "spirv-headers"}
        io.replace("CMakeLists.txt", "add_subdirectory(third_party)", "", {plain = true})
        io.replace("libshaderc_util/src/compiler.cc", "SPIRV/GlslangToSpv.h", "glslang/SPIRV/GlslangToSpv.h", {plain = true})

        if not package:has_tool("sh", "link") then
            local links = {}
            for _, dep in ipairs({"glslang", "spirv-tools"}) do
                local fetchinfo = package:dep(dep):fetch()
                if fetchinfo then
                    for _, link in ipairs(fetchinfo.links) do
                        table.insert(links, link)
                    end
                end
            end
            if package:version():ge("2023.8") then
                io.replace("libshaderc_util/CMakeLists.txt", "glslang SPIRV", table.concat(links, " "), {plain = true})
            else
                io.replace("glslc/CMakeLists.txt", "glslang OSDependent OGLCompiler HLSL glslang SPIRV", "", {plain = true})
                io.replace("libshaderc_util/CMakeLists.txt", "glslang OSDependent OGLCompiler HLSL glslang SPIRV", table.concat(links, " "), {plain = true})
            end
            links = table.join({"shaderc", "shaderc_util"}, links)
            io.replace("glslc/CMakeLists.txt", "shaderc_util shaderc", table.concat(links, " "), {plain = true})
        end
        -- glslc --version
        local version_str = format("shaderc %s\nspirv-tools %s\nglslang %s\0", 
            package:version(),
            package:dep("spirv-tools"):version(),
            package:dep("glslang"):version()
        )

        -- const char[] = {'s', 'h' ...};
        local version_c_array = "{"
        for i = 1, #version_str do
            local char = version_str:sub(i, i)
            if char == "\n" then
                char = [[\n]]
            end
            if char == "\0" then
                char = [[\0]]
            end
            version_c_array = format([[%s'%s',]], version_c_array, char)
        end
        version_c_array = version_c_array .. "}"

        -- remove python codegen
        io.writefile("glslc/src/build-version.inc", version_c_array)
        io.replace("glslc/CMakeLists.txt", "add_dependencies(glslc_exe build-version)", "", {plain = true})

        local configs = {
            "-DSHADERC_SKIP_EXAMPLES=ON",
            "-DSHADERC_SKIP_TESTS=ON",
            "-DSHADERC_ENABLE_COPYRIGHT_CHECK=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})
            io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
            table.insert(configs, "-DSHADERC_ENABLE_SHARED_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
        end

        if package:config("exceptions") then
            table.insert(configs, "-DDISABLE_EXCEPTIONS=OFF")
            if package:is_plat("windows") and package:has_tool("cxx", "cl", "clang_cl") then
                opt.cxflags = "/EHsc"
            end
        else
            table.insert(configs, "-DDISABLE_EXCEPTIONS=ON")
        end
        import("package.tools.cmake").install(package, configs, opt)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("glslc --version")
        end

        if not package:is_binary() then
            assert(package:has_cfuncs("shaderc_compiler_initialize", {includes = "shaderc/shaderc.h"}))
        end
    end)
