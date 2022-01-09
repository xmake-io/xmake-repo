package("iso-codes")
    set_homepage("https://salsa.debian.org/iso-codes-team/iso-codes")
    set_description("Provides lists of various ISO standards")
    set_license("LGPL-2.1-or-later")

    add_urls("https://deb.debian.org/debian/pool/main/i/iso-codes/iso-codes_$(version).orig.tar.xz")
    add_versions("4.8.0", "b02b9c8bb81dcfa03e4baa25b266df47710832cbf550081cf43f72dcedfc8768")

    add_deps("gettext", "python 3.x", "pkg-config")

    on_install("linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        local envs = {PKG_CONFIG_PATH = package:installdir("share/pkgconfig")}
        os.vrunv("pkg-config", {"--exists", "iso-codes"}, {envs = envs})
    end)
