package("sqlcipher")
    set_homepage("https://www.zetetic.net/sqlcipher/")
    set_description("SQLCipher is a standalone fork of the SQLite database library that adds 256 bit AES encryption of database files and other security features")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/sqlcipher/sqlcipher/archive/refs/tags/v$(version).tar.gz")
    add_versions("4.13.0", "7ca5c11f70e460d6537844185621d5b3d683a001e6bad223d15bdf8eff322efa")
    add_versions("4.12.0", "151a1c618c7ae175dfd0f862a8d52e8abd4c5808d548072290e8656032bb0f12")
    add_versions("4.6.0", "879fb030c36bc5138029af6aa3ae3f36c28c58e920af05ac7ca78a5915b2fa3c")
    add_versions("4.5.3", "5c9d672eba6be4d05a9a8170f70170e537ae735a09c3de444a8ad629b595d5e2")

    if not is_plat("windows") then
        -- only for GCC 15
        add_patches(">=4.12.0", path.join(os.scriptdir(), "patches", "4.12.0", "stdint.patch"), "608ea7c41855b26029f114ac5b0c9abf35656dec559b86939909813da6bb78ae")
    end

    add_configs("encrypt",  { description = "enable encrypt", default = true, type = "boolean"})
    add_configs("temp_store",  { description = "use an in-ram database for temporary tables", default = "2", values = {"0", "1", "2" , "3"}})
    add_configs("threadsafe",  { description = "sqltie thread safe mode", default = "1", values = {"0", "1", "2"}})

    if is_plat("iphoneos") then
        add_frameworks("Security")
    else
        add_deps("openssl3")
    end
    if is_host("linux", "macosx") then
        add_deps("tclsh")
    end

    if is_plat("macosx", "linux", "cross") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("android") then
        add_syslinks("dl", "m", "z")
    end

    if on_check then
        on_check("windows|arm64", function (package)
            raise("package(sqlcipher): does not support windows-arm64")
        end)
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "SQLITE_API=__declspec(dllimport)")
        end

        if package:config("encrypt") then
            package:add("defines", "SQLITE_HAS_CODEC=1")
        end
    end)

    on_install("windows", function (package)
        local openssl = package:dep("openssl3"):fetch()
        assert(openssl, "Failed fetch openssl3 library!")

        local rtcc_include = ""
        for _, dir in ipairs(openssl.sysincludedirs or openssl.includedirs) do
            rtcc_include = rtcc_include .. " -I" .. dir
        end

        local libpaths = ""
        for _, dir in ipairs(openssl.linkdirs) do
            libpaths = libpaths .. " /LIBPATH:" .. dir
        end

        local temp_store = " -DSQLITE_TEMP_STORE=" .. package:config("temp_store")
        local thread_safe = " -DSQLITE_THREADSAFE=" .. package:config("threadsafe")
        io.replace("Makefile.msc", "TCC = $(TCC) -DSQLITE_TEMP_STORE=1", "TCC = $(TCC) -DSQLITE_HAS_CODEC" .. rtcc_include .. temp_store, {plain = true})
        io.replace("Makefile.msc", "TCC = $(TCC) -DSQLITE_THREADSAFE=1", "TCC = $(TCC)" .. thread_safe, {plain = true})
        io.replace("Makefile.msc", "RCC = $(RCC) -DSQLITE_TEMP_STORE=1", "RCC = $(RCC) -DSQLITE_HAS_CODEC" .. rtcc_include .. temp_store, {plain = true})
        io.replace("Makefile.msc", "RCC = $(RCC) -DSQLITE_THREADSAFE=1", "RCC = $(RCC)" .. thread_safe, {plain = true})

        import("package.tools.nmake")
        local envs = nmake.buildenvs(package)
        envs.NO_TCL = 1
        envs.SESSION = 0
        envs.SQLITE3DLL = "sqlcipher.dll"
        envs.SQLITE3LIB = "sqlcipher.lib"
        envs.SQLITE3EXE = "sqlcipher.exe"
        envs.SQLITE3EXEPDB = "/pdb:sqlcipher.pdb"
        envs.LTLIBS = "advapi32.lib user32.lib ws2_32.lib crypt32.lib wsock32.lib libcrypto.lib libssl.lib"
        envs.LTLIBPATHS = libpaths
        envs.PLATFORM = package:arch()

        nmake.build(package, {"-f", "Makefile.msc"}, {envs = envs})
        os.cp("sqlcipher.dll", package:installdir("bin"))
        os.cp("sqlcipher.pdb", package:installdir("bin"))
        os.cp("sqlcipher.exe", package:installdir("bin"))
        os.cp("sqlcipher.lib", package:installdir("lib"))
        os.cp("sqlite3.h", package:installdir("include"))
        os.cp("sqlite3ext.h", package:installdir("include"))
    end)

    on_install("linux", "macosx", "iphoneos", "cross", function (package)
        local make_args = {}
        local packagedeps = {}
        if package:version():ge("4.7.0") then
            if package:config("temp_store") ~= "0" then
                table.insert(make_args, "--with-tempstore=yes")
            end
            if package:config("threadsafe") == "0" then
                table.insert(make_args, "--disable-threadsafe")
            end
            if package:config("encrypt") then
                if is_plat("iphoneos") then
                    table.insert(make_args, [[CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_EXTRA_INIT=sqlcipher_extra_init -DSQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown -DSQLCIPHER_CRYPTO_CC"]])
                else
                    table.insert(make_args, [[CFLAGS="-DSQLITE_HAS_CODEC -DSQLITE_EXTRA_INIT=sqlcipher_extra_init -DSQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown -DSQLCIPHER_CRYPTO_OPENSSL"]])
                    table.insert(packagedeps, "openssl3")
                end
            end
        else
            table.insert(make_args, "--with-crypto-lib=none")
        end
        os.vrunv("./configure", make_args)
        import("package.tools.make").build(package, {"sqlite3.c"}, {packagedeps = packagedeps})
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        configs.encrypt = package:config("encrypt")
        configs.threadsafe = threadsafe
        configs.temp_store = temp_store
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
    end)
