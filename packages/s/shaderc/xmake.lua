package("shaderc")
    set_homepage("https://github.com/google/shaderc")
    set_description("A collection of tools, libraries, and tests for Vulkan shader compilation.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/shaderc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/shaderc.git")

    add_versions("v2022.2", "517d36937c406858164673db696dc1d9c7be7ef0960fbf2965bfef768f46b8c0")

    add_configs("exceptions", {description = "Enable exception handling", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:is_binary() then
            package:set("kind", "binary")
        else
            if package:version():ge("2022.3") then
                package:add("deps", "glslang")
            else
                -- real version: glslang <1.3.231.0
                package:add("deps", "glslang <=1.3.211")
            end
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
        opt.cxflags = {}
        if package:has_tool("ld", "link") or package:has_tool("sh", "link") then
            opt.packagedeps = {"glslang", "spirv-tools", "spirv-headers"}
        else
            opt.ldflags = {}
            opt.shflags = {}
            for _, dep in ipairs({"glslang", "spirv-tools", "spirv-headers"}) do
                local fetchinfo = package:dep(dep):fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(opt.cxflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(opt.ldflags, "-L" .. linkdir)
                        table.insert(opt.shflags, "-L" .. linkdir)
                    end
                end
            end
        end
        io.replace("CMakeLists.txt", "add_subdirectory(third_party)", "", {plain = true})
        io.replace("libshaderc_util/src/compiler.cc", "SPIRV/GlslangToSpv.h", "glslang/SPIRV/GlslangToSpv.h", {plain = true})

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
            table.insert(configs, "-DSHADERC_ENABLE_SHARED_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "OFF" or "ON"))
        end

        if package:config("exceptions") then
            table.insert(configs, "-DDISABLE_EXCEPTIONS=OFF")
            if package:is_plat("windows") and package:has_tool("cxx", "cl", "clang_cl") then
                table.insert(opt.cxflags, "/EHsc")
            end
        else
            table.insert(configs, "-DDISABLE_EXCEPTIONS=ON")
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("glslc --version")
        end

        if not package:is_binary() then
            assert(package:has_cfuncs("shaderc_compiler_initialize", {includes = "shaderc/shaderc.h"}))
        end
    end)
