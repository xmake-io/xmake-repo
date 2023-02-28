package("directxshadercompiler")

    set_homepage("https://github.com/microsoft/DirectXShaderCompiler/")
    set_description("DirectX Shader Compiler")
    set_license("LLVM")

    local date = {["1.5.2010"] = "2020_10-22",
                  ["1.6.2104"] = "2021_04-20",
                  ["1.6.2106"] = "2021_07_01",
                  ["1.7.2212"] = "2022_12_16"}
    if is_host("windows") then 
        add_urls("https://github.com/microsoft/DirectXShaderCompiler/releases/download/v$(version).zip", {version = function (version) return version .. "/dxc_" .. date[tostring(version)] end})
        add_versions("1.5.2010", "b691f63778f470ebeb94874426779b2f60685fc8711adf1b1f9f01535d9b67f8")
        add_versions("1.6.2104", "ee5e96d58134957443ded04be132e2e19240c534d7602e3ab8fd5adc5156014a")
        add_versions("1.6.2106", "053b2d90c227cae84e7ce636bc4f7c25acd224c31c11a324885acbf5dd8b7aac")
        add_versions("1.7.2212", "ed77c7775fcf1e117bec8b5bb4de6735af101b733d3920dda083496dceef130f")
    elseif is_host("linux") and os.arch() == "x86_64" then 
        add_urls("https://github.com/microsoft/DirectXShaderCompiler/releases/download/v$(version).tar.gz", {version = function (version) return version .. "/linux_dxc_" .. date[tostring(version)] end})
        add_versions("1.7.2212", "bfb453bd844d52575d2fe0db477701c33db4507e14a89e85128aca8608b5c359")
        add_extsources("pacman::directx-shader-compiler")
    end
    
    on_install("windows|x64", "linux|x86_64", function (package)
        os.cp("bin/x64/*", package:installdir("bin"))
        os.cp("inc/*", package:installdir("include"))
        os.cp("lib/x64/*", package:installdir("lib"))

        if is_host("linux") then 
            os.mv(package:installdir("include/WinAdapter.h"), package:installdir("include/dxc/Support"))
            os.vrunv("chmod", {"+x", path.join(package:installdir("bin"), "dxc")})
            os.vrunv("ln", {"-s", path.join(package:installdir("lib"), "libdxcompiler.so"), path.join(package:installdir("lib"), "libdxcompiler.so.3.7")})
            if package:has_tool("cxx", "clang") then
                package:add("cxxflags", "-fms-extensions")
            end
        end

        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dxc -help")
        if is_plat("windows") then
            assert(package:has_cxxfuncs("DxcCreateInstance", {includes = {"windows.h", "dxcapi.h"}}))
        elseif is_plat("linux") then
            assert(package:has_cxxfuncs("DxcCreateInstance", {includes = {"dxcapi.h"}}))
        end
    end)
