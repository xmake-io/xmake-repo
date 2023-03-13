package("sqlcipher")

    set_homepage("https://www.zetetic.net/sqlcipher/")
    set_description("SQLCipher is a standalone fork of the SQLite database library that adds 256 bit AES encryption of database files and other security features")
    
    set_urls("https://github.com/sqlcipher/sqlcipher/archive/refs/tags/v$(version).tar.gz")
    add_versions("4.5.3", "5c9d672eba6be4d05a9a8170f70170e537ae735a09c3de444a8ad629b595d5e2")

    add_configs("encrypt",  { description = "enable encrypt", default = true, type = "boolean"})

    -- 0: force temporary tables to be in a file, 
    -- 1: default to file
    -- 2: default to memory, 
    -- 3: default to always in memory
    add_configs("SQLITE_TEMP_STORE",  { description = "use an in-ram database for temporary tables", default = "2", values = {"0", "1", "2" , "3"}})
    
    add_configs("SQLITE_THREADSAFE",  { description = "SQLITE_TRHEADSAFE", default = "1", values = {"0", "1", "2"}})
    
    if is_plat("iphoneos") then
        add_frameworks("Security")
    else
        add_deps("openssl")
    end

    if is_plat("macosx", "linux", "cross") then
        add_syslinks("pthread", "dl", "m")
    end

    if is_plat("android") then
        add_syslinks("dl", "m", "z")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:get("kind") == "shared" then
            package:add("defines", "SQLITE_API=__declspec(dllimport)")
        end

        if package:config("encrypt") then
            package:add("defines", "SQLITE_HAS_CODEC=1")
        end

        if package:is_plat("iphoneos") then
            package:add("frameworks", "Security")
            package:add("defines", "SQLCIPHER_CRYPTO_CC")
            package:add("defines", "SQLITE_TEMP_STORE=" .. package:config("SQLITE_TEMP_STORE"))
        end
    end)

    on_install("windows", function (package)
        os.setenv("NO_TCL", 1)
        os.setenv("SESSION", 0)
        os.setenv("SQLITE3DLL", "sqlcipher.dll")
        os.setenv("SQLITE3LIB", "sqlcipher.lib")
        os.setenv("SQLITE3EXE", "sqlcipher.exe")
        os.setenv("SQLITE3EXEPDB", "/pdb:sqlcipher.pdb")

        local p = package:dep("openssl")
        local rtcc_include = " -I" .. p:installdir("include")
        local temp_store = " -DSQLITE_TEMP_STORE=" .. package:config("SQLITE_TEMP_STORE")
        local thread_safe = " -DSQLITE_THREADSAFE=" .. package:config("SQLITE_THREADSAFE")
        io.replace("Makefile.msc", "TCC = $(TCC) -DSQLITE_TEMP_STORE=1", "TCC = $(TCC) -DSQLITE_HAS_CODEC" .. rtcc_include .. temp_store, {plain = true})
        io.replace("Makefile.msc", "TCC = $(TCC) -DSQLITE_THREADSAFE=1", "TCC = $(TCC)" .. thread_safe, {plain = true})
        io.replace("Makefile.msc", "RCC = $(RCC) -DSQLITE_TEMP_STORE=1", "RCC = $(RCC) -DSQLITE_HAS_CODEC" .. rtcc_include .. temp_store, {plain = true})
        io.replace("Makefile.msc", "RCC = $(RCC) -DSQLITE_THREADSAFE=1", "RCC = $(RCC)" .. thread_safe, {plain = true})

        os.setenv("LTLIBS ", "advapi32.lib user32.lib ws2_32.lib crypt32.lib wsock32.lib libcrypto.lib libssl.lib")
        os.setenv("LTLIBPATHS", "/LIBPATH:" .. p:installdir("lib"))

        os.setenv("PLATFORM", package:arch())
        local configs = {"-f", "Makefile.msc"}
        import("package.tools.nmake").build(package, configs)
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

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            if not is_plat("iphoneos") then
                add_requires("openssl")
            end

            option("encrypt")
                set_default(true)
            option_end()

            option("SQLITE_THREADSAFE")
                set_default("2")
                set_values("0", "1", "2")
            option_end()

            option("SQLITE_TEMP_STORE")
                set_default("2")
                set_values("0", "1", "2")
            option_end()            

            target("sqlcipher")
                set_kind("$(kind)")
                if is_plat("iphoneos") then
                    add_frameworks("Security")
                    add_defines("SQLCIPHER_CRYPTO_CC")
                else
                    add_packages("openssl")
                    add_defines("SQLCIPHER_CRYPTO_OPENSSL")
                end
                if get_config("encrypt") then
                    add_defines("SQLITE_HAS_CODEC")
                end
                if is_plat("windows") then
                    add_defines("SQLITE_OS_WIN=1")
                    if is_kind("shared") then
                        add_defines("SQLITE_API=__declspec(dllexport)")
                    end
                else
                    add_defines("SQLITE_OS_UNIX=1")
                end
                if is_plat("android") then
                    add_cxflags("-Os")
                else
                    set_optimize("fastest")
                end
                if is_plat("macosx", "linux", "cross") then
                    add_defines("SQLITE_ENABLE_MATH_FUNCTIONS")
                    add_syslinks("pthread", "dl", "m")
                end
                if is_plat("android") then
                    add_defines("SQLITE_ENABLE_MATH_FUNCTIONS", "SQLITE_HAVE_ZLIB")
                    add_syslinks("dl", "m", "z")
                end                
                set_strip("all")
                add_defines("NDEBUG", "SQLITE_ENABLE_EXPLAIN_COMMENTS", "SQLITE_ENABLE_DBPAGE_VTAB", "SQLITE_ENABLE_STMTVTAB", "SQLITE_ENABLE_DBSTAT_VTAB", "SQLITE_ENABLE_MATH_FUNCTIONS")
                add_cxflags("-fPIC")
                add_includedirs(".")
                add_files("sqlite3.c")
                add_headerfiles("$(projectdir)/sqlite3*.h)")
            target_end()
        ]])    
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        table.insert(configs, "--encrypt=" .. (package:config("encrypt") and "y" or "n"))
        table.insert(configs, "--SQLITE_THREADSAFE=" .. package:config("SQLITE_THREADSAFE"))
        table.insert(configs, "--SQLITE_TEMP_STORE=" .. package:config("SQLITE_TEMP_STORE"))
        import("package.tools.xmake").install(package, configs)        
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
    end)