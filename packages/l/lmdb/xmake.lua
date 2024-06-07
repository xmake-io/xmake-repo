package("lmdb")
    set_homepage("http://www.openldap.org/software/repo.html")
    set_description("Read-only mirror of official repo on openldap.org. Issues and pull requests here are ignored. Use OpenLDAP ITS for issues.")

    add_urls("https://github.com/LMDB/lmdb/archive/refs/tags/LMDB_$(version).tar.gz",
             "https://github.com/LMDB/lmdb.git")

    add_versions("0.9.31", "dd70a8c67807b3b8532b3e987b0a4e998962ecc28643e1af5ec77696b081c9b0")

    add_configs("robust_mutex", {description = "Enable robust mutex", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("tools", {description = "Build tools", default = false, type = "boolean", readonly = true})
    else
        add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    end

    if is_plat("windows") then
        add_syslinks("Advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        local configs = {
            robust_mutex = package:config("robust_mutex"),
            tools = package:config("tools"),
        }
        package:add("defines", "MDB_USE_ROBUST=" .. (configs.robust_mutex and "1" or "0"))
        if configs.tools then
            package:addenv("PATH", "bin")
        end

        os.cd("libraries/liblmdb")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mdb_version", {includes = "lmdb.h"}))
    end)
