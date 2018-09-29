package("libxml2")

    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")

    set_urls("https://github.com/GNOME/libxml2/archive/$(version).zip", {excludes = {"*/result/*", "*/test/*"}})

    add_versions("v2.9.8", "c87793e45e66a7aa19200f861873f75195065de786a21c1b469bdb7bfc1230fb")
    add_versions("v2.9.7", "31dd4c0e10fa625b47e27fd6a5295d246c883f214da947b9a4a9e13733905ed9")

    if is_plat("macosx", "linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_install("windows", function (package)
        os.cd("win32")
        os.vrun("cscript configure.js iso8859x=yes iconv=no compiler=msvc cruntime=/MT debug=%s prefix=\"%s\"", package:debug() and "yes" or "no", package:installdir())
        os.vrun("nmake /f Makefile.msvc")
        os.vrun("nmake /f Makefile.msvc install")
        package:addvar("includedirs", "include/libxml2")
        package:addvar("links", "libxml2")
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-dependency-tracking", "--without-python", "--without-lzma"})
        package:addvar("includedirs", "include/libxml2")
    end)
