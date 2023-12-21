package("sqlcipher")

    set_homepage("https://www.zetetic.net/sqlcipher/")
    set_description("SQLCipher is a standalone fork of the SQLite database library that adds 256 bit AES encryption of database files and other security features")

    set_urls("https://github.com/sqlcipher/sqlcipher/archive/refs/tags/v$(version).tar.gz")
    add_versions("4.5.3", "5c9d672eba6be4d05a9a8170f70170e537ae735a09c3de444a8ad629b595d5e2")

    add_configs("encrypt",  { description = "enable encrypt", default = true, type = "boolean"})
    add_configs("temp_store",  { description = "use an in-ram database for temporary tables", default = "2", values = {"0", "1", "2" , "3"}})
    add_configs("threadsafe",  { description = "sqltie thread safe mode", default = "1", values = {"0", "1", "2"}})

    if is_plat("iphoneos") then
        add_frameworks("Security")
    else
        add_deps("openssl")
    end
    if is_host("linux", "macosx") then
        add_deps("tclsh")
    end

    if is_plat("macosx", "linux", "cross") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("android") then
        add_syslinks("dl", "m", "z")
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
        local openssl = package:dep("openssl"):fetch()
        assert(openssl, "Failed fetch openssl library!")

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

    on_install("linux", "macosx", "android", "iphoneos", "cross", function (package)
        os.vrunv("./configure", {"--with-crypto-lib=none"})
        import("package.tools.make").build(package, {"sqlite3.c"})
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
