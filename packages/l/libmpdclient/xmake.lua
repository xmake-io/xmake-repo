package("libmpdclient")
    set_homepage("https://musicpd.org/libs/libmpdclient/")
    set_description("A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.")
    add_urls("https://musicpd.org/download/libmpdclient/2/libmpdclient-$(version).tar.xz")
    add_versions("2.19", "158aad4c2278ab08e76a3f2b0166c99b39fae00ee17231bd225c5a36e977a189")
    if is_plat("mingw") then
        add_deps("meson:0.50.1", "ninja")
    else
        add_deps("meson", "ninja")
    end

    on_install("linux", "mingw", function (package)
        import("package.tools.meson").install(package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpd_connection_new", {includes = "mpd/connection.h"}))
    end)
