package("libintl")

    set_homepage("https://www.gnu.org/software/gettext/")
    set_description("GNU gettext runtime")

    add_urls("https://ftp.gnu.org/gnu/gettext/gettext-$(version).tar.xz")
    add_versions("0.21", "d20fcbb537e02dcf1383197ba05bd0734ef7bf5db06bdb241eb69b7d16b73192")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("windows", "macosx", "android", function (package)
        -- on linux libintl is already a part of libc
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        io.replace("gettext-runtime/config.h.in", "$", "", {plain = true})
        io.replace("gettext-runtime/config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        import("package.tools.xmake").install(package, {
            vers = package:version_str(),
            relocatable = true,
            installprefix = package:installdir():gsub("\\", "/")
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ngettext", {includes = "libintl.h"}))
    end)
