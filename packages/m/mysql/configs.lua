function _host_tool_configs(package)
    return {
        "-DCMAKE_BUILD_TYPE=Release",

        "-DWITH_CURL=none",
        "-DWITH_KERBEROS=none",
        "-DWITH_FIDO=none",
    }
end

function _target_configs(package)
    local configs = {}
    table.insert(configs, "-DWITH_CURL=" .. (package:config("curl") and "system" or "none"))
    table.insert(configs, "-DWITH_KERBEROS=" .. (package:config("kerberos") and "system" or "none"))
    table.insert(configs, "-DWITH_FIDO=" .. (package:config("fido") and "system" or "none"))
    return configs
end

function get(package, build_host_tool)
    local configs = {
        "-DWITH_BUILD_ID=OFF",
        "-DWITH_UNIT_TESTS=OFF",
        "-DENABLED_PROFILING=OFF",
        "-DWIX_DIR=OFF",
        "-DWITH_TEST_TRACE_PLUGIN=OFF",
        "-DMYSQL_MAINTAINER_MODE=OFF",
        "-DBUNDLE_RUNTIME_LIBRARIES=OFF",
        "-DDOWNLOAD_BOOST=OFF",

        "-DWITH_BOOST=system",
        "-DWITH_LIBEVENT=system",
        "-DWITH_ZLIB=system",
        "-DWITH_ZSTD=system",
        "-DWITH_SSL=system",
        "-DWITH_LZ4=system",
        "-DWITH_RAPIDJSON=system",
    }

    if package:is_cross() then
        table.insert(configs, "-DCMAKE_CROSSCOMPILING=ON")
    end

    if package:is_plat("linux") then
        local widec = package:dep("ncurses"):config("widec")
        -- From FindCurses.cmake
        table.insert(configs, "-DCURSES_NEED_WIDE=" .. (widec and "ON" or "OFF"))
        table.insert(configs, "-DWITH_EDITLINE=system")
    end

    if package:config("server") then
        -- TODO: server deps
        table.insert(configs, "-DWITH_ICU=system")
        table.insert(configs, "-DWITH_PROTOBUF=system")
    end

    if package:config("x") then
        table.join2(configs, {"-DWITH_MYSQLX=ON", "-DWITH_MYSQLX_USE_PROTOBUF_FULL=ON"})
    else
        table.insert(configs, "-DWITH_MYSQLX=OFF")
    end

    if package:config("cluster") then
        table.join2(configs, {"-DWITH_NDB=ON", "-DWITH_NDBCLUSTER=ON"})
    else
        table.join2(configs, {"-DWITH_NDB=OFF", "-DWITH_NDBCLUSTER=OFF"})
    end
    table.insert(configs, "-DWITHOUT_SERVER=" .. (package:config("server") and "OFF" or "ON"))
    table.join2(configs, (build_host_tool and _host_tool_configs(package) or _target_configs(package)))
    return configs
end
