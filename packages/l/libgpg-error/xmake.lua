package("libgpg-error")

    set_homepage("https://www.gnupg.org/related_software/libgpg-error/")
    set_description("Libgpg-error is a small library that originally defined common error values for all GnuPG components.")
    set_license("GPL-2.0")

    add_urls("https://github.com/gpg/libgpg-error/archive/refs/tags/libgpg-error-$(version).tar.gz")
    add_versions("1.39", "fff17f17928bc6efa2775b16d2ea986a9b82c128ab64dc877325cce468d9b4de")

    add_deps("gettext")

    on_install("linux", "macosx", function (package)
        local configs = {"--disable-doc", "--disable-tests", "--with-pic"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gpgrt_strdup", {includes = "gpgrt.h"}))
    end)
