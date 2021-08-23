package("libgpg-error")

    set_homepage("https://www.gnupg.org/related_software/libgpg-error/")
    set_description("Libgpg-error is a small library that originally defined common error values for all GnuPG components.")
    set_license("GPL-2.0")

    add_urls("https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$(version).tar.gz")
    add_versions("1.39", "3d4dc56588d62ff01067af192e2d3de38ef4c060857ed8da77327365477569ca")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libgpg-error")
    elseif is_plat("linux") then
        add_extsources("pacman::libgpg-error", "apt::libgpg-error-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libgpg-error")
    end

    on_install("linux", function (package)
        local configs = {"--disable-doc", "--disable-tests", "--with-pic"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gpgrt_strdup", {includes = "gpgrt.h"}))
    end)
