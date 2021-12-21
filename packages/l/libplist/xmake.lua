package("libplist")

    set_homepage("https://www.libimobiledevice.org/")
    set_description("Library for Apple Binary- and XML-Property Lists")
    set_license("LGPL-2.1")

    set_urls("https://github.com/libimobiledevice/libplist/archive/$(version).tar.gz",
             "https://github.com/libimobiledevice/libplist.git")
    add_versions("2.2.0", "7e654bdd5d8b96f03240227ed09057377f06ebad08e1c37d0cfa2abe6ba0cee2")

    add_deps("autoconf", "automake", "libtool", "pkg-config")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("macosx", "linux", "mingw@macosx", "iphoneos", "cross", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--without-cython"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        local cxflags
        if package:is_plat("linux") and package:config("pic") ~= false then
            cxflags = "-fPIC"
        end
        io.replace("src/plist.c", "void thread_once", "static void thread_once")
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plist_new_dict", {includes = "plist/plist.h"}))
    end)
