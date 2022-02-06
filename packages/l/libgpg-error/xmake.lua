package("libgpg-error")

    set_homepage("https://www.gnupg.org/related_software/libgpg-error/")
    set_description("Libgpg-error is a small library that originally defined common error values for all GnuPG components.")
    set_license("GPL-2.0")

    add_urls("https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$(version).tar.bz2")
    add_versions("1.44", "8e3d2da7a8b9a104dd8e9212ebe8e0daf86aa838cc1314ba6bc4de8f2d8a1ff9")

    if is_plat("macosx") then
        add_deps("libintl")
    end
    on_install("linux", "macosx", function (package)
        local configs = {"--disable-doc", "--disable-tests"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gpgrt_strdup", {includes = "gpgrt.h"}))
    end)
