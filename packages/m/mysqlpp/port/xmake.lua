add_rules("mode.debug", "mode.release")
add_requires("mysql", "zlib", "zstd")

target("mysqlpp")
    set_kind("shared")
    add_files("lib/beemutex.cpp","lib/cmdline.cpp","lib/connection.cpp","lib/cpool.cpp","lib/datetime.cpp","lib/dbdriver.cpp","lib/field_names.cpp","lib/field_types.cpp","lib/manip.cpp","lib/myset.cpp","lib/mysql++.cpp","lib/mystring.cpp","lib/null.cpp","lib/options.cpp","lib/qparms.cpp","lib/query.cpp","lib/result.cpp","lib/row.cpp","lib/scopedconnection.cpp","lib/sql_buffer.cpp","lib/sqlstream.cpp","lib/ssqls2.cpp","lib/stadapter.cpp","lib/tcp_connection.cpp","lib/transaction.cpp","lib/type_info.cpp","lib/uds_connection.cpp","lib/utility.cpp","lib/vallist.cpp","lib/wnp_connection.cpp")
    add_packages("mysql", "zlib", "zstd")
    add_headerfiles("lib/*.h")
    if is_plat("windows") then
        add_defines("_USRDLL","DLL_EXPORTS","UNICODE","_UNICODE","MYSQLPP_MAKING_DLL","HAVE_MYSQL_SSL_SET")
    elseif is_plat("mingw") then
        add_syslinks("pthread")
        add_defines("UNICODE","_UNICODE","MYSQLPP_NO_DLL","HAVE_MYSQL_SSL_SET")
    end
