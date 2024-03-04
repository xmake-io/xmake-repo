package("gspell")

    set_homepage("https://gitlab.gnome.org/GNOME/gspell")
    set_description("A spell-checking library for GTK applications")
    set_license("LGPL-2.0-or-later")

    on_fetch("linux", function (package, opt)
        if opt.system and package.find_package then
            return package:find_package("pkgconfig::gspell")
        end
    end)

