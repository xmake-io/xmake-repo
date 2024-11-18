package("sqlite3")

    set_homepage("https://sqlite.org/")
    set_description("The most used database engine in the world")
    set_license("Public Domain")

    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = "2024"
        if version:le("3.24") then
            year = "2018"
        elseif version:le("3.36") then
            year = "2021"
        elseif version:le("3.42") then
            year = "2022"
        elseif version:le("3.44") then
            year = "2023"
        end
        local version_str = version:gsub("[.+]", "")
        if #version_str < 7 then
            version_str = version_str .. "00"
        end
        return year .. "/sqlite-autoconf-" .. version_str .. ".tar.gz"
    end})

    add_versions("3.23.0+0",   "b7711a1800a071674c2bf76898ae8584fc6c9643cfe933cfc1bc54361e3a6e49")
    add_versions("3.24.0+0",   "d9d14e88c6fb6d68de9ca0d1f9797477d82fc3aed613558f87ffbdbbc5ceb74a")
    add_versions("3.34.0+100", "2a3bca581117b3b88e5361d0ef3803ba6d8da604b1c1a47d902ef785c1b53e89")
    add_versions("3.35.0+300", "ecbccdd440bdf32c0e1bb3611d635239e3b5af268248d130d0445a32daf0274b")
    add_versions("3.35.0+400", "7771525dff0185bfe9638ccce23faa0e1451757ddbda5a6c853bb80b923a512d")
    add_versions("3.36.0+0", "bd90c3eb96bee996206b83be7065c9ce19aef38c3f4fb53073ada0d0b69bbce3")
    add_versions("3.37.0+200", "4089a8d9b467537b3f246f217b84cd76e00b1d1a971fe5aca1e30e230e46b2d8")
    add_versions("3.39.0+200", "852be8a6183a17ba47cee0bbff7400b7aa5affd283bf3beefc34fcd088a239de")
    add_versions("3.43.0+200", "6d422b6f62c4de2ca80d61860e3a3fb693554d2f75bb1aaca743ccc4d6f609f0")
    add_versions("3.45.0+100", "cd9c27841b7a5932c9897651e20b86c701dd740556989b01ca596fcfa3d49a0a")
    add_versions("3.45.0+200", "bc9067442eedf3dd39989b5c5cfbfff37ae66cc9c99274e0c3052dc4d4a8f6ae")
    add_versions("3.45.0+300", "b2809ca53124c19c60f42bf627736eae011afdcc205bb48270a5ee9a38191531")
    add_versions("3.46.0+0", "6f8e6a7b335273748816f9b3b62bbdc372a889de8782d7f048c653a447417a7d")
    add_versions("3.46.0+100", "67d3fe6d268e6eaddcae3727fce58fcc8e9c53869bdd07a0c61e38ddf2965071")
    add_versions("3.47.0+0", "83eb21a6f6a649f506df8bd3aab85a08f7556ceed5dbd8dea743ea003fc3a957")

    add_configs("explain_comments", { description = "Inserts comment text into the output of EXPLAIN.", default = true, type = "boolean"})
    add_configs("dbpage_vtab",      { description = "Enable the SQLITE_DBPAGE virtual table.", default = true, type = "boolean"})
    add_configs("stmt_vtab",        { description = "Enable the SQLITE_STMT virtual table logic.", default = true, type = "boolean"})
    add_configs("dbstat_vtab",      { description = "Enable the dbstat virtual table.", default = true, type = "boolean"})
    add_configs("math_functions",   { description = "Enable the built-in SQL math functions.", default = true, type = "boolean"})
    add_configs("rtree",            { description = "Enable R-Tree.", default = false, type = "boolean"})
    add_configs("safe_mode",        { description = "Use thread safe mode in 0 (single thread) | 1 (serialize) | 2 (mutli thread).", default = "1", type = "string", values = {"0", "1", "2"}})

    if is_plat("macosx", "linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install(function (package)
        local xmake_lua = [[
            add_rules("mode.debug", "mode.release")
            set_encodings("utf-8")

            option("explain_comments", {default = false, defines = "SQLITE_ENABLE_EXPLAIN_COMMENTS"})
            option("dbpage_vtab", {default = false, defines = "SQLITE_ENABLE_DBPAGE_VTAB"})
            option("stmt_vtab", {default = false, defines = "SQLITE_ENABLE_STMTVTAB"})
            option("dbstat_vtab", {default = false, defines = "SQLITE_ENABLE_DBSTAT_VTAB"})
            option("math_functions", {default = false, defines = "SQLITE_ENABLE_MATH_FUNCTIONS"})
            option("rtree", {default = false, defines = "SQLITE_ENABLE_RTREE"})
            option("safe_mode", {default = "1"})

            target("sqlite3")
                set_kind("$(kind)")
                add_files("sqlite3.c")
                add_headerfiles("sqlite3.h", "sqlite3ext.h")
                add_options("explain_comments", "dbpage_vtab", "stmt_vtab", "dbstat_vtab", "math_functions", "rtree")

                if has_config("safe_mode") then
                    add_defines("SQLITE_THREADSAFE=" .. get_config("safe_mode"))
                end

                if is_kind("shared") and is_plat("windows") then
                    add_defines("SQLITE_API=__declspec(dllexport)")
                end
                if is_plat("macosx", "linux", "bsd") then
                    add_syslinks("pthread", "dl")
                end
        ]]
        if package:is_plat(os.host()) and (package:is_arch(os.arch()) or package:is_plat("windows")) then
            xmake_lua = xmake_lua .. [[
                target("sqlite3_shell")
                    set_kind("binary")
                    set_basename("sqlite3")
                    add_files("shell.c")
                    add_deps("sqlite3")
            ]]
        end
        io.writefile("xmake.lua", xmake_lua)

        local configs = {}
        for opt, value in pairs(package:configs()) do
            if not package:extraconf("configs", opt, "builtin") then
                configs[opt] = value
            end
        end

        import("package.tools.xmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
    end)
