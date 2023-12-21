package("directxshadercompiler")

    set_homepage("https://github.com/microsoft/DirectXShaderCompiler/")
    set_description("DirectX Shader Compiler")
    set_license("LLVM")

    local date = {["1.5.2010"] = "2020_10-22",
                  ["1.6.2104"] = "2021_04-20",
                  ["1.6.2106"] = "2021_07_01",
                  ["1.7.2212"] = "2022_12_16"}
    if is_plat("windows") then 
        add_urls("https://github.com/microsoft/DirectXShaderCompiler/releases/download/v$(version).zip", {version = function (version) return version .. "/dxc_" .. date[tostring(version)] end})
        add_versions("1.5.2010", "b691f63778f470ebeb94874426779b2f60685fc8711adf1b1f9f01535d9b67f8")
        add_versions("1.6.2104", "ee5e96d58134957443ded04be132e2e19240c534d7602e3ab8fd5adc5156014a")
        add_versions("1.6.2106", "053b2d90c227cae84e7ce636bc4f7c25acd224c31c11a324885acbf5dd8b7aac")
        add_versions("1.7.2212", "ed77c7775fcf1e117bec8b5bb4de6735af101b733d3920dda083496dceef130f")
    elseif is_plat("linux") and is_arch("x86_64") then 
        add_urls("https://github.com/microsoft/DirectXShaderCompiler.git")
        add_versions("v1.7.2212", "f2643f8699299ab4e77421952e9c24f7483b46896d9f4cc6b4790b22c90d2ff0")
        
        add_patches("v1.7.2212", path.join(os.scriptdir(), "patches", "disable_go_bindings.patch"), "2337f4f94d4c27c3caf0e6b0f00efd1bee719f79c0bb3b0d7e74c2859546c73a")

        add_extsources("pacman::directx-shader-compiler")
        add_deps("cmake", "ninja")
    end

    add_configs("shared", {description = "Using shared binaries.", default = true, type = "boolean", readonly = true})

    on_install("windows|x64", function (package)
        os.cp("bin/x64/*", package:installdir("bin"))
        os.cp("inc/*", package:installdir("include"))
        os.cp("lib/x64/*", package:installdir("lib"))
        package:addenv("PATH", "bin")
    end)

    on_install("linux|x86_64", function (package)
        local configs = {
            "-C ../cmake/caches/PredefinedParams.cmake"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").build(package, configs, {cmake_generator = "Ninja", buildir = "build"})

        if package:has_tool("cxx", "clang") then
            package:add("cxxflags", "-fms-extensions")
        end
        os.cp("build/bin/dxc", package:installdir("bin"))
        os.cp("include/dxc", package:installdir("include"))
        os.cp("build/lib/libdxcompiler.so*", package:installdir("lib"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dxc -help")
        if package:is_plat("windows") then
            assert(package:has_cxxfuncs("DxcCreateInstance", {includes = {"windows.h", "dxcapi.h"}}))
        elseif package:is_plat("linux") then
            assert(package:has_cxxfuncs("DxcCreateInstance", {includes = {"dxc/dxcapi.h"}}))
        end
    end)
