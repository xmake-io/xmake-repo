package("python")

    set_homepage("https://www.python.org/")
    set_description("The python programming language.")

    if is_host("windows") then
        if is_arch("x86", "i386") or os.arch() == "x86" then
            add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-$(version).win32.zip")
            add_versions("2.7.18", "95e21c87c9f38fa8068e014fc3683c3bc2c827f64875e620b9ecd3c75976a79c")
            add_versions("3.7.9", "55c8a408a11e598964f5d581589cf7f8c622e3cad048dce331ee5a61e5a6f57f")
            add_versions("3.8.10", "f520d2880578df076e3df53bf9e147b81b5328db02d8d873670a651fa076be50")
            add_versions("3.9.5", "ce0bfe8ced874d8d74a6cf6a98f13f5afee27cffbaf2d1ee0f09d3a027fab299")
            add_versions("3.9.6", "2918246384dfb233bd8f8c2bcf6aa3688e6834e84ab204f7c962147c468f8d12")
        else
            add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-$(version).win64.zip")
            add_versions("2.7.18", "6680835ed5b818e2c041c7033bea47ace17f6f3b73b0d6efb6ded8598a266754")
            add_versions("3.7.9", "d0d879c934b463d46161f933db53a676790d72f24e92143f629ee5629ae286bc")
            add_versions("3.8.10", "acf35048274404dd415e190bf5b928fae3b03d8bb5dfbfa504f9a183361468bd")
            add_versions("3.9.5", "3265059edac21bf4c46fac13553a5d78417e7aa209eceeffd0250aa1dd8d6fdf")
            add_versions("3.9.6", "57ccd1b1b5fbc62882bd2a6f47df6e830ba39af741acf0a1d2f161eef4e87f2e")
        end
    else
        set_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz",
                 "https://github.com/xmake-mirror/cpython/releases/download/v$(version)/Python-$(version).tgz")
        add_versions("2.7.18", "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814")
        add_versions("3.7.9", "39b018bc7d8a165e59aa827d9ae45c45901739b0bbb13721e4f973f3521c166a")
        add_versions("3.8.10", "b37ac74d2cbad2590e7cd0dd2b3826c29afe89a734090a87bf8c03c45066cb65")
        add_versions("3.9.5", "e0fbd5b6e1ee242524430dee3c91baf4cbbaba4a72dd1674b90fda87b713c7ab")
        add_versions("3.9.6", "d0a35182e19e416fc8eae25a3dcd4d02d4997333e4ad1f2eee6010aadc3fe866")
    end

    if not is_plat(os.host()) then
        set_kind("binary")
    end

    if is_host("macosx", "linux") then
        add_deps("openssl", {host = true})
    end

    if is_host("linux") then
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
        package:addenv("PATH", "Scripts")
    end)

    on_load("@macosx", "@linux", function (package)

        -- set includedirs
        local version = package:version()
        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        if version:ge("3.0") and version:le("3.8") then
            package:add("includedirs", path.join("include", pyver .. "m"))
        else
            package:add("includedirs", path.join("include", pyver))
        end

        -- set python environments
        local PYTHONPATH = package:installdir("lib", pyver, "site-packages")
        package:addenv("PYTHONPATH", PYTHONPATH)
        package:addenv("PATH", "bin")
        package:addenv("PATH", "Scripts")
    end)

    on_install("@windows", "@msys", "@cygwin", function (package)
        if package:version():ge("3.0") then
            os.cp("python.exe", path.join(package:installdir("bin"), "python3.exe"))
        else
            os.cp("python.exe", path.join(package:installdir("bin"), "python2.exe"))
        end
        os.cp("*.exe", package:installdir("bin"))
        os.cp("*.dll", package:installdir("bin"))
        os.cp("Lib", package:installdir())
        os.cp("libs/*", package:installdir("lib"))
        os.cp("*", package:installdir())
        local python = path.join(package:installdir("bin"), "python.exe")
        os.vrunv(python, {"-m", "pip", "install", "-U", "pip"})
        os.vrunv(python, {"-m", "pip", "install", "wheel"})
    end)

    on_install("@macosx", "@linux", function (package)

        -- init configs
        local configs = {"--enable-ipv6", "--with-ensurepip", "--enable-optimizations"}
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))

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
            if package:version():ge("3.0") then
                table.insert(configs, "--with-openssl=" .. openssl_dir)
            else
                io.gsub("setup.py", "/usr/local/ssl", openssl_dir)
            end
        end

        -- allow python modules to use ctypes.find_library to find xmake's stuff
        if package:is_plat("macosx") then
            io.gsub("Lib/ctypes/macholib/dyld.py", "DEFAULT_LIBRARY_FALLBACK = %[", format("DEFAULT_LIBRARY_FALLBACK = [ '%s/lib',", package:installdir()))
        end

        -- add flags for macOS
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

            -- TODO will be deprecated after xmake v2.5.1
            xcode_sdkver = xcode_sdkver or get_config("xcode_sdkver_macosx")
            if not xcode_dir or not xcode_sdkver then
                -- maybe on cross platform, we need find xcode envs manually
                local xcode = import("detect.sdks.find_xcode")(nil, {force = true, plat = package:plat(), arch = package:arch()})
                if xcode then
                    xcode_dir = xcode.sdkdir
                    xcode_sdkver = xcode.sdkver
                end
            end

            -- TODO will be deprecated after xmake v2.5.1
            target_minver = target_minver or get_config("target_minver_macosx")
            if not target_minver then
                local macos_ver = macos.version()
                if macos_ver then
                    target_minver = macos_ver:major() .. "." .. macos_ver:minor()
                end
            end

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
        import("package.tools.autoconf").configure(package, configs, {envs = {PYTHONHOME = "", PYTHONPATH = ""}})
        os.vrunv("make", {"install", "-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        if package:version():ge("3.0") then
            os.cp(path.join(package:installdir("bin"), "python3"), path.join(package:installdir("bin"), "python"))
            os.cp(path.join(package:installdir("bin"), "python3-config"), path.join(package:installdir("bin"), "python-config"))
        end

        -- install wheel
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
    end)
