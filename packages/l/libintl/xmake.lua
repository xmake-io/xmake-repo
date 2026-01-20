package("libintl")
    set_homepage("https://www.gnu.org/software/gettext/")
    set_description("GNU gettext runtime")

    add_urls("https://mirrors.dotsrc.org/gnu/gettext/gettext-$(version).tar.xz",
             "https://ftpmirror.gnu.org/gnu/gettext/gettext-$(version).tar.xz",
             "https://ftp.gnu.org/gnu/gettext/gettext-$(version).tar.xz")
    add_versions("0.21", "d20fcbb537e02dcf1383197ba05bd0734ef7bf5db06bdb241eb69b7d16b73192")
    add_versions("0.22.3", "b838228b3f8823a6c1eddf07297197c4db13f7e1b173b9ef93f3f945a63080b6")

    if is_plat("mingw") then
        add_patches("0.22.3", "patches/0.22.3/fix-mingw-build-wgetcwd.diff", "4db86b836cf332151558d5cd4553ed2e8a6dc88676b5d66dda486f55dcd6785c")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    end

    on_fetch(function (package, opt)
        if opt.system then
            return package:find_package("system::intl", {includes = "libintl.h"})
        end
    end)

    on_install("windows", "macosx", "android", "mingw", function (package)
        -- on linux libintl is already a part of libc
        os.cp(path.join(os.scriptdir(), "port", package:version_str(), "xmake.lua"), "xmake.lua")
        for _, conffile in ipairs({"gettext-runtime/config.h.in", "gettext-runtime/intl/config.h.in"}) do
            io.replace(conffile, "$", "", {plain = true})
            io.replace(conffile, "# ?undef (.-)\n", "${define %1}\n")
        end
        import("package.tools.xmake").install(package, {
            vers = package:version_str(),
            relocatable = true,
            installprefix = package:installdir():gsub("\\", "/")
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ngettext", {includes = "libintl.h"}))
    end)
