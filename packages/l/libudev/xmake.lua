package("libudev")

    set_homepage("https://www.freedesktop.org/wiki/Software/systemd/")
    set_description("API for enumerating and introspecting local devices")

    on_fetch("linux", function (package, opt)
        if opt.system then
            return package:find_package("pkgconfig::libudev") or package:find_package("system::udev")
        end
    end)

    add_extsources("apt::libudev-dev", "pacman::systemd")
