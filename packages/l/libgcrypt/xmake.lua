package("libgcrypt")

    set_homepage("https://www.gnupg.org/related_software/libgcrypt/")
    set_description("Libgcrypt is a general purpose cryptographic library originally based on code from GnuPG.")
    set_license("GPL-2.0")

    add_urls("https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(version).tar.gz")
    add_versions("1.8.7", "55d98db5e5c7e7bb1efabe1299040d501e5d55272e10f60b68de9f9118b53102")

    add_deps("libgpg-error", "libxml2")
    on_install("linux", function (package)
        local configs = {"--disable-doc", "--with-pic"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        table.insert(configs, "--with-libgpg-error-prefix=" .. package:dep("libgpg-error"):installdir())
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gcry_check_version", {includes = "gcrypt.h"}))
    end)
