package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")
    set_license("MIT")

    set_urls("http://xmlsoft.org/sources/libxml2-$(version).tar.gz",
             "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-$(version).tar.gz")
    add_urls("https://gitlab.gnome.org/GNOME/libxml2.git")
    add_versions("2.9.9", "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871")
    add_versions("2.9.10", "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f")
    add_versions("2.9.12", "c8d6681e38c56f172892c85ddc0852e1fd4b53b4209e7f4ebf17f7e2eae71d92")

    add_includedirs("include/libxml2")
    if is_plat("windows") then
        add_syslinks("wsock32", "ws2_32")
    else
        add_links("xml2")
    end
    if is_plat("linux") then
        add_extsources("pkgconfig::libxml-2.0", "apt::libxml2-dev")
        add_syslinks("m")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "LIBXML_STATIC")
        end
    end)

    on_load("macosx", "linux", "iphoneos", "android", function (package)
        if package:gitref() then
            package:add("deps", "autoconf", "automake", "libtool", "pkg-config")
        end
    end)

    on_install("windows", function (package)
        os.cd("win32")
        os.vrun("cscript configure.js iso8859x=yes iconv=no compiler=msvc cruntime=/%s debug=%s prefix=\"%s\"", package:config("vs_runtime"), package:debug() and "yes" or "no", package:installdir())
        import("package.tools.nmake").install(package, {"/f", "Makefile.msvc"})
        os.tryrm(path.join(package:installdir("lib"), "libxml2_a_dll.lib"))
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "libxml2_a.lib"))
        else
            os.tryrm(path.join(package:installdir("lib"), "libxml2.lib"))
            os.tryrm(path.join(package:installdir("bin"), "libxml2.dll"))
        end
    end)

    on_install("macosx", "linux", "iphoneos", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--with-pic",
                         "--without-python",
                         "--without-lzma",
                         "--without-zlib",
                         "--without-iconv"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xmlNewNode", {includes = {"libxml/parser.h", "libxml/tree.h"}}))
    end)
