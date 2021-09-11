package("spirv-tools")

    set_homepage("https://github.com/KhronosGroup/SPIRV-Tools/")
    set_description("SPIR-V Tools")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/SPIRV-Tools/archive/v$(version).tar.gz")
    add_versions("2020.5", "947ee994ba416380bd7ccc1c6377ac28a4802a55ca81ccc06796c28e84c00b71")
    add_versions("2020.6", "de2392682df8def7ac666a2a320cd475751badf4790b01c7391b7644ecb550a3")
    add_versions("2021.3", "b6b4194121ee8084c62b20f8d574c32f766e4e9237dfe60b0658b316d19c6b13")

    add_patches("2020.5", "https://github.com/KhronosGroup/SPIRV-Tools/commit/a1d38174b1f7d2651c718ae661886d606cb50a32.patch", "2811faeef3ad53a83e409c8ef9879badcf9dc04fc3d98dbead7313514b819933")

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("spirv-headers")
    if is_plat("linux") then
        add_extsources("apt::spirv-tools")
    end

    on_install("linux", "windows", "macosx", function (package)
        package:addenv("PATH", "bin")
        local configs = {"-DSPIRV_SKIP_TESTS=ON"}
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
        os.runv("spirv-as --help")
        os.runv("spirv-opt --help")
        assert(package:has_cxxfuncs("spvContextCreate", {configs = {languages = "c++11"}, includes = "spirv-tools/libspirv.hpp"}))
    end)
