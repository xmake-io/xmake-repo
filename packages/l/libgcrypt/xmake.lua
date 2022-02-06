package("libgcrypt")

    set_homepage("https://www.gnupg.org/related_software/libgcrypt/")
    set_description("Libgcrypt is a general purpose cryptographic library originally based on code from GnuPG.")
    set_license("GPL-2.0")

    add_urls("https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(version).tar.gz")
    add_versions("1.10.0", "624dc2f72aaadf6ef4e183589aba794cc060bfbf14d2f4f0995b4d636189c584")

    add_deps("libgpg-error")
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-doc"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--with-libgpg-error-prefix=" .. package:dep("libgpg-error"):installdir())
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gcry_check_version", {includes = "gcrypt.h"}))
    end)
