package("nsis")
    set_kind("binary")
    set_homepage("https://nsis.sourceforge.io/")
    set_description("NSIS (Nullsoft Scriptable Install System) is a professional open source system to create Windows installers.")

    add_urls("https://github.com/xmake-mirror/nsis/releases/download/$(version).zip", {version = function (version)
        return "v" .. (version:gsub("%.", "")) .. "/nsis-" .. version
    end})

    add_versions("3.09", "b6f9960f6956b40a05809f1edad5761d6ed7af1548806836bc2381689b11442a")

    add_resources("3.09", "uac", "https://github.com/xmake-mirror/nsis/releases/download/v309/UAC.zip", "20e3192af5598568887c16d88de59a52c2ce4a26e42c5fb8bee8105dcbbd1760")
    add_resources("3.09", "strlen_8192", "https://github.com/xmake-mirror/nsis/releases/download/v309/nsis-3.09-strlen_8192.zip", "9e3b8e77c97a46747201f95f89eba26714dd9c6dc06830c3934b3f5fbdb1beca")

    on_install("@windows|x64", "@windows|x86", function (package)
        os.cp("*", package:installdir())
        os.cp(path.join(package:resourcedir("strlen_8192"), "*"), package:installdir())
        os.cp(path.join(package:resourcedir("uac"), "UAC.nsh"), path.join(package:installdir(), "Include"))
        package:addenv("PATH", "Plugins/x86-unicode")
    end)

    on_test(function (package)
        os.runv("makensis", {"/CMDHELP"})
    end)
