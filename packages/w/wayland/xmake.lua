package("wayland")
    set_homepage("https://wayland.freedesktop.org/")
    set_description("Wayland is a protocol for a compositor to talk to its clients as well as a C library implementation of that protocol.")
    set_license("MIT")

    add_urls("https://fossies.org/linux/misc/wayland-$(version).tar.xz",
             "https://gitlab.freedesktop.org/wayland/wayland/-/releases/$(version)/downloads/wayland-$(version).tar.xz")
    add_versions("1.18.0", "4675a79f091020817a98fd0484e7208c8762242266967f55a67776936c2e294d")
    add_versions("1.19.0", "baccd902300d354581cd5ad3cc49daa4921d55fb416a5883e218750fef166d15")
    add_versions("1.23.0", "05b3e1574d3e67626b5974f862f36b5b427c7ceeb965cb36a4e6c2d342e45ab2")
    add_versions("1.23.1", "864fb2a8399e2d0ec39d56e9d9b753c093775beadc6022ce81f441929a81e5ed")
    add_versions("1.24.0", "82892487a01ad67b334eca83b54317a7c86a03a89cfadacfef5211f11a5d0536")

    if is_plat("linux") then
        add_extsources("apt::libwayland-dev", "pacman::wayland")
    end

    add_deps("meson", "ninja >=1.8.2", "libxml2", "libffi", "expat", "bison", "pkg-config")

    if is_plat("bsd") then
        add_deps("epoll-shim")
    end

    on_install("linux|native", "bsd", function (package)
        import("package.tools.meson")

        -- set environment variables
        package:addenv("PATH", "bin")
        local LD_LIBRARY_PATH = package:installdir("lib")
        local PKG_CONFIG_PATH = path.joinenv({package:installdir("lib", "pkgconfig"), package:installdir("share", "pkgconfig")})
        local ACLOCAL_PATH = package:installdir("share", "aclocal")
        local ACLOCAL = "aclocal -I " .. package:installdir("share", "aclocal")
        os.mkdir(package:installdir("share", "aclocal"))

        -- build wayland
        local configs = {"-Ddtd_validation=false", "-Ddocumentation=false", "-Dtests=false", "-Dc_link_args=-lm"}
        table.insert(configs, "-Dscanner=" .. (package:is_cross() and "false" or "true"))
        table.insert(configs, "--libdir=lib")
        local envs = meson.buildenvs(package)
        envs.LD_LIBRARY_PATH = path.joinenv(table.join(LD_LIBRARY_PATH, envs.LD_LIBRARY_PATH))
        envs.PKG_CONFIG_PATH = path.joinenv(table.join(PKG_CONFIG_PATH, envs.PKG_CONFIG_PATH))
        envs.ACLOCAL_PATH    = path.joinenv(table.join(ACLOCAL_PATH, envs.ACLOCAL_PATH))
        envs.ACLOCAL         = ACLOCAL
        meson.install(package, configs, {envs = envs})
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("wayland-scanner --version")
        end
        assert(package:has_cfuncs("wl_list_init", {includes = "wayland-util.h"}))
    end)
