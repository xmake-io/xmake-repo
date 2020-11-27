package("wayland")

    set_homepage("https://wayland.freedesktop.org/")
    set_description("Wayland is a protocol for a compositor to talk to its clients as well as a C library implementation of that protocol.")
    set_license("MIT")

    add_urls("https://wayland.freedesktop.org/releases/wayland-$(version).tar.xz")
    add_versions("1.18.0", "4675a79f091020817a98fd0484e7208c8762242266967f55a67776936c2e294d")

    add_resources("1.x", "protocols", "https://wayland.freedesktop.org/releases/wayland-protocols-1.20.tar.xz", "9782b7a1a863d82d7c92478497d13c758f52e7da4f197aa16443f73de77e4de7")

    add_deps("meson", "libxml2", "libffi", "expat")
    on_install("linux", function (package)

        -- imports
        import("package.tools.meson")
        import("package.tools.autoconf")
        import("lib.detect.find_file")

        -- set environment variables
        package:addenv("PATH", "bin")
        local LD_LIBRARY_PATH = package:installdir("lib")
        local PKG_CONFIG_PATH = path.joinenv({package:installdir("lib", "pkgconfig"), package:installdir("share", "pkgconfig")})
        local ACLOCAL_PATH = package:installdir("share", "aclocal")
        local ACLOCAL = "aclocal -I " .. package:installdir("share", "aclocal")
        os.mkdir(package:installdir("share", "aclocal"))

        -- build wayland
        local configs = {"-Ddocumentation=false", "-Dc_link_args=-lm"}
        local envs = meson.buildenvs(package)
        envs.LD_LIBRARY_PATH = path.joinenv(table.join(LD_LIBRARY_PATH, envs.LD_LIBRARY_PATH))
        envs.PKG_CONFIG_PATH = path.joinenv(table.join(PKG_CONFIG_PATH, envs.PKG_CONFIG_PATH))
        envs.ACLOCAL_PATH    = path.joinenv(table.join(ACLOCAL_PATH, envs.ACLOCAL_PATH))
        envs.ACLOCAL         = ACLOCAL
        meson.install(package, configs, {envs = envs})

        -- add links
        local arch = package:is_arch("x86_64", "x64") and "x86_64" or "x86"
        package:add("linkdirs", path.join("lib", arch .. "-linux-gnu"))
        package:add("links", "wayland-client", "wayland-server", "wayland-cursor", "wayland-egl")
        os.mv(package:installdir("lib", arch .. "-linux-gnu", "pkgconfig"), package:installdir("lib"))

        -- install wayland-protocols
        local protocol = assert(package:resourcedir("protocols"), "wayland-protocols not found!")
        local configfile = find_file("configure.ac", path.join(protocol, "**"))
        os.cd(path.directory(configfile))

        envs = autoconf.buildenvs(package)
        envs.LD_LIBRARY_PATH = path.joinenv(table.join(LD_LIBRARY_PATH, envs.LD_LIBRARY_PATH))
        envs.PKG_CONFIG_PATH = path.joinenv(table.join(PKG_CONFIG_PATH, envs.PKG_CONFIG_PATH))
        envs.ACLOCAL_PATH    = path.joinenv(table.join(ACLOCAL_PATH, envs.ACLOCAL_PATH))
        envs.ACLOCAL         = ACLOCAL
        autoconf.install(package, {}, {envs = envs})
    end)

    on_test(function (package)
        os.vrun("wayland-scanner --version")
        assert(package:has_cfuncs("wl_list_init", {includes = "wayland-util.h"}))
    end)
