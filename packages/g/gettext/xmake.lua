package("gettext")

    set_homepage("https://www.gnu.org/software/gettext/")
    set_description("GNU internationalization (i18n) and localization (l10n) library.")

    set_urls("https://ftp.gnu.org/gnu/gettext/gettext-$(version).tar.xz",
             "https://ftpmirror.gnu.org/gettext/gettext-$(version).tar.xz",
             {version = function (version) return version:gsub('%-', '.') end})
    add_versions("0.19.8-1", "105556dbc5c3fbbc2aa0edb46d22d055748b6f5c7cd7a8d99f8e7eb84e938be4")

    if is_plat("macosx") then
        add_syslinks("iconv")
        add_frameworks("CoreFoundation")
    else
        add_deps("libiconv")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-shared=no",
                         "--enable-static=yes",
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
        if is_plat("macosx") then
            table.insert(configs, "--with-included-gettext")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ngettext", {includes = "libintl.h"}))
    end)
