package("innosetup")
    set_kind("binary")
    set_homepage("https://jrsoftware.org/isinfo.php")
    set_description("Inno Setup is an open-source installation builder for Windows applications by Jordan Russell and Martijn Laan.")
    set_license("Inno Setup License")

    set_urls("https://www.nuget.org/api/v2/package/Tools.InnoSetup/$(version)/#Tools.InnoSetup-$(version).zip")

    add_versions("7.1.0", "aad15c662593c6f5656457a5c001f4591babd72820cacf63f9706d4af5d93b75")

    on_fetch(function (package, opt)
        return false
    end)

    on_install("windows", function (package)
        import("lib.detect.find_file")
        local tools_dir = path.directory(find_file("ISCC.exe", "tools"))
        os.cp(path.join(tools_dir, "/*"), package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrunv("ISCC", {"--version"})
    end)
