package("libthai")

    set_homepage("https://github.com/tlwg/libthai")
    set_description("LibThai is a set of Thai language support routines")
    set_license("LGPL-2.1")

    add_urls("https://github.com/tlwg/libthai/releases/download/v$(version)/libthai-$(version).tar.xz")
    add_versions("0.1.29", "fc80cc7dcb50e11302b417cebd24f2d30a8b987292e77e003267b9100d0f4bcd")
    
    add_deps("libdatrie", "pkg-config", "autoconf", "automake","m4", "libtool")

    on_install("linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-doxygen-doc", "--disable-dict"}
        table.insert(configs, (package:debug() and "--enable-debug" or ""))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs, {packagedeps = "libdatrie"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("th_brk_new", {includes = "thai/thbrk.h"}))
    end)
