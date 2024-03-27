package("libpq")
    set_homepage("https://www.postgresql.org/docs/16/libpq.html")
    set_description("Postgres C API library")
    set_license("PostgreSQL")

    add_urls("https://github.com/postgres/postgres/archive/refs/tags/REL_$(version).tar.gz", {alias = "github", version = function (version)
        return version:gsub("%.", "_")
    end})
    add_versions("16.1", "58250fee449f5fd0b5de5c1b0205e8aa8c9a4e3a8cead64ef8a3ca3c9fc2c6e9")
    add_versions("14.1", "14809c9f669851ab89b344a50219e85b77f3e93d9df9e255b9781d8d60fcfbc9")

    add_deps("icu4c", {configs = {shared = true}})
    add_deps("krb5", "openssl", "zlib")
    if is_plat("linux") then
        add_deps("flex", "bison")
    end

    on_install("macosx|x86_64", "linux", function (package)
        local configs = {"--with-openssl", "--without-readline"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_plat("macosx") then
            table.insert(configs, "--with-gssapi")
            local libinfo_krb5 = package:dep("krb5"):fetch()
            local libinfo_icu4c = package:dep("icu4c"):fetch()
            if libinfo_krb5 or libinfo_icu4c then
                local includedirs_krb5 = table.wrap(libinfo_krb5.sysincludedirs or libinfo_krb5.includedirs)
                local includedirs_icu4c = table.wrap(libinfo_icu4c.sysincludedirs or libinfo_icu4c.includedirs)
                local includedirs = table.join(includedirs_krb5, includedirs_icu4c)
                if #includedirs > 0 then
                    table.insert(configs, "--with-includes=" .. table.concat(includedirs, ":"))
                end
                local linkdirs_krb5 = table.wrap(libinfo_krb5.linkdirs)
                local linkdirs_icu4c = table.wrap(libinfo_icu4c.linkdirs)
                local linkdirs = table.join(linkdirs_krb5, linkdirs_icu4c)
                if #linkdirs > 0 then
                    table.insert(configs, "--with-libraries=" .. table.concat(linkdirs, ":"))
                end
                if libinfo_icu4c then
                    os.setenv("ICU_CFLAGS", "-I" .. includedirs_icu4c[1])
                    os.setenv("ICU_LIBS", "-L" .. linkdirs_icu4c[1])
                end
            end
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"icu4c", "openssl", "zlib"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PQconnectdb", {includes = "libpq-fe.h"}))
    end)
