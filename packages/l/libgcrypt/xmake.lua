package("libgcrypt")

    set_homepage("https://www.gnupg.org/related_software/libgcrypt/")
    set_description("Libgcrypt is a general purpose cryptographic library originally based on code from GnuPG.")
    set_license("GPL-2.0")

    add_urls("https://github.com/gpg/libgcrypt/archive/refs/tags/libgcrypt-$(version).tar.gz")
    add_versions("1.8.7", "c6e5bb1d29c0af709f67d1b748fd4eeada52a487bc2990366510b1b91e5204fb")

    add_deps("libgpg-error", "libxml2")
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-doc"}
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
