package("mysql-build-tools")
    set_kind("binary")
    set_homepage("http://www.mysql.com")
    set_description("This package help for mysql corss compilation")
    set_license("GPL-2.0")

    add_urls("https://github.com/mysql/mysql-server/archive/refs/tags/mysql-$(version).tar.gz")

    add_versions("8.0.39", "3a72e6af758236374764b7a1d682f7ab94c70ed0d00bf0cb0f7dd728352b6d96")

    add_configs("server", {description = "Build server", default = false, type = "boolean"})
    add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})

    add_deps("cmake")
    add_deps("zlib", "zstd", "lz4", "openssl", "rapidjson")
    if is_plat("linux") then
        add_deps("patchelf")
        add_deps("libedit", {configs = {terminal_db = "ncurses"}})
    end

    local tool_list = {
        "uca9dump",
        "comp_sql",
        "comp_err",
        "comp_client_err",
        "libmysql_api_test",
    }

    on_load(function(package)
        if package:config("server") then
            table.join2(tool_list, {
                "json_schema_embedder",
                "gen_lex_token",
                "gen_lex_hash",
                "gen_keyword_list"
            })
        end

        local version = package:version()
        if version:lt("9.0.0") then
            package:add("deps", "boost", "libevent")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local mysql_script_dir = path.join(path.directory(package:scriptdir()), "mysql")
        import("patch", {rootdir = mysql_script_dir}).cmake(package)

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
    
            "-DWITH_CURL=none",
            "-DWITH_KERBEROS=none",
            "-DWITH_FIDO=none",
    
            "-DCMAKE_BUILD_TYPE=Release",
        }
        if package:is_plat("linux") then
            local widec = package:dep("ncurses"):config("widec")
            -- From FindCurses.cmake
            table.insert(configs, "-DCURSES_NEED_WIDE=" .. (widec and "ON" or "OFF"))
            table.insert(configs, "-DWITH_EDITLINE=system")
        end
        table.insert(configs, "-DWITHOUT_SERVER=" .. (package:config("server") and "OFF" or "ON"))
        if package:is_cross() then
            table.insert(configs, "-DCMAKE_CROSSCOMPILING=ON")
        end

        local opt = {}
        if xmake:version():ge("2.9.5") then
            opt.target = tool_list
        end
        import("package.tools.cmake").build(package, configs, opt)

        local hash = import("core.base.hashset").from(tool_list)
        local tools_dir = path.join(package:buildir(), "runtime_output_directory/**")
        for _, file in ipairs(os.files(tools_dir)) do
            if hash:has(path.basename(file)) then
                os.vcp(file, package:installdir("bin"))
            end
        end
    end)

    on_test(function (package)
        for _, name in ipairs(tool_list) do
            if is_host("windows") then
                name = name .. ".exe"
            end
            local exec = path.join(package:installdir("bin", name))
            assert(os.isexec(exec), name .. " not found!")
        end
    end)
