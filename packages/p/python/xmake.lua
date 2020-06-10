package("python")

    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win64.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win64.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win64.tar.gz")
            add_versions("2.7.15", "c81c4604b4176ff26be8d37cf48a2582e71a5e8f475b531c2e5d032a39511acb")
            add_versions("3.7.0", "8acd395e64d09b6b33ef78e199ffa48a8fd48f32d4d90d575e72448939a0e4c5")
        else
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win32.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win32.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win32.tar.gz")
            add_versions("2.7.15", "4a7be2b440b74776662daaeb6bb6c5574bb6d0f4ddc0ad03ce63571ab2353303")
            add_versions("3.7.0", "6f6dfd3df4b15157a12d06685a6dda450478ca118aa8832f0033093b9ca6329f")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz",
                 "https://github.com/xmake-mirror/cpython/releases/download/v$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
        add_versions("3.7.0", "85bb9feb6863e04fb1700b018d9d42d1caac178559ffa453d7e6a436e259fd0d")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl", {host = true})
    end

    if is_plat("linux") then
        add_syslinks("util", "pthread", "dl")
    end

    add_resources("3.7.0", "setuptools",  "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip", "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d")
    add_resources("3.7.0", "pip",         "https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz", "6e6f197a1abfb45118dbb878b5c859a0edbdd33fd250100bc015b67fded4b9f2")
    add_resources("3.7.0", "wheel",       "https://files.pythonhosted.org/packages/b7/cf/1ea0f5b3ce55cacde1e84cdde6cee1ebaff51bd9a3e6c7ba4082199af6f6/wheel-0.33.1.tar.gz", "66a8fd76f28977bb664b098372daef2b27f60dc4d1688cfab7b37a09448f0e9d")

    add_resources("2.7.15", "setuptools", "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip", "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d")
    add_resources("2.7.15", "pip",        "https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz", "6e6f197a1abfb45118dbb878b5c859a0edbdd33fd250100bc015b67fded4b9f2")
    add_resources("2.7.15", "wheel",      "https://files.pythonhosted.org/packages/b7/cf/1ea0f5b3ce55cacde1e84cdde6cee1ebaff51bd9a3e6c7ba4082199af6f6/wheel-0.33.1.tar.gz", "66a8fd76f28977bb664b098372daef2b27f60dc4d1688cfab7b37a09448f0e9d")

    on_load(function (package)
        
        -- add PATH
        package:addenv("PATH", "bin")

        -- set includedirs
        local version = package:version()
        if package:is_plat("windows") then
            package:add("includedirs", "include")
        elseif version:ge("3.0") then
            package:add("includedirs", ("include/python%d.%dm"):format(version:major(), version:minor()))
        else
            package:add("includedirs", ("include/python%d.%d"):format(version:major(), version:minor()))
        end

        -- define install_resources()
        package:data_set("install_resources", function()

            -- imports
            import("lib.detect.find_file")

            -- set python environments
            local envs = {}
            if is_host("windows") and version:ge("3.0") then
                envs.PYTHONPATH = package:installdir("Lib", "site-packages")
            else
                envs.PYTHONPATH = package:installdir("lib", "python" .. version:major() .. "." .. version:minor(), "site-packages")
            end
            package:addenv("PYTHONPATH", envs.PYTHONPATH)
     
            -- install resources
            local python = path.join(package:installdir("bin"), "python" .. (is_host("windows") and ".exe" or ""))
            for _, name in ipairs({"setuptools", "pip", "wheel"}) do
                local resourcedir = assert(package:resourcedir(name), "resource(%s): not found!", name)
                local setupfile = assert(find_file("setup.py", path.join(resourcedir, "*")), "resource(%s): setup.py not found!", name)
                local oldir = os.cd(path.directory(setupfile))
                os.vrunv(python, {"setup.py", "install", "--prefix=" .. package:installdir()}, {envs = envs})
                os.cd(oldir)
            end
        end)
    end)

    on_install("@windows", function (package)
        if package:version():ge("3.0") then
            os.cp("python.exe", path.join(package:installdir("bin"), "python3.exe"))
        else
            os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        end
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
        os.mv("libs/*", package:installdir("lib"))
        os.cp("*", package:installdir())
        package:data("install_resources")()
    end)

    on_install("@macosx", "@linux", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--without-ensurepip"}
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))

        -- add openssl libs path for detecting
        local openssl_dir = package:dep("openssl"):installdir()
        if package:version():ge("3.0") then
            table.insert(configs, "--with-openssl=" .. openssl_dir)
        else
            io.gsub("setup.py", "/usr/local/ssl", openssl_dir)
        end

        -- allow python modules to use ctypes.find_library to find xmake's stuff
        if is_host("macosx") then
            io.gsub("Lib/ctypes/macholib/dyld.py", "DEFAULT_LIBRARY_FALLBACK = %[", format("DEFAULT_LIBRARY_FALLBACK = [ '%s/lib',", package:installdir()))
        end

        -- add flags
        local cflags = {}
        local ldflags = {}
        if package:is_plat("macosx") then
            local xcode_dir     = get_config("xcode")
            local xcode_sdkver  = get_config("xcode_sdkver")
            if xcode_dir and xcode_sdkver then
                -- help Python's build system (setuptools/pip) to build things on SDK-based systems
                -- the setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
                local xcode_sdkdir = xcode_dir .. "/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX" .. xcode_sdkver .. ".sdk"
                table.insert(cflags, "-isysroot " .. xcode_sdkdir)
                table.insert(cflags, "-I" .. path.join(xcode_sdkdir, "/usr/include"))
                table.insert(ldflags, "-isysroot " .. xcode_sdkdir)

                -- for the Xlib.h, Python needs this header dir with the system Tk
                -- yep, this needs the absolute path where zlib needed a path relative to the SDK.
                table.insert(cflags, "-I" .. path.join(xcode_sdkdir, "/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"))
            end
    
            -- avoid linking to libgcc https://mail.python.org/pipermail/python-dev/2012-February/116205.html
            local target_minver = get_config("target_minver")
            if target_minver then
                table.insert(configs, "MACOSX_DEPLOYMENT_TARGET=" .. target_minver)
            end
        end
        if #cflags > 0 then
            table.insert(configs, "CFLAGS=" .. table.concat(cflags, " "))
        end
        if #ldflags > 0 then
            table.insert(configs, "LDFLAGS=" .. table.concat(ldflags, " "))
        end

        -- unset these so that installing pip and setuptools puts them where we want
        -- and not into some other Python the user has installed.
        import("package.tools.autoconf").configure(package, configs, {envs = {PYTHONHOME = "", PYTHONPATH = ""}})
        os.vrunv("make", {"install", "-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        if package:version():ge("3.0") then
            os.cp(path.join(package:installdir("bin"), "python3"), path.join(package:installdir("bin"), "python"))
            os.cp(path.join(package:installdir("bin"), "python3-config"), path.join(package:installdir("bin"), "python-config"))
        end

        -- install resources
        package:data("install_resources")()
    end)

    on_test(function (package)
        os.vrun("python --version")
        os.vrun("python -c \"import pip\"")
        os.vrun("python -c \"import setuptools\"")
        os.vrun("python -c \"import wheel\"")
        assert(package:has_cfuncs("PyModule_New", {includes = "Python.h"}))
    end)
