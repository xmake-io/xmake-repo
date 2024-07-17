package("gtk+3")

    set_homepage("https://gtk.org/")
    set_description("Toolkit for creating graphical user interfaces")
    set_license("LGPL-2.0-or-later")

     add_urls("https://gitlab.gnome.org/GNOME/gtk/-/archive/gtk-3-24/gtk-gtk-3-24.zip",
             "https://gitlab.gnome.org/GNOME/gtk.git")

    add_versions("v0.1.2", "648f7e5e2252d0db4e9432d493cec0682c059605ae3dfded793884cbbf3d1bd5")

    on_fetch("linux", function (package, opt)
        if opt.system and package.find_package then
            return package:find_package("pkgconfig::gtk+-3.0")
        end
    end)

