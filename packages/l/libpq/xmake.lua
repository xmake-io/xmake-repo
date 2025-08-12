package("libpq")
    set_homepage("https://www.postgresql.org/docs/14/libpq.html")
    set_description("Postgres C API library")
    set_license("PostgreSQL")

    add_urls("https://github.com/postgres/postgres/archive/refs/tags/REL_$(version).tar.gz", {alias = "github", version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("17.5", "476e0522af981352177c12a05295b08d2f49b35c667aecb5bae1af4807999467")

    add_deps("meson", "ninja", "openssl", "zlib", "bison")
    

    on_load("windows|!arm64 or macosx|!arm64 or linux|!arm64 or bsd|!arm64", function (package)
        if package:is_plat("mingw", "macosx", "windows") then
            package:add("deps", "libintl")
        end

        if package:is_plat("macosx", "linux", "bsd", "windows", "@msys") and package:is_arch("i386") ~= false then
            package:add("deps", "flex")
        end

        if package:is_plat("linux", "macosx") then
            package:add("deps", "krb5")
        end

        if package:is_plat("bsd") then
            package:add("deps", "readline")
        end
    end)

    on_install("windows|!arm64 or macosx|!arm64 or linux|!arm64 or bsd|!arm64", function (package)
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
