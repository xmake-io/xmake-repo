package("lunzip")
    set_kind("binary")
    set_homepage("https://www.nongnu.org/lzip/lunzip.html")
    set_description("Lunzip is a decompressor for the lzip format written in C.")
    set_license("GPL-2.0-or-later")

    add_urls("https://download.nus.edu.sg/mirror/gentoo/distfiles/f7/lunzip-$(version).tar.gz",
             "https://debian.netcologne.de/savannah/lzip/lunzip/lunzip-$(version).tar.gz",
             "https://download.savannah.gnu.org/releases/lzip/lunzip/lunzip-$(version).tar.gz", {alias="archive"})

    add_versions("archive:1.15",  "fdb930b87672a238a54c4b86d63df1c86038ff577d512adbc8e2c754c046d8f2")

    if not is_subhost("windows") then
        add_deps("autotools")
    end

    on_load(function(package)
        if is_subhost("windows") then
            local msystem = "MINGW" .. (package:is_arch64() and "64" or "32")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true, gcc = true, make = true}})
        end
    end)

    on_install(function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("lunzip -h")
    end)
