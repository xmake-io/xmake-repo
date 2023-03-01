package("gettext")

    set_homepage("https://www.gnu.org/software/gettext/")
    set_description("GNU internationalization (i18n) and localization (l10n) library.")

    set_urls("https://ftp.gnu.org/gnu/gettext/gettext-$(version).tar.xz",
             "https://ftpmirror.gnu.org/gettext/gettext-$(version).tar.xz",
             {version = function (version) return version:gsub('%-', '.') end})
    add_versions("0.19.8-1", "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4")
    add_versions("0.21", "d20fcbb537e02dcf1383197ba05bd0734ef7bf5db06bdb241eb69b7d16b73192")
    add_versions("0.21.1", "50dbc8f39797950aa2c98e939947c527e5ac9ebd2c1b99dd7b06ba33a6767ae6")

    if is_plat("macosx") then
        add_syslinks("iconv")
        add_frameworks("CoreFoundation")
    else
        add_deps("libiconv")
    end

    on_install("macosx", "linux", "android", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--with-included-glib",
                         "--with-included-libcroco",
                         "--with-included-libunistring",
                         "--with-lispdir=#{elisp}",
                         "--disable-java",
                         "--disable-csharp",
                         "--without-emacs",
                         "--without-git",
                         "--without-bzip2",
                         "--without-cvs",
                         "--without-xz"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:is_plat("macosx") then
            table.insert(configs, "--with-included-gettext")
        end
        if package:is_plat("android") and package:version():le("0.20") then
            io.replace("./gettext-tools/configure", "#define gid_t int", "")
            io.replace("./gettext-tools/configure", "#define uid_t int", "")
            io.replace("./gettext-runtime/configure", "#define gid_t int", "")
            io.replace("./gettext-runtime/configure", "#define uid_t int", "")
            io.replace("./gettext-tools/gnulib-lib/spawn.in.h", "@HAVE_SPAWN_H@", "0")
            io.replace("./gettext-tools/gnulib-lib/spawn.in.h", "@HAVE_POSIX_SPAWNATTR_T@", "0")
            io.replace("./gettext-tools/gnulib-lib/spawn.in.h", "@HAVE_POSIX_SPAWN_FILE_ACTIONS_T@", "0")
            io.replace("./gettext-runtime/src/Makefile.in",
                "bin_PROGRAMS = gettext$(EXEEXT) ngettext$(EXEEXT) envsubst$(EXEEXT)",
                "bin_PROGRAMS =", {plain = true})
            io.replace("./gettext-tools/src/Makefile.in",
                "bin_PROGRAMS = .*noinst_PROGRAMS =",
                "bin_PROGRAMS =\nnoinst_PROGRAMS =")
            io.replace("./gettext-tools/src/Makefile.in",
                "noinst_PROGRAMS = hostname$(EXEEXT) urlget$(EXEEXT) \\",
                "bin_PROGRAMS =", {plain = true})
            io.replace("./gettext-tools/src/Makefile.in",
                "cldr-plurals$(EXEEXT)",
                "", {plain = true})
            io.replace("./gettext-tools/src/Makefile.in",
                "install-exec-local:",
                "install-exec-local: \n\ninstall-exec-local_: ", {plain = true})
            io.replace("./gettext-tools/config.h.in", "#undef ICONV_CONST", "#define ICONV_CONST const")
            io.replace("./gettext-runtime/config.h.in", "#undef ICONV_CONST", "#define ICONV_CONST const")
            io.replace("./gettext-tools/libgrep/langinfo.in.h", "@HAVE_LANGINFO_H@", "0")
            io.replace("./gettext-tools/gnulib-lib/langinfo.in.h", "@HAVE_LANGINFO_H@", "0")
            io.replace("./gettext-runtime/gnulib-lib/langinfo.in.h", "@HAVE_LANGINFO_H@", "0")
        end
        local cflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cflags = cflags, ldflags = ldflags})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ngettext", {includes = "libintl.h"}))
    end)
