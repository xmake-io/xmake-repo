package("directxshadercompiler")

    set_homepage("https://github.com/microsoft/DirectXShaderCompiler/")
    set_description("DirectX Shader Compiler")
    set_license("LLVM")

    local date = {["1.5.2010"] = "2020_10-22"}
    add_urls("https://github.com/microsoft/DirectXShaderCompiler/releases/download/v$(version).zip", {version = function (version) return version .. "/dxc_" .. date[version] end})
    add_versions("1.5.2010", "b691f63778f470ebeb94874426779b2f60685fc8711adf1b1f9f01535d9b67f8")

    set_kind("binary")

    on_install("@windows|x64", function (package)
        os.cp("bin/x64/**", package:installdir("bin"))
        os.cp("inc/**", package:installdir("include"))
        os.cp("lib", package:installdir())
    end)

    on_test(function (package)
        os.vrun("dxc -help")
    end)
