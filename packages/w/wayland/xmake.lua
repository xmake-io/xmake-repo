package("wayland")
    set_homepage("https://wayland.freedesktop.org/")
    set_description("Wayland is a protocol for a compositor to talk to its clients as well as a C library implementation of that protocol.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/wayland/wayland/-/releases/$(version)/downloads/wayland-$(version).tar.xz")
    add_versions("1.18.0", "4675a79f091020817a98fd0484e7208c8762242266967f55a67776936c2e294d")
    add_versions("1.19.0", "baccd902300d354581cd5ad3cc49daa4921d55fb416a5883e218750fef166d15")
    add_versions("1.23.0", "05b3e1574d3e67626b5974f862f36b5b427c7ceeb965cb36a4e6c2d342e45ab2")

    add_resources("1.18.0", "protocols", "https://wayland.freedesktop.org/releases/wayland-protocols-1.20.tar.xz", "9782b7a1a863d82d7c92478497d13c758f52e7da4f197aa16443f73de77e4de7")
    add_resources("1.19.0", "protocols", "https://wayland.freedesktop.org/releases/wayland-protocols-1.21.tar.xz", "b99945842d8be18817c26ee77dafa157883af89268e15f4a5a1a1ff3ffa4cde5")
    add_resources("1.23.0", "protocols", "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.36/downloads/wayland-protocols-1.36.tar.xz", "71fd4de05e79f9a1ca559fac30c1f8365fa10346422f9fe795f74d77b9ef7e92")

    if is_plat("linux") then
        add_extsources("apt::libwayland-dev", "pacman::wayland")
    end

    add_deps("meson", "ninja >=1.8.2", "libxml2", "libffi", "expat", "bison", "pkg-config")

    if is_plat("bsd") then
        add_deps("epoll-shim")
    end

    on_install("linux", "bsd", function (package)
        -- imports
        import("package.tools.meson")
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
        table.insert(configs, "--libdir=lib")
        local envs = meson.buildenvs(package)
        envs.LD_LIBRARY_PATH = path.joinenv(table.join(LD_LIBRARY_PATH, envs.LD_LIBRARY_PATH))
        envs.PKG_CONFIG_PATH = path.joinenv(table.join(PKG_CONFIG_PATH, envs.PKG_CONFIG_PATH))
        envs.ACLOCAL_PATH    = path.joinenv(table.join(ACLOCAL_PATH, envs.ACLOCAL_PATH))
        envs.ACLOCAL         = ACLOCAL
        meson.install(package, configs, {envs = envs})

        -- install wayland-protocols
        local protocol = assert(package:resourcedir("protocols"), "wayland-protocols not found!")
        local buildfile = find_file("meson.build", path.join(protocol, "*"))
        if buildfile then
            os.cd(path.directory(buildfile))
            meson.install(package, {"-Dtests=false"}, {envs = envs})
        else
            import("package.tools.autoconf")
            
            local configfile = assert(find_file("configure.ac", path.join(protocol, "**")))
            os.cd(path.directory(configfile))

            envs = autoconf.buildenvs(package)
            envs.LD_LIBRARY_PATH = path.joinenv(table.join(LD_LIBRARY_PATH, envs.LD_LIBRARY_PATH))
            envs.PKG_CONFIG_PATH = path.joinenv(table.join(PKG_CONFIG_PATH, envs.PKG_CONFIG_PATH))
            envs.ACLOCAL_PATH    = path.joinenv(table.join(ACLOCAL_PATH, envs.ACLOCAL_PATH))
            envs.ACLOCAL         = ACLOCAL
            autoconf.install(package, {}, {envs = envs})
        end
    end)

    on_test(function (package)
        os.vrun("wayland-scanner --version")
        assert(package:has_cfuncs("wl_list_init", {includes = "wayland-util.h"}))
    end)
