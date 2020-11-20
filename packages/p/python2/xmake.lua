package("python2")

    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win64.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win64.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win64.tar.gz")
            add_versions("2.7.15", "c81c4604b4176ff26be8d37cf48a2582e71a5e8f475b531c2e5d032a39511acb")
            add_versions("2.7.18", "a51d27c9f64cd28415ea0a8fdcb2ffda113ce61267f5f05c9af7fd00e27c9376")
        else
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win32.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win32.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win32.tar.gz")
            add_versions("2.7.15", "4a7be2b440b74776662daaeb6bb6c5574bb6d0f4ddc0ad03ce63571ab2353303")
            add_versions("2.7.18", "e80770ae6a10e8bccb56b378cb75a1c28c2762926205923b2fd51ce266e4baad")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz",
                 "https://github.com/xmake-mirror/cpython/releases/download/v$(version)/Python-$(version).tgz")
        add_versions("2.7.15", "18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db")
        add_versions("2.7.18", "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814")
    end

    if not is_plat(os.host()) or not is_arch(os.arch()) then
        set_kind("binary")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl", {host = true})
    end

    if is_host("linux") then
        add_syslinks("util", "pthread", "dl")
    end

    add_resources("2.7.x", "setuptools", "https://files.pythonhosted.org/packages/b2/40/4e00501c204b457f10fe410da0c97537214b2265247bc9a5bc6edd55b9e4/setuptools-44.1.1.zip", "c67aa55db532a0dadc4d2e20ba9961cbd3ccc84d544e9029699822542b5a476b")
    add_resources("2.7.x", "pip",        "https://files.pythonhosted.org/packages/0b/f5/be8e741434a4bf4ce5dbc235aa28ed0666178ea8986ddc10d035023744e6/pip-20.2.4.tar.gz", "85c99a857ea0fb0aedf23833d9be5c40cf253fe24443f0829c7b472e23c364a1")
    add_resources("2.7.x", "wheel",      "https://files.pythonhosted.org/packages/59/b0/11710a598e1e148fb7cbf9220fd2a0b82c98e94efbdecb299cb25e7f0b39/wheel-0.33.6.tar.gz", "10c9da68765315ed98850f8e048347c3eb06dd81822dc2ab1d4fde9dc9702646")

    on_load(function (package)

        -- add PATH
        package:addenv("PATH", "bin")
        package:addenv("PATH", "Scripts")

        -- set includedirs
        local version = package:version()
        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        if package:is_plat("windows") then
            package:add("includedirs", "include")
        else
            package:add("includedirs", path.join("include", pyver))
        end

        -- set python environments
        local envs = {}
        envs.PYTHONPATH = package:installdir("lib", pyver, "site-packages")
        package:addenv("PYTHONPATH", envs.PYTHONPATH)

        -- define install_resources()
        package:data_set("install_resources", function()

            -- imports
            import("lib.detect.find_file")

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

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
        os.mv("libs/*", package:installdir("lib"))
        os.cp("*|libs", package:installdir())
        package:data("install_resources")()
    end)

    on_install("@macosx", "@linux", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--without-ensurepip"}
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))

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
        if package:kind() ~= "binary" then
            assert(package:has_cfuncs("PyModule_New", {includes = "Python.h"}))
        end
    end)
