package("openldap")

    set_homepage("https://www.openldap.org/")
    set_description("OpenLDAP Software is an open source implementation of the Lightweight Directory Access Protocol.")

    add_urls("https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-$(version).tgz")
    add_versions("2.5.7", "ea9757001bc36295037f0030ede16810a1bb7438bbe8f871a35cc2a2b439d9ab")

    add_configs("tls", {description = "Set TLS/SSL support library.", default = "openssl", type = "string", values = {"openssl", "gnutls"}})
    add_configs("sasl", {description = "Enable Cyrus SASL support.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("linux", "macosx", function (package)
        package:add("deps", package:config("tls"))
        if package:config("sasl") then
            package:add("deps", "cyrus-sasl")
        end
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-tls=" .. package:config("tls"))
        table.insert(configs, "--with-cyrus-sasl=" .. (package:config("sasl") and "yes" or "no"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local cppflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cppflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ldap_get_option", {includes = "ldap.h"}))
    end)
