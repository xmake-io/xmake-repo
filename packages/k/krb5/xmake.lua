package("krb5")

    set_homepage("http://web.mit.edu/kerberos/")
    set_description("Kerberos: The Network Authentication Protocol")

    add_urls("https://kerberos.org/dist/krb5/$(version).tar.gz", {version = function (version)
        return format("%d.%d/krb5-%s", version:major(), version:minor(), version)
    end})
    add_versions("1.22.1", "1a8832b8cad923ebbf1394f67e2efcf41e3a49f460285a66e35adec8fa0053af")

    add_configs("tls", {description = "Enable TLS/OpenSSL support.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("bison", "libverto")
    add_links("k5crypto", "kdb5", "krad", "gssapi_krb5", "krb5support", "krb5", "gssrpc", "verto", "com_err")
    on_load("macosx", "linux", function (package)
        if package:config("tls") then
            package:add("deps", "openssl")
        end
    end)

    on_install("macosx", "linux", function (package)
        os.cd("src")
        local configs = {"--disable-dependency-tracking", "--with-system-verto"}
        table.insert(configs, "--with-tls-impl=" .. (package:config("tls") and "openssl" or "no"))
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
            end
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("krb5_c_encrypt", {includes = "krb5.h"}))
    end)
