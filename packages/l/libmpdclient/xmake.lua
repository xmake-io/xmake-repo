package("libmpdclient")
    set_homepage("https://musicpd.org/libs/libmpdclient/")
    set_description("A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.")
    add_urls("https://musicpd.org/download/libmpdclient/2/libmpdclient-$(version).tar.xz")
    add_versions("2.19", "158aad4c2278ab08e76a3f2b0166c99b39fae00ee17231bd225c5a36e977a189")
    add_deps("meson", "ninja")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
        os.cp("include", package:installdir())
        os.cp("build_*/version.h", package:installdir() .. "/include/mpd")
        os.rm(package:installdir() .. "/include/mpd/version.h.in")
        if package:is_plat("linux") and package:is_arch("x86_64") then
            if os.isdir(path.join(package:installdir(), "lib", "x86_64-linux-gnu")) then
                package:add("linkdirs", "lib/x86_64-linux-gnu")
            elseif os.isdir(path.join(package:installdir(), "lib64")) then
                package:add("linkdirs", "lib64")
            end
            package:add("links", "mpdclient")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpd_connection_new", {includes = "mpd/connection.h"}))
    end)
