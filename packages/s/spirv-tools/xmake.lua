package("spirv-tools")
    set_homepage("https://github.com/KhronosGroup/SPIRV-Tools/")
    set_description("SPIR-V Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Tools/archive/$(version).tar.gz",
             "https://github.com/KhronosGroup/SPIRV-Tools.git")
    add_versions("v2020.5", "947ee994ba416380bd7ccc1c6377ac28a4802a55ca81ccc06796c28e84c00b71")
    add_versions("v2020.6", "de2392682df8def7ac666a2a320cd475751badf4790b01c7391b7644ecb550a3")
    add_versions("v2021.3", "b6b4194121ee8084c62b20f8d574c32f766e4e9237dfe60b0658b316d19c6b13")
    add_versions("v2021.4", "d68de260708dda785d109ff1ceeecde2d2ab71142fa5bf59061bb9f47dd3bb2c")
    add_versions("v2022.2", "909fc7e68049dca611ca2d57828883a86f503b0353ff78bc594eddc65eb882b9")
    add_versions("v2022.4", "a156215a2d7c6c5b267933ed691877a9a66f07d75970da33ce9ad627a71389d7")
    add_versions("v2023.1", "f3d8245aeb89f098c01dddaa566f9c0f2aab4a3d62a9020afaeb676b5e7e64d4")

    add_patches("v2020.5", "https://github.com/KhronosGroup/SPIRV-Tools/commit/a1d38174b1f7d2651c718ae661886d606cb50a32.patch", "2811faeef3ad53a83e409c8ef9879badcf9dc04fc3d98dbead7313514b819933")

    add_deps("cmake", "spirv-headers")
    add_deps("python 3.x", {kind = "binary"})
    if is_plat("linux") then
        add_extsources("apt::spirv-tools", "pacman::spirv-tools")
    end

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
        assert(package:has_cxxfuncs("spvContextCreate", {configs = {languages = "c++11"}, includes = "spirv-tools/libspirv.hpp"}))
    end)
