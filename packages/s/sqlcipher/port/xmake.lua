add_rules("mode.debug", "mode.release")

if not is_plat("iphoneos") then
    add_requires("openssl3")
end

option("encrypt")
    set_default(true)
option_end()

option("threadsafe")
    set_default("2")
    set_values("0", "1", "2")
option_end()

option("temp_store")
    set_default("2")
    set_values("0", "1", "2", "3")
option_end()            

target("sqlcipher")
    set_kind("$(kind)")
    if has_config("encrypt") then
        add_defines("SQLITE_HAS_CODEC")
    end

    if is_plat("iphoneos") then
        add_frameworks("Security")
        add_defines("SQLCIPHER_CRYPTO_CC")
    else
        add_packages("openssl3")
        add_defines("SQLCIPHER_CRYPTO_OPENSSL")
    end

    if is_plat("windows") then
        add_defines("SQLITE_OS_WIN=1")
        if is_kind("shared") then
            add_defines("SQLITE_API=__declspec(dllexport)")
        end
    else
        add_defines("SQLITE_OS_UNIX=1")
    end

    if is_plat("macosx", "linux", "cross") then
        add_defines("SQLITE_ENABLE_MATH_FUNCTIONS")
        add_syslinks("pthread", "dl", "m")
    end
    if is_plat("android") then
        add_defines("SQLITE_ENABLE_MATH_FUNCTIONS", "SQLITE_HAVE_ZLIB")
        add_syslinks("dl", "m", "z")
    end

    add_defines("SQLITE_EXTRA_INIT=sqlcipher_extra_init")
    add_defines("SQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown")
    add_defines("SQLITE_THREADSAFE=$(threadsafe)")
    add_defines("SQLITE_TEMP_STORE=$(temp_store)")
    add_defines("NDEBUG", "SQLITE_ENABLE_EXPLAIN_COMMENTS", "SQLITE_ENABLE_DBPAGE_VTAB", "SQLITE_ENABLE_STMTVTAB", "SQLITE_ENABLE_DBSTAT_VTAB", "SQLITE_ENABLE_MATH_FUNCTIONS")
    add_files("sqlite3.c")
    add_headerfiles("sqlite3*.h)")