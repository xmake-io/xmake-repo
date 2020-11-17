package("python")

    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" or os.arch() == "x86_64" then
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win64.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win64.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win64.tar.gz")
            add_versions("2.7.15", "c81c4604b4176ff26be8d37cf48a2582e71a5e8f475b531c2e5d032a39511acb")
            add_versions("2.7.18", "a51d27c9f64cd28415ea0a8fdcb2ffda113ce61267f5f05c9af7fd00e27c9376")
            add_versions("3.7.0", "8acd395e64d09b6b33ef78e199ffa48a8fd48f32d4d90d575e72448939a0e4c5")
            add_versions("3.8.6", "87a3f900dc9cf3a72056198c764704355f2d624120f9cb3f2592c13874a9a479")
        else
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win32.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win32.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win32.tar.gz")
            add_versions("2.7.15", "4a7be2b440b74776662daaeb6bb6c5574bb6d0f4ddc0ad03ce63571ab2353303")
            add_versions("2.7.18", "e80770ae6a10e8bccb56b378cb75a1c28c2762926205923b2fd51ce266e4baad")
            add_versions("3.7.0", "6f6dfd3df4b15157a12d06685a6dda450478ca118aa8832f0033093b9ca6329f")
            add_versions("3.8.6", "999d1810c4f3e1dfc31dd50a3064fd973e041fc5aa2d3832516dd556b43e039c")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz",
                 "https://github.com/xmake-mirror/cpython/releases/download/v$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
        add_versions("2.7.18", "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814")
        add_versions("3.7.0", "85bb9feb6863e04fb1700b018d9d42d1caac178559ffa453d7e6a436e259fd0d")
        add_versions("3.8.6", "313562ee9986dc369cd678011bdfd9800ef62fbf7b1496228a18f86b36428c21")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl", {host = true})
    end

    if is_host("linux") then
        add_syslinks("util", "pthread", "dl")
    end

    -- mangle with cross compilation
    if not is_plat(os.host()) then
        set_kind("binary")
    end

    on_load("@windows", "@msys", "@cygwin", function (package)
        package:addenv("PATH", "bin")

        -- set includedirs
        package:add("includedirs", "include")

        -- set python environments
        local envs = {}
        envs.PYTHONPATH = package:installdir("Lib", "site-packages")
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_load("@macosx", "@linux", function (package)
        package:addenv("PATH", "bin")

        -- set includedirs
        local version = package:version()
        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        package:add("includedirs", path.join("include", pyver))

        -- set python environments
        local envs = {}
        envs.PYTHONPATH = package:installdir("lib", pyver, "site-packages")
        package:addenv("PYTHONPATH", envs.PYTHONPATH)
    end)

    on_install("@windows", "@msys", "@cygwin", function (package)
        if package:version():ge("3.0") then
            os.cp("python.exe", path.join(package:installdir("bin"), "python3.exe"))
        else
            os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        end
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
        os.mv("Lib", package:installdir())
        os.mv("libs/*", package:installdir("lib"))
        os.cp("**|libs", package:installdir())
        local python = path.join(package:installdir("bin"), "python.exe")
        os.vrunv(python, {"-m", "pip", "install", "wheel"})
    end)

    on_install("@macosx", "@linux", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--with-ensurepip"}
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
            local xcode_sdkver  = get_config("xcode_sdkver") or get_config("xcode_sdkver_macosx")
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
            local target_minver = get_config("target_minver") or get_config("target_minver_macosx")
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

        local python = path.join(package:installdir("bin"), "python")
        os.vrunv(python, {"-m", "pip", "install", "wheel"})
    end)

    on_test(function (package)
        os.vrun("python --version")
        os.vrun("python -c \"import pip\"")
        os.vrun("python -c \"import setuptools\"")
        os.vrun("python -c \"import wheel\"")
        if package:kind() ~= "binary" then
            assert(package:has_cfuncs("PyModule_New", {includes = "Python.h"}))
        end
        if is_host("windows") then
            os.vrun("py -3 -c \"import sys\"")
        end
    end)
