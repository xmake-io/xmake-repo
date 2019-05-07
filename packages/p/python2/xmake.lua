package("python2")

    set_kind("binary")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).amd64.zip")
            add_versions("2.7.15", "b9d8157fe2ca58f84d29a814bedf1d304d2277ad02f0930acd22e2ce7367b77e")
        else
            add_urls("https://gitlab.com/xmake-mirror/python-releases/raw/master/python-$(version).win32.zip")
            add_versions("2.7.15", "f34e2555c4fde5d7d746e6a0bbfc9151435f3f5c3eaddfc046ec0993b7cc9660")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
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
        os.cp("python.exe", path.join(installdir, "python2.exe"))
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
        io.gsub("setup.py", "/usr/local/ssl", package:dep("openssl"):installdir())

        -- do install
        import("package.tools.autoconf").install(package, configs)
        os.setenv("PYTHONHOME", PYTHONHOME)
        os.setenv("PYTHONPATH", PYTHONPATH)
    end)

    on_test(function (package)
        os.vrun("python2 --version")
    end)
