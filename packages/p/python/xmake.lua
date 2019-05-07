package("python")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).amd64.zip", {alias = "py2"})
            add_versions("py2:2.7.15", "b9d8157fe2ca58f84d29a814bedf1d304d2277ad02f0930acd22e2ce7367b77e")
        else
            add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).win32.zip", {alias = "py2"})
            add_versions("py2:2.7.15", "f34e2555c4fde5d7d746e6a0bbfc9151435f3f5c3eaddfc046ec0993b7cc9660")
        end
        if winos.version():gt("winxp") then
            if os.arch() == "x64" then
                add_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-amd64.zip", {alias = "py3"})
                add_versions("py3:3.7.0", "0cc08f3c74c0112abc2adafd16a534cde12fe7c7aafb42e936d59fd3ab08fcdb")
            else
                add_urls("https://www.python.org/ftp/python/$(version)/python-$(version)-embed-win32.zip", {alias = "py3"})
                add_versions("py3:3.7.0", "9596b23a8db1f945c2e26fe0dc1743e33f3700b4b708c68ea202cf2ac761a736")
            end
        else
            if os.arch() == "x64" then
                add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).amd64.zip", {alias = "py3"})
                add_versions("py3:3.3.4", "a83bf90b28f8b44b99c3524a34ab18f21a59999e07c107da19b031869fb42af1")
            else
                add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).win32.zip", {alias = "py3"})
                add_versions("py3:3.3.4", "c9843d585e30da1c7c85663543b2f6a1f68621e02d288abc5b5e54361d93ccd6")
            end
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
        add_versions("3.7.0", "85bb9feb6863e04fb1700b018d9d42d1caac178559ffa453d7e6a436e259fd0d")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl")
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
        os.cp("*", installdir)
        if package:version_str():startswith("2.") then
            os.cp("python.exe", path.join(installdir, "python2.exe"))
        else
            os.cp("python.exe", path.join(installdir, "python3.exe"))
        end
    end)

    on_install("macosx", "linux", function (package)
        -- unset these so that installing pip and setuptools puts them where we want
        -- and not into some other Python the user has installed.
        local PYTHONHOME = os.getenv("PYTHONHOME")
        local PYTHONPATH = os.getenv("PYTHONPATH")
        os.setenv("PYTHONHOME", "")
        os.setenv("PYTHONPATH", "")

        -- init configs
        local configs = {"--enable-ipv6", "--without-ensurepip"}
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))

        -- add openssl libs path for detecting
        local openssl_dir = package:dep("openssl"):installdir()
        if package:version_str():startswith("3") then
            table.insert(configs, "--with-openssl=" .. openssl_dir)
        else
            io.gsub("setup.py", "/usr/local/ssl", openssl_dir)
        end

        -- do install
        import("package.tools.autoconf").install(package, configs)

        os.setenv("PYTHONHOME", PYTHONHOME)
        os.setenv("PYTHONPATH", PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("python --version")
    end)
