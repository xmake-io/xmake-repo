package("mysql-build-tools")
    set_kind("binary")
    set_homepage("http://www.mysql.com")
    set_description("This package help for mysql corss compilation")
    set_license("GPL-2.0")

    add_urls("https://github.com/mysql/mysql-server/archive/refs/tags/mysql-$(version).tar.gz")

    add_versions("8.0.40", "746c111747ba56ac9cdcd3d47867ee9f2e7d5d6230a1fd3401723db997e33f28")
    add_versions("8.0.39", "3a72e6af758236374764b7a1d682f7ab94c70ed0d00bf0cb0f7dd728352b6d96")

    add_configs("server", {description = "Build server", default = false, type = "boolean"})
    add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})

    add_deps("cmake")
    add_deps("zlib", "zstd", "lz4", "openssl", "rapidjson", {host = true, private = true})
    if is_plat("linux") then
        add_deps("patchelf")
        add_deps("libedit", {host = true, private = true, configs = {terminal_db = "ncurses"}})
    end
    if is_plat("windows") then
        add_deps("ninja")
        set_policy("package.cmake_generator.ninja", true)
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
            package:add("deps", "boost", {host = true, private = true, configs = {header_only = true}})
            package:add("deps", "libevent", {host = true, private = true})
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local mysql_script_dir = path.join(path.directory(package:scriptdir()), "mysql")

        import("patch", {rootdir = mysql_script_dir})
        import("configs", {rootdir = mysql_script_dir})
        import("package.tools.cmake")
        import("core.base.hashset")

        local opt = {}
        if cmake.configure then -- xmake 2.9.5
            opt.target = tool_list
        end
        patch.cmake(package)
        cmake.build(package, configs.get(package, true), opt)

        local hash = hashset.from(tool_list)
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
