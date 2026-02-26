package("spirv-tools")
    set_homepage("https://github.com/KhronosGroup/SPIRV-Tools/")
    set_description("SPIR-V Tools")
    set_license("Apache-2.0")

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_urls("https://github.com/KhronosGroup/SPIRV-Tools.git")
    add_versions("1.2.154+1", "sdk-1.2.154.1")
    add_versions("1.2.162+0", "sdk-1.2.162.0")
    add_versions("1.2.189+1", "sdk-1.2.189.1")
    add_versions("1.3.211+0", "sdk-1.3.211.0")
    add_versions("1.3.231+1", "sdk-1.3.231.1")
    add_versions("1.3.236+0", "sdk-1.3.236.0")
    add_versions("1.3.239+0", "sdk-1.3.239.0")
    add_versions("1.3.246+1", "sdk-1.3.246.1")
    add_versions("1.3.250+1", "sdk-1.3.250.1")
    add_versions("1.3.261+1", "sdk-1.3.261.1")
    add_versions("1.3.268+0", "vulkan-sdk-1.3.268.0")
    add_versions("1.3.275+0", "vulkan-sdk-1.3.275.0")
    add_versions("1.3.280+0", "vulkan-sdk-1.3.280.0")
    add_versions("1.3.283+0", "vulkan-sdk-1.3.283.0")
    add_versions("1.3.290+0", "vulkan-sdk-1.3.290.0")
    add_versions("1.4.309+0", "vulkan-sdk-1.4.309.0")
    add_versions("1.4.335+0", "vulkan-sdk-1.4.335.0")

    add_deps("cmake >=3.17.2")
    add_deps("python 3.x", {kind = "binary"})
    if is_plat("linux") then
        add_extsources("apt::spirv-tools", "pacman::spirv-tools")
    end

    on_load(function (package)
        local sdkver = package:version():split("%+")[1]
        package:add("deps", "spirv-headers " .. sdkver)
    end)

    on_fetch("macosx", function (package, opt)
        if opt.system then
            -- fix missing includedirs when the system library is found on macOS
            local result = package:find_package("spirv-tools")
            if result and not result.includedirs then
                for _, linkdir in ipairs(result.linkdirs) do
                    if linkdir:startswith("/usr") then
                        local includedir = path.join(path.directory(linkdir), "include", "spirv-tools")
                        if os.isdir(includedir) then
                            includedir = path.directory(includedir)
                            result.includedirs = result.includedirs or {}
                            table.insert(result.includedirs, includedir)
                        end
                    end
                end
            end
            return result
        end
    end)

    on_install(function (package)
        package:addenv("PATH", "bin")
        local configs = {"-DSPIRV_SKIP_TESTS=ON", "-DSPIRV_WERROR=OFF"}
        -- walkaround for potential conflict with parallel build & debug pdb generation
        if package:debug() then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local spirv = package:dep("spirv-headers")
        table.insert(configs, "-DSPIRV-Headers_SOURCE_DIR=" .. spirv:installdir():gsub("\\", "/"))
        if package:is_plat("windows") then
            import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
        else
            import("package.tools.cmake").install(package, configs)
        end
        package:add("links", "SPIRV-Tools-link", "SPIRV-Tools-reduce", "SPIRV-Tools-opt")
        if package:config("shared") then
            package:add("links", "SPIRV-Tools-shared")
        else
            package:add("links", "SPIRV-Tools")
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.runv("spirv-as --help")
            os.runv("spirv-opt --help")
        end
        assert(package:has_cxxfuncs("spvContextCreate", {configs = {languages = "c++17"}, includes = "spirv-tools/libspirv.hpp"}))
    end)
