package("python3")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            set_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-amd64.zip")
            add_versions("3.7.0", "0cc08f3c74c0112abc2adafd16a534cde12fe7c7aafb42e936d59fd3ab08fcdb")
        else
            set_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-win32.zip")
            add_versions("3.7.0", "9596b23a8db1f945c2e26fe0dc1743e33f3700b4b708c68ea202cf2ac761a736")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("3.7.0", "85bb9feb6863e04fb1700b018d9d42d1caac178559ffa453d7e6a436e259fd0d")
    end

    on_build(function (package)
    end)

    on_install("windows", function (package)
        os.mv("python.exe", path.join(package:installdir("bin"), "python3.exe"))
        os.cp("*", package:installdir("bin"))
    end)

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s", package:installdir())
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make altinstall")
    end)
