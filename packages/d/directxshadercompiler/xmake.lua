package("directxshadercompiler")

    set_homepage("https://github.com/microsoft/DirectXShaderCompiler/")
    set_description("DirectX Shader Compiler")
    set_license("LLVM")

    local date = {["1.5.2010"] = "2020_10-22",
                  ["1.6.2104"] = "2021_04-20"}
    add_urls("https://github.com/microsoft/DirectXShaderCompiler/releases/download/v$(version).zip", {version = function (version) return version .. "/dxc_" .. date[tostring(version)] end})
    add_versions("1.5.2010", "b691f63778f470ebeb94874426779b2f60685fc8711adf1b1f9f01535d9b67f8")
    add_versions("1.6.2104", "ee5e96d58134957443ded04be132e2e19240c534d7602e3ab8fd5adc5156014a")

    on_install("windows|x64", function (package)
        os.cp("bin/x64/*", package:installdir("bin"))
        os.cp("inc/*", package:installdir("include"))
        os.cp("lib/x64/*", package:installdir("lib"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dxc -help")
        assert(package:has_cxxfuncs("DxcCreateInstance", {includes = {"windows.h", "dxcapi.h"}}))
    end)
