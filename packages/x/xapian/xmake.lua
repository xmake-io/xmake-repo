package("xapian")
    set_homepage("https://savannah.gnu.org/projects/osip")
    set_description("Xapian is an Open Source Search Engine Library, with bindings to allow use from Perl, Python 2, Python 3, PHP 5, PHP 7, Java, Tcl, C#, Ruby, Lua, Erlang, Node.js, R.")
    set_license("GPL-2.0-or-later")

    add_urls("https://oligarchy.co.uk/xapian/$(version)/xapian-core-$(version).tar.xz")

    add_versions("1.4.27", "bcbc99cfbf16080119c2571fc296794f539bd542ca3926f17c2999600830ab61")

    if is_plat('wasm') then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if not is_plat("msys", "mingw", "windows") then
        add_deps("autoconf", "automake", "libtool")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "rpcrt4")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("zlib")

    if is_plat("linux", "macosx", "bsd", "android", "iphoneos", "wasm", "cross") then
        add_deps("libuuid")
    end

    if is_plat("mingw") then
        add_deps("ssp")
    end

    on_install("!windows and !android@windows", function (package)
        io.replace("include/xapian/version_h.cc", "#elif defined _MSC_VER", "#elif 0", {plain = true})

        io.replace("configure.ac", "dnl Check for zlib.h.", [[
enable_zlib_checks=no        
  if test "x$enable_zlib_checks" = "xyes"; then
  dnl Check for zlib.h.
        ]], {plain = true})

        io.replace("configure.ac", "dnl Find a way to generate UUIDs.", [[
fi
  PKG_CHECK_MODULES([ZLIB], [zlib], [],[AC_MSG_ERROR([zlib library not found])])
  CFLAGS="$LIBS $ZLIB_CFLAGS"
  LIBS="$ZLIB_LIBS $LIBS"
  dnl Find a way to generate UUIDs.
        ]], {plain = true})

        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))

        local deps = {"zlib"}

        if is_plat("linux", "macosx", "bsd", "android", "iphoneos", "wasm", "cross") then
            table.insert(deps, "libuuid")
        end
    
        if is_plat("mingw") then
            table.insert(deps, "ssp")
        end

        import("package.tools.autoconf").install(package, configs, {packagedeps = deps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Xapian::version_string();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "xapian.h"}))
    end)
