package("python2")

    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if is_arch("x86", "i386") or os.arch() == "x86" then
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win32.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win32.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win32.tar.gz")
            add_versions("2.7.15", "4a7be2b440b74776662daaeb6bb6c5574bb6d0f4ddc0ad03ce63571ab2353303")
            add_versions("2.7.18", "9efaf273aa2e7d23fa22efa2936619ec91cf9ee189f707e375f9063fadeabcd6")
        else
            add_urls("https://cdn.jsdelivr.net/gh/xmake-mirror/python-releases@$(version)/python-$(version).win64.tar.gz",
                     "https://github.com/xmake-mirror/python-releases/raw/$(version)/python-$(version).win64.tar.gz",
                     "https://gitlab.com/xmake-mirror/python-releases/-/raw/$(version)/python-$(version).win64.tar.gz")
            add_versions("2.7.15", "c81c4604b4176ff26be8d37cf48a2582e71a5e8f475b531c2e5d032a39511acb")
            add_versions("2.7.18", "0e1adec089c4358b4ff1cd392c8bd7c975e0bf7c279aee91e7aaa04c00fb2c10")
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

    if is_host("macosx", "linux", "bsd") then
        add_deps("openssl", "ca-certificates", {host = true})
    end

    if is_host("linux", "bsd") then
        add_deps("libffi", "zlib", {host = true})
        add_syslinks("util", "pthread", "dl")
    end

    on_load("@windows", "@msys", "@cygwin", function (package)

        -- set includedirs
        package:add("includedirs", "include")

        -- set python environments
        local PYTHONPATH = package:installdir("Lib", "site-packages")
        package:addenv("PYTHONPATH", PYTHONPATH)
        package:addenv("PATH", "bin")
    end)

    on_load("@macosx", "@linux", "@bsd", function (package)

        -- set includedirs
        local version = package:version()
        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        package:add("includedirs", path.join("include", pyver))

        -- set python environments
        local PYTHONPATH = package:installdir("lib", pyver, "site-packages")
        package:addenv("PYTHONPATH", PYTHONPATH)
        package:addenv("PATH", "bin")
    end)

    on_install("@windows", "@msys", "@cygwin", function (package)
        os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        os.mv("*.exe", package:installdir("bin"))
        os.mv("*.dll", package:installdir("bin"))
        os.mv("Lib", package:installdir())
        os.mv("libs/*", package:installdir("lib"))
        os.cp("*|libs", package:installdir())
        local python = path.join(package:installdir("bin"), "python.exe")
        os.vrunv(python, {"-m", "pip", "install", "wheel"})
    end)

    on_install("@macosx|x86_64", "@linux", "@bsd", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--with-ensurepip", "--enable-optimizations"}
        table.insert(configs, "--libdir=" .. package:installdir("lib"))
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        -- add compiler settings
        if package:has_tool("cxx", "gcc", "g++") then
            table.insert(configs, "CXX=g++")
        elseif package:has_tool("cxx", "clang", "clang++") then
            table.insert(configs, "CXX=clang++")
        end

        -- add openssl libs path for detecting
        local openssl_dir
        local openssl = package:dep("openssl"):fetch()
        if openssl then
            for _, linkdir in ipairs(openssl.linkdirs) do
                if path.filename(linkdir) == "lib" then
                    openssl_dir = path.directory(linkdir)
                    if openssl_dir then
                        break
                    end
                end
            end
        end
        if openssl_dir then
            io.gsub("setup.py", "/usr/local/ssl", openssl_dir)
        end

        -- allow python modules to use ctypes.find_library to find xmake's stuff
        if package:is_plat("macosx") then
            io.gsub("Lib/ctypes/macholib/dyld.py", "DEFAULT_LIBRARY_FALLBACK = %[", format("DEFAULT_LIBRARY_FALLBACK = [ '%s/lib',", package:installdir()))
        end

        -- add flags
        local cflags = {}
        local ldflags = {}
        if package:is_plat("macosx") then

            -- get xcode information
            import("core.tool.toolchain")
            local xcode_dir
            local xcode_sdkver
            local target_minver
            local xcode = toolchain.load("xcode", {plat = package:plat(), arch = package:arch()})
            if xcode and xcode.config and xcode:check() then
                xcode_dir = xcode:config("xcode")
                xcode_sdkver = xcode:config("xcode_sdkver")
                target_minver = xcode:config("target_minver")
            end
            xcode_dir = xcode_dir or get_config("xcode")
            xcode_sdkver = xcode_sdkver or get_config("xcode_sdkver")
            target_minver = target_minver or get_config("target_minver")

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

        -- add zlib to fix `No module named 'zlib'`
        local linkdirs = {}
        local includedirs = {}
        if package:is_plat("linux") then
            local zlib = package:dep("zlib"):fetch({external = false})
            if zlib then
                table.join2(linkdirs, zlib.linkdirs)
                table.join2(includedirs, zlib.includedirs)
            end
            -- add libffi to fix `No module named '_ctypes'`
            local libffi = package:dep("libffi"):fetch({external = false})
            if libffi then
                table.join2(linkdirs, libffi.linkdirs)
                table.join2(includedirs, libffi.includedirs)
            end
        end
        if #linkdirs > 0 and #includedirs > 0 then
            io.replace("setup.py", "    def detect_modules(self):", format([[    def detect_modules(self):
        linkdirs = ['%s']
        includedirs = ['%s']
        for includedir in includedirs:
            add_dir_to_list(self.compiler.include_dirs, includedir)
        for linkdir in linkdirs:
            add_dir_to_list(self.compiler.library_dirs, linkdir)
]], table.concat(linkdirs, "', '"), table.concat(includedirs, "', '")), {plain = true})
        end

        -- unset these so that installing pip and setuptools puts them where we want
        -- and not into some other Python the user has installed.
        import("package.tools.autoconf").configure(package, configs, {envs = {PYTHONHOME = "", PYTHONPATH = "", LD_LIBRARY_PATH = package:installdir("lib")}})
        os.vrunv("make", {"-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        os.vrunv("make", {"install", "-j4", "PYTHONAPPSDIR=" .. package:installdir()})

        -- install wheel
        local python = path.join(package:installdir("bin"), "python")
        os.vrunv(python, {"-m", "pip", "install", "wheel"}, {envs = {LD_LIBRARY_PATH = package:installdir("lib")}})
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
