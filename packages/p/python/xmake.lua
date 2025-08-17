package("python")
    set_homepage("https://www.python.org/")
    set_description("The python programming language.")
    set_license("PSF")

    if is_host("windows") then
        if is_arch("x86", "i386") or os.arch() == "x86" then
            add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-$(version).win32.zip")
            add_versions("2.7.18", "95e21c87c9f38fa8068e014fc3683c3bc2c827f64875e620b9ecd3c75976a79c")
            add_versions("3.7.9", "55c8a408a11e598964f5d581589cf7f8c622e3cad048dce331ee5a61e5a6f57f")
            add_versions("3.8.10", "f520d2880578df076e3df53bf9e147b81b5328db02d8d873670a651fa076be50")
            add_versions("3.9.5", "ce0bfe8ced874d8d74a6cf6a98f13f5afee27cffbaf2d1ee0f09d3a027fab299")
            add_versions("3.9.6", "2918246384dfb233bd8f8c2bcf6aa3688e6834e84ab204f7c962147c468f8d12")
            add_versions("3.9.10", "e2c8e6b792748289ac27ef8462478022c96e24c99c4c3eb97d3afe510d9db646")
            add_versions("3.9.13", "c60ec0da0adf3a31623073d4fa085da62747085a9f23f4348fe43dfe94ea447b")
            add_versions("3.10.6", "c1a07f7685b5499f58cfad2bb32b394b853ba12b8062e0f7530f2352b0942096")
            add_versions("3.10.11", "7fac6ed9a58623f31610024d2c4d6abb33fac0cf741ec1a5285d056b5933012e")
            add_versions("3.11.3", "992648876ecca6cfbe122dc2d9c358c9029d9fdb83ee6edd6e54926bf0360da6")
            add_versions("3.11.8", "f5e399d12b00a4f73dc3078b7b4fe900e1de6821aa3e31d1c27c6ef4e33e95d9")
            add_versions("3.12.3", "49bbcd200cda1f56452feeaf0954045e85b27a93b929034cc03ab198c4d9662e")
            add_versions("3.12.8", "b4ec65bf24417c4098c8d1f30a30fec12680aedd7094de3caf35e5e2d55d9c46")
            add_versions("3.12.10", "c23a8efcecadbe19fead675c621af54dc8fa086f1526b568718343f06b6dc1d2")
            add_versions("3.13.1", "f89b297ca94ced2fbdad7919518ebf05005f39637f8ec5b01e42f2c71d53a673")
            add_versions("3.13.2", "67ccaa5e8fb05e8e15a46f9262368fcfef190b1cfab3e2511acada7d68cf6464")
        elseif is_arch("x64", "x86_64") or os.arch() == "x64" then
            add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-$(version).win64.zip")
            add_versions("2.7.18", "6680835ed5b818e2c041c7033bea47ace17f6f3b73b0d6efb6ded8598a266754")
            add_versions("3.7.9", "d0d879c934b463d46161f933db53a676790d72f24e92143f629ee5629ae286bc")
            add_versions("3.8.10", "acf35048274404dd415e190bf5b928fae3b03d8bb5dfbfa504f9a183361468bd")
            add_versions("3.9.5", "3265059edac21bf4c46fac13553a5d78417e7aa209eceeffd0250aa1dd8d6fdf")
            add_versions("3.9.6", "57ccd1b1b5fbc62882bd2a6f47df6e830ba39af741acf0a1d2f161eef4e87f2e")
            add_versions("3.9.10", "4cee67e2a529fe363e34f0da57f8e5c3fc036913dc838b17389b2319ead0927e")
            add_versions("3.9.13", "6774fdd872fc55b028becc81b7d79bdcb96c5e0eb1483cfcd38224b921c94d7d")
            add_versions("3.10.6", "8cbc234939a679687da44c3bbc6d6ce375ea4b84c4fa8dbc1bf5befc43254b58")
            add_versions("3.10.11", "96663f508643c1efec639733118d4a8382c5c895b82ad1362caead17b643260e")
            add_versions("3.11.3", "708c4e666989b3b00057eaea553a42b23f692c4496337a91d17aced931280dc4")
            add_versions("3.11.8", "2be5fdc87a96659b75f2acd9f4c4a7709fcfccb7a81cd0bd11e9c0e08380e55c")
            add_versions("3.12.3", "00a80ccce8738de45ebe73c6084b1ea92ad131ec79cbe5c033a925c761cb5fdc")
            add_versions("3.12.8", "7f8cf0a21a076d2646b26c5248ae47f1dbc870bc059670915e042f6eb1850ecb")
            add_versions("3.12.10", "c6218cb107638583bd51f617cd7400e903e3c0c7fbe3f5b3c3d87efeb4738fbf")
            add_versions("3.13.1", "104d1de9eb6ff7c345c3415a57880dc0b2c51695515f2a87097512e6d77e977d")
            add_versions("3.13.2", "baee66e4d1b16a220bf61d64a210676f6d6fef69c65959ffd9828264c7fe8ef5")
        elseif is_arch("arm64.*", "aarch64") or os.arch() == "arm64" then
            add_urls("https://github.com/xmake-mirror/python-windows/releases/download/$(version)/python-$(version).winarm64.zip")
            add_versions("3.12.10", "ca559e226e5bb99ccad687817c191ddf4d972ac3f582f26e88c80f94884ff29f")
            add_versions("3.13.2", "f121c4a9a1118d297814155c93e75ef376f3d0bbccbd5cf38598d6e833b0e858")
        end
        set_policy("package.precompiled", false)
    else
        add_urls("https://www.python.org/ftp/python/$(version)/Python-$(version).tgz")
        add_versions("2.7.18", "da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814")
        add_versions("3.7.9", "39b018bc7d8a165e59aa827d9ae45c45901739b0bbb13721e4f973f3521c166a")
        add_versions("3.8.10", "b37ac74d2cbad2590e7cd0dd2b3826c29afe89a734090a87bf8c03c45066cb65")
        add_versions("3.9.5", "e0fbd5b6e1ee242524430dee3c91baf4cbbaba4a72dd1674b90fda87b713c7ab")
        add_versions("3.9.6", "d0a35182e19e416fc8eae25a3dcd4d02d4997333e4ad1f2eee6010aadc3fe866")
        add_versions("3.9.10", "1aa9c0702edbae8f6a2c95f70a49da8420aaa76b7889d3419c186bfc8c0e571e")
        add_versions("3.9.13", "829b0d26072a44689a6b0810f5b4a3933ee2a0b8a4bfc99d7c5893ffd4f97c44")
        add_versions("3.10.6", "848cb06a5caa85da5c45bd7a9221bb821e33fc2bdcba088c127c58fad44e6343")
        add_versions("3.10.11", "f3db31b668efa983508bd67b5712898aa4247899a346f2eb745734699ccd3859")
        add_versions("3.11.3", "1a79f3df32265d9e6625f1a0b31c28eb1594df911403d11f3320ee1da1b3e048")
        add_versions("3.11.8", "d3019a613b9e8761d260d9ebe3bd4df63976de30464e5c0189566e1ae3f61889")
        add_versions("3.11.9", "e7de3240a8bc2b1e1ba5c81bf943f06861ff494b69fda990ce2722a504c6153d")
        add_versions("3.12.3", "a6b9459f45a6ebbbc1af44f5762623fa355a0c87208ed417628b379d762dddb0")
        add_versions("3.12.8", "5978435c479a376648cb02854df3b892ace9ed7d32b1fead652712bee9d03a45")
        add_versions("3.12.10", "15d9c623abfd2165fe816ea1fb385d6ed8cf3c664661ab357f1782e3036a6dac")
        add_versions("3.13.0", "12445c7b3db3126c41190bfdc1c8239c39c719404e844babbd015a1bc3fafcd4")
        add_versions("3.13.1", "1513925a9f255ef0793dbf2f78bb4533c9f184bdd0ad19763fd7f47a400a7c55")
        add_versions("3.13.2", "b8d79530e3b7c96a5cb2d40d431ddb512af4a563e863728d8713039aa50203f9")
    end

    add_configs("headeronly", {description = "Use header only version.", default = false, type = "boolean"})

    if not is_plat(os.host()) or not is_arch(os.arch()) then
        set_kind("binary")
    end

    if is_host("linux", "bsd") then
        add_deps("libffi", "zlib", {host = true, private = true})
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

    on_load("@macosx", "@linux", "@bsd", function (package)
        local version = package:version()

        -- set openssl dep
        if version:ge("3.10") then
            -- starting with Python 3.10, Python requires OpenSSL 1.1.1 or newer
            -- see https://peps.python.org/pep-0644/
            package:add("deps", "openssl >=1.1.1-a", "ca-certificates", {host = true, private = package:config("headeronly")})
        else
            package:add("deps", "openssl", "ca-certificates", {host = true, private = package:config("headeronly")})
        end

        -- set includedirs
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

        if package:config("headeronly") then
            package:set("links", "")
        end
    end)

    on_fetch("fetch")

    on_install("@windows|x86", "@windows|x64", "@windows|arm64*", "@msys", "@cygwin", function (package)
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
        os.vrunv(python, {"-m", "pip", "install", "--upgrade", "--force-reinstall", "pip"})
        os.vrunv(python, {"-m", "pip", "install", "--upgrade", "setuptools"})
        os.vrunv(python, {"-m", "pip", "install", "wheel"})
    end)

    on_install("@macosx", "@bsd", "@linux", function (package)
        local version = package:version()

        -- init configs
        local configs = {"--enable-ipv6", "--with-ensurepip", "--enable-optimizations"}
        table.insert(configs, "--libdir=" .. package:installdir("lib"))
        table.insert(configs, "--with-platlibdir=lib")
        table.insert(configs, "--datadir=" .. package:installdir("share"))
        table.insert(configs, "--datarootdir=" .. package:installdir("share"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))

        -- add openssl libs path
        local openssl = package:dep("openssl"):fetch()
        if openssl then
            local openssl_dir
            for _, linkdir in ipairs(openssl.linkdirs) do
                if path.filename(linkdir) == "lib" then
                    openssl_dir = path.directory(linkdir)
                else
                    -- try to find if linkdir is root (brew has linkdir as root and includedirs inside)
                    for _, includedir in ipairs(openssl.sysincludedirs or openssl.includedirs) do
                        if includedir:startswith(linkdir) then
                            openssl_dir = linkdir
                            break
                        end
                    end
                end
                if openssl_dir then
                    if version:ge("3.0") then
                        table.insert(configs, "--with-openssl=" .. openssl_dir)
                    else
                        io.gsub("setup.py", "/usr/local/ssl", openssl_dir)
                    end
                    break
                end
            end
        end

        -- allow python modules to use ctypes.find_library to find xmake's stuff
        if package:is_plat("macosx") then
            io.gsub("Lib/ctypes/macholib/dyld.py", "DEFAULT_LIBRARY_FALLBACK = %[", format("DEFAULT_LIBRARY_FALLBACK = [ '%s/lib',", package:installdir()))
        end

        -- add flags for macOS
        local cppflags = {}
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
                table.insert(cppflags, "-isysroot " .. xcode_sdkdir)
                table.insert(cppflags, "-I" .. path.join(xcode_sdkdir, "/usr/include"))
                table.insert(ldflags, "-isysroot " .. xcode_sdkdir)

                -- for the Xlib.h, Python needs this header dir with the system Tk
                -- yep, this needs the absolute path where zlib needed a path relative to the SDK.
                table.insert(cppflags, "-I" .. path.join(xcode_sdkdir, "/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"))
            end

            -- avoid linking to libgcc https://mail.python.org/pipermail/python-dev/2012-February/116205.html
            if target_minver then
                table.insert(configs, "MACOSX_DEPLOYMENT_TARGET=" .. target_minver)
            end
        end

        -- add pic
        if package:is_plat("linux", "bsd") and package:config("pic") ~= false then
            table.insert(cppflags, "-fPIC")
        end

        -- add external path for zlib and libffi
        for _, libname in ipairs({"zlib", "libffi"}) do
            local lib = package:dep(libname)
            if lib and not lib:is_system() then
                local fetchinfo = lib:fetch({external = false})
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(cppflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(ldflags, "-L" .. linkdir)
                    end
                end
            end
        end
        if #cppflags > 0 then
            table.insert(configs, "CPPFLAGS=" .. table.concat(cppflags, " "))
        end
        if #ldflags > 0 then
            table.insert(configs, "LDFLAGS=" .. table.concat(ldflags, " "))
        end

        local pyver = ("python%d.%d"):format(version:major(), version:minor())
        -- https://github.com/python/cpython/issues/109796
        if version:ge("3.12.0") then
            os.mkdir(package:installdir("lib", pyver))
        end

        -- fix ssl module detect, e.g. gcc conftest.c -ldl   -lcrypto >&5
        if package:is_plat("linux") then
            io.replace("./configure", "-lssl -lcrypto", "-lssl -lcrypto -ldl", {plain = true})
        end

        -- unset these so that installing pip and setuptools puts them where we want
        -- and not into some other Python the user has installed.
        import("package.tools.autoconf").configure(package, configs, {envs = {PYTHONHOME = "", PYTHONPATH = ""}})
        os.vrunv("make", {"-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        os.vrunv("make", {"install", "-j4", "PYTHONAPPSDIR=" .. package:installdir()})
        if version:ge("3.0") then
            os.cp(path.join(package:installdir("bin"), "python3"), path.join(package:installdir("bin"), "python"))
            os.cp(path.join(package:installdir("bin"), "python3-config"), path.join(package:installdir("bin"), "python-config"))
        end

        -- install wheel
        local python = path.join(package:installdir("bin"), "python")
        local envs = {
            PATH = package:installdir("bin"),
            PYTHONPATH = package:installdir("lib", pyver, "site-packages"),
            LD_LIBRARY_PATH = package:installdir("lib")
        }
        os.vrunv(python, {"-m", "pip", "install", "--upgrade", "--force-reinstall", "pip"}, {envs = envs})
        os.vrunv(python, {"-m", "pip", "install", "--upgrade", "setuptools"}, {envs = envs})
        os.vrunv(python, {"-m", "pip", "install", "wheel"}, {envs = envs})
    end)

    on_test(function (package)
        os.vrun("python --version")
        os.vrun("python -c \"import pip\"")
        os.vrun("python -c \"import setuptools\"")
        os.vrun("python -c \"import wheel\"")
        if package:kind() ~= "binary" and not package:config("headeronly") then
            assert(package:has_cfuncs("PyModule_New", {includes = "Python.h"}))
        end
    end)
