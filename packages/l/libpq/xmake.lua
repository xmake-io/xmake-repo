package("libpq")
    set_homepage("https://www.postgresql.org/docs/14/libpq.html")
    set_description("Postgres C API library")
    set_license("PostgreSQL")
    add_extsources("apt::libpq-dev", "brew::libpq", "pacman::postgresql-libs")

    add_urls("https://github.com/postgres/postgres/archive/refs/tags/REL_$(version).tar.gz", {alias = "github", version = function (version)
        return version:gsub("%.", "_")
    end})
    
    add_versions("17.5", "476e0522af981352177c12a05295b08d2f49b35c667aecb5bae1af4807999467")
    add_versions("14.1", "14809c9f669851ab89b344a50219e85b77f3e93d9df9e255b9781d8d60fcfbc9")

    add_deps("pkgconf", "meson", "ninja", "openssl", "zlib", "bison")
    
    on_load(function (package)
        if package:is_plat("macosx", "windows") then
            package:add("deps", "libintl")
        end

        if package:is_plat("macosx", "linux", "bsd", "windows") and package:is_arch("i386") ~= false then
            package:add("deps", "flex")
        end

        if package:is_plat("bsd") then
            package:add("deps", "libedit")
        end
    end)

    on_install("windows|!arm64", "macosx", "linux", "bsd", function (package)
        local configs = {"-Dssl=openssl", "-Dzlib=enabled"}

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        if package:is_plat("bsd") then
            table.insert(configs, "-Dreadline=disabled")
            table.insert(configs, "-Dlibedit_preferred=true")
        end

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PQconnectdb", {includes = "libpq-fe.h"}))
    end)
