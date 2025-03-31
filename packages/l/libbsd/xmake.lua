package("libbsd")

    set_homepage("https://libbsd.freedesktop.org/wiki/")
    set_description("This library provides useful functions commonly found on BSD systems")
    set_license("BSD-3-Clause")

    add_urls("https://libbsd.freedesktop.org/releases/libbsd-$(version).tar.xz")
    add_versions("0.11.5", "1a9c952525635c1bb6770cb22e969b938d8e6a9d7912362b98ee8370599b0efd")
    add_versions("0.12.2", "b88cc9163d0c652aaf39a99991d974ddba1c3a9711db8f1b5838af2a14731014")

    add_deps("autotools", "libmd")
    add_links("bsd")

    on_install("linux", "android@linux,macosx", "cross", "bsd", "mingw", "wasm", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"libmd"}})
        if not package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "libbsd.so"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bsd_getopt", {includes = "bsd/unistd.h"}))
    end)
