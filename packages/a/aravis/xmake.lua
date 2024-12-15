package("aravis")
    set_homepage("https://github.com/AravisProject/aravis")
    set_description("A vision library for genicam based cameras")
    set_license("LGPL-2.1")

    add_urls("https://github.com/AravisProject/aravis.git")
    add_urls("https://github.com/AravisProject/aravis/releases/download/$(version)/aravis-$(version).tar.xz", {alias = "release"})
    add_urls("https://github.com/AravisProject/aravis/archive/refs/tags/$(version).tar.gz", {alias = "github"})

    add_versions("release:0.8.33", "3c4409a12ea70bba4de25e5b08c777112de854bc801896594f2cb6f8c2bd6fbc")

    add_versions("github:0.8.33", "d70b125666b23ca4c0f8986fa0786a3d2b9efb7a56b558b703083cdfaa793f4e")

    add_configs("gst_plugin", {description = "Build GStreamer plugin", default = false, type = "boolean"})
    add_configs("usb", {description = "Enable USB support", default = false, type = "boolean"})
    add_configs("packet_socket", {description = "Enable packet socket support", default = false, type = "boolean"})
    add_configs("introspection", {description = "Enable packet socket support", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("ws2_32", "iphlpapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "pthread", "m", "resolv")
    end

    add_deps("meson", "ninja")
    if is_plat("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("glib", "libxml2", "zlib")

    on_load(function (package)
        if package:config("gst_plugin") then
            package:add("deps", "gstreamer")
        end
        if package:config("usb") then
            package:add("deps", "libusb")
        end

        local version = package:version()
        assert(version, "require version to set includedirs")
        package:add("includedirs", "include", format("include/aravis-%d.%d", version:major(), version:minor()))
    end)

    on_install("windows|native", "macosx|native", "linux|native", function (package)
        -- patch xrepo package name to find .pc
        local libusb = package:dep("libusb")
        if libusb and not libusb:is_system() then
            io.replace("meson.build", "libusb-1.0", "libusb", {plain = true})
        end

        local configs = {"-Dviewer=disabled", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dgst-plugin=" .. (package:config("gst_plugin") and "enabled" or "disabled"))
        table.insert(configs, "-Dusb=" .. (package:config("usb") and "enabled" or "disabled"))
        table.insert(configs, "-Dpacket-socket=" .. (package:config("packet_socket") and "enabled" or "disabled"))
        table.insert(configs, "-Dintrospection=" .. (package:config("introspection") and "enabled" or "disabled"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("arv_get_n_interfaces", {includes = "arv.h"}))
    end)
