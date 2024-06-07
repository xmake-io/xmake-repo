package("libepoxy")

    set_homepage("https://download.gnome.org/sources/libepoxy/")
    set_description("Epoxy is a library for handling OpenGL function pointer management for you.")
    set_license("MIT")

    add_urls("https://download.gnome.org/sources/libepoxy/$(version).tar.xz", {version = function (version)
        return format("%d.%d/libepoxy-%s", version:major(), version:minor(), version)
    end})
    add_versions("1.5.9", "d168a19a6edfdd9977fef1308ccf516079856a4275cf876de688fb7927e365e4")
    add_versions("1.5.10", "072cda4b59dd098bba8c2363a6247299db1fa89411dc221c8b81b8ee8192e623")

    if is_plat("linux") then
        add_extsources("apt::libepoxy-dev")
        add_deps("libx11", "pkg-config")
    end

    add_deps("meson", "ninja")
    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            io.replace("include/epoxy/common.h", "__declspec(dllimport)", "", {plain = true})
        end
        local configs = {"-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("epoxy_gl_version", {includes = "epoxy/gl.h"}))
    end)
