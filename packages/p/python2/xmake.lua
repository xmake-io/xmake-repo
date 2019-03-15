package("python2")

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
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
    end

    on_load(function (package)
        if is_host("windows") then
            package:addenv("PATH", path.join("share", package:name(), package:version_str()))
        else
            package:addenv("PATH", path.join("share", package:name(), package:version_str(), "bin"))
        end
    end)

    on_install("windows", function (package)
        local installdir = package:installdir("share", package:name(), package:version_str())
        os.mkdir("targetdir")
        os.vrun("msiexec /a \"%s\" /quiet /qn TARGETDIR=\"%s\"", package:originfile(), path.absolute("targetdir"))
        os.cp("targetdir/*", installdir)
        os.cp("targetdir/python.exe", path.join(installdir, "python2.exe"))
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

