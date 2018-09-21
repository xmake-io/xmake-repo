package("python")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            set_urls("https://www.python.org/ftp/python/$(version)/python-$(version).amd64.msi")
            add_versions("2.7.15", "5e85f3c4c209de98480acbf2ba2e71a907fd5567a838ad4b6748c76deb286ad7")
        else
            set_urls("https://www.python.org/ftp/python/$(version)/python-$(version).msi")
            add_versions("2.7.15", "1afa1b10cf491c788baa340066a813d5ec6232561472cfc3af1664dbc6f29f77")
        end
    end

    on_build(function (package)
    end)

    on_install("windows", function (package)
        os.mkdir("targetdir")
        os.vrun("msiexec /a \"%s\" /quiet /qn TARGETDIR=\"%s\"", package:originfile(), path.absolute("targetdir"))
        os.cp("targetdir/*", package:installdir("bin"))
    end)

    on_install("macosx", "linux", function (package)
        import("package.manager").install("python")
    end)
