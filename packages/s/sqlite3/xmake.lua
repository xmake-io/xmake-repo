package("sqlite3")

    set_homepage("https://sqlite.org/")
    set_description("The most used database engine in the world")

    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = "2021"
        if version:le("3.24") then
            year = "2018"
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

    if is_plat("macosx", "linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("sqlite3")
                set_kind("$(kind)")
                add_files("sqlite3.c")
                add_headerfiles("sqlite3.h", "sqlite3ext.h")
                add_defines("SQLITE_ENABLE_EXPLAIN_COMMENTS", "SQLITE_ENABLE_DBPAGE_VTAB", "SQLITE_ENABLE_STMTVTAB", "SQLITE_ENABLE_DBSTAT_VTAB", "SQLITE_ENABLE_MATH_FUNCTIONS")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("SQLITE_API=__declspec(dllexport)")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        if not package:is_plat("windows", "mingw") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
    end)
