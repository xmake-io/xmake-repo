package("libpq")
    set_homepage("https://www.postgresql.org/docs/14/libpq.html")
    set_description("Postgres C API library")
    set_license("PostgreSQL")

    add_urls("https://github.com/postgres/postgres/archive/refs/tags/REL_$(version).tar.gz", {alias = "github", version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("17.5", "476e0522af981352177c12a05295b08d2f49b35c667aecb5bae1af4807999467")

    add_deps("meson", "ninja", "openssl", "zlib", "flex", "bison")
    if is_plat("linux") then
        add_deps("krb5")
    end

    on_install("windows", "macosx", "linux", "!cross", function (package)
        local configs = {"-Dssl=openssl", "-Dzlib=enabled"}

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        if package:debug() then
            table.insert(configs, "--buildtype=debug")
        end

        import("package.tools.meson").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PQconnectdb", {includes = "libpq-fe.h"}))
    end)
