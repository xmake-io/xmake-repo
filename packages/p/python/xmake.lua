package("python")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://www.python.org/ftp/python/$(version)/python-$(version).amd64.msi", {alias = "py2"})
            add_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-amd64.zip", {alias = "py3"})
            add_versions("py2:2.7.15", "5e85f3c4c209de98480acbf2ba2e71a907fd5567a838ad4b6748c76deb286ad7")
            add_versions("py3:3.7.0", "0cc08f3c74c0112abc2adafd16a534cde12fe7c7aafb42e936d59fd3ab08fcdb")
        else
            add_urls("https://www.python.org/ftp/python/$(version)/python-$(version).msi", {alias = "py2"})
            add_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-win32.zip", {alias = "py3"})
            add_versions("py2:2.7.15", "1afa1b10cf491c788baa340066a813d5ec6232561472cfc3af1664dbc6f29f77")
            add_versions("py3:3.7.0", "9596b23a8db1f945c2e26fe0dc1743e33f3700b4b708c68ea202cf2ac761a736")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
        add_versions("3.7.0", "85bb9feb6863e04fb1700b018d9d42d1caac178559ffa453d7e6a436e259fd0d")
    end

    on_install("windows", function (package)
        local installdir = package:installdir("share", package:name(), package:version_str())
        if package:version_str():startswith("2.") then
            os.mkdir("targetdir")
            os.vrun("msiexec /a \"%s\" /quiet /qn TARGETDIR=\"%s\"", package:originfile(), path.absolute("targetdir"))
            os.cp("targetdir/*", installdir)
            os.cp("targetdir/python.exe", path.join(installdir, "python2.exe"))
        else
            os.cp("*", installdir)
            os.cp("python.exe", path.join(installdir, "python3.exe"))
        end
        package:addenv("PATH", path.join("share", package:name(), package:version_str()))
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {prefix = package:installdir("share", package:name(), package:version_str())})
        package:addenv("PATH", path.join("share", package:name(), package:version_str(), "bin"))
    end)

