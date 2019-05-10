package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")

    set_urls("http://xmlsoft.org/sources/libxml2-$(version).tar.gz", 
             "https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-$(version).tar.gz")
    add_urls("https://gitlab.gnome.org/GNOME/libxml2.git")

    add_versions("2.9.9", "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871")
 
    add_includedirs("include/libxml2")
    if is_plat("windows") then
        add_links("libxml2_a")
        add_syslinks("wsock32", "ws2_32")
    else
        add_links("xml2")
    end

    on_load("macosx", "linux", "iphoneos", "android", function (package)
        if package:gitref() then
            package:add("deps", "autoconf", "automake", "libtool", "pkg-config")
        end
    end)

    if is_plat("windows") and winos.version():gt("winxp") then
        on_install("windows", function (package)
            os.cd("win32")
            os.vrun("cscript configure.js iso8859x=yes iconv=no compiler=msvc cruntime=/MT debug=%s prefix=\"%s\"", package:debug() and "yes" or "no", package:installdir())
            os.vrun("nmake /f Makefile.msvc")
            os.vrun("nmake /f Makefile.msvc install")
        end)
    end

    on_install("macosx", "linux", "iphoneos", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--without-python", 
                         "--without-lzma", 
                         "--without-zlib",
                         "--without-iconv",
                         "--enable-shared=no"}
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xmlNewNode", {includes = {"libxml/parser.h", "libxml/tree.h"}}))
    end)
