package("gtk+3")

    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

    on_fetch("linux", function (package, opt)
        if opt.system and package.find_package then
            return package:find_package("pkgconfig::gtk+-3.0")
        end
    end)

