package("libmd")

    set_homepage("https://www.hadrons.org/software/libmd/")
    set_description("Message Digest functions from BSD systems")
    set_license("BSD-3-Clause")

    add_urls("https://archive.hadrons.org/software/libmd/libmd-$(version).tar.xz")
    add_urls("https://libbsd.freedesktop.org/releases/libmd-$(version).tar.xz")
    add_versions("1.0.4", "f51c921042e34beddeded4b75557656559cf5b1f2448033b4c1eec11c07e530f")

    if not is_subhost("windows") then
        add_deps("autotools")
    end

    on_install("linux", "android", "cross", "bsd", "mingw", "wasm", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MD5Init", {includes = "md5.h"}))
    end)
