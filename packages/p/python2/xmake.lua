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
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz",
                 "https://github.com/xmake-mirror/cpython/releases/download/v$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl", {plat = os.host(), arch = os.arch()})
    end
 
    on_load(function (package)
        package:data_set("install_resources", function()

            -- imports
            import("net.http")
            import("utils.archive")
            import("lib.detect.find_file")

            -- set python environments
            local version = package:version()
            local envs = {PYTHONPATH = package:installdir("lib", "python" .. version:major() .. "." .. version:minor(), "site-packages")}
            package:addenv("PYTHONPATH", envs.PYTHONPATH)

            -- install resources
            local resources = 
            {
                setuptools = 
                {
                    url = "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip",
                    sha256 = "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d"
                },
                pip = 
                {
                    url = "https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz",
                    sha256 = "6e6f197a1abfb45118dbb878b5c859a0edbdd33fd250100bc015b67fded4b9f2"
                },
                wheel =
                {
                    url = "https://files.pythonhosted.org/packages/b7/cf/1ea0f5b3ce55cacde1e84cdde6cee1ebaff51bd9a3e6c7ba4082199af6f6/wheel-0.33.1.tar.gz",
                    sha256 = "66a8fd76f28977bb664b098372daef2b27f60dc4d1688cfab7b37a09448f0e9d"
                }
            }
            local python = path.join(package:installdir("bin"), "python" .. (is_host("windows") and ".exe" or ""))
            for name, resource in pairs(resources) do
                local resourcefile = path.join(os.curdir(), path.filename(resource.url))
                local resourcedir = resourcefile .. ".dir"
                http.download(resource.url, resourcefile)
                assert(resource.sha256 == hash.sha256(resourcefile), "resource(%s): unmatched checksum!", name)
                assert(archive.extract(resourcefile, resourcedir), "resource(%s): extract failed!", name)
                print(resourcedir)
                local setupfile = assert(find_file("setup.py", path.join(resourcedir, "*")), "resource(%s): setup.py not found!", name)
                local oldir = os.cd(path.directory(setupfile))
                os.vrunv(python, {"setup.py", "install", "--prefix=" .. package:installdir()}, {envs = envs})
                os.cd(oldir)
            end
        end)
    end)

    on_install("@windows", function (package)
        os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
        os.cp("*", package:installdir())
        package:data("install_resources")()
    end)

    on_install("@macosx", "@linux", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--without-ensurepip"}
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))

        -- add openssl libs path for detecting
        io.gsub("setup.py", "/usr/local/ssl", package:dep("openssl"):installdir())

        -- allow python modules to use ctypes.find_library to find xmake's stuff
        if is_host("macosx") then
            io.gsub("Lib/ctypes/macholib/dyld.py", "DEFAULT_LIBRARY_FALLBACK = %[", format("DEFAULT_LIBRARY_FALLBACK = [ '%s/lib',", package:installdir()))
        end

        -- unset these so that installing pip and setuptools puts them where we want
        -- and not into some other Python the user has installed.
        import("package.tools.autoconf").configure(package, configs, {envs = {PYTHONHOME = "", PYTHONPATH = ""}})
        os.vrunv("make", {"install", "-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        package:data("install_resources")()
    end)

    on_test(function (package)
        os.vrun("python2 --version")
        os.vrun("python2 -c \"import pip\"")
        os.vrun("python2 -c \"import setuptools\"")
        os.vrun("python2 -c \"import wheel\"")
    end)
