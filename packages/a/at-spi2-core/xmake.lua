package("at-spi2-core")

    set_homepage("https://gitlab.gnome.org/GNOME/at-spi2-core")
    set_description("contains the DBus interface definitions for AT-SPI - the core of an accessibility stack for free software systems.")
    set_license("LGPL-2.1")

    add_urls("https://gitlab.gnome.org/GNOME/at-spi2-core/-/archive/AT_SPI2_CORE_$(version)/at-spi2-core-AT_SPI2_CORE_$(version).tar.gz", {alias = "archive", version = function (version)
        return version:gsub("%.", "_")
    end})

    add_urls("https://gitlab.gnome.org/GNOME/at-spi2-core/-/archive/$(version)/at-spi2-core-$(version).tar.gz", {alias = "archive_new"})

    add_versions("archive:2.53.90", "6b0a7c15b5fceb69f501e8b6b8bebe9896c35b9edb1ee08fe0b202d488a71363")

    add_versions("archive_new:2.55.90", "f99a1dc25a0556c9ec58b7049f8c76f002ee3f50f10aae677fc49ac6c143b2a2")

    add_includedirs("include", "include/at-spi-2.0", "include/atk-1.0", "include/at-spi2-atk/2.0")

    add_links("atk-bridge-2.0", "atspi", "atk-1.0")

    if is_plat("linux") then
        add_syslinks("dl", "resolv", "pthread")
    end

    add_deps("meson", "ninja", "pkg-config", "dbus", "libx11", "libxtst", "libxi", "libxml2", "glib")
    on_install("linux", function (package)
        io.replace("meson.build", "warning_level=1", "warning_level=3", {plain = true})
        io.replace("meson.build", "subdir('tests')", "", {plain = true})
        local configs = {"-Dintrospection=disabled", "-Ddocs=false"}

        os.cp("atk-adaptor/atk-bridge.h", package:installdir("include"))

        for _, header in ipairs({"atspi.h", "atspi-accessible.h", "atspi-action.h", "atspi-application.h", "atspi-collection.h", "atspi-component.h", "atspi-constants.h", "atspi-device.h", "atspi-device-a11y-manager.h", "atspi-device-legacy.h", "atspi-device-listener.h", "atspi-document.h", "atspi-editabletext.h", "atspi-event-listener.h", "atspi-gmain.h", "atspi-hyperlink.h", "atspi-hypertext.h", "atspi-image.h", "atspi-matchrule.h", "atspi-misc.h", "atspi-object.h", "atspi-registry.h", "atspi-relation.h", "atspi-selection.h", "atspi-stateset.h", "atspi-table.h", "atspi-table-cell.h", "atspi-text.h", "atspi-types.h", "atspi-value.h", "atspi-device-x11.h"}) do
            os.cp("atspi/" .. header, path.join(package:installdir("include"), "atspi", header))
        end

        for _, header in ipairs({"atkaction.h", "atkcomponent.h", "atkdocument.h", "atkeditabletext.h", "atkgobjectaccessible.h", "atkhyperlink.h", "atkhyperlinkimpl.h", "atkhypertext.h", "atkimage.h", "atkmisc.h", "atknoopobject.h", "atknoopobjectfactory.h", "atkobject.h", "atkobjectfactory.h", "atkplug.h", "atkrange.h", "atkregistry.h", "atkrelation.h", "atkrelationtype.h", "atkrelationset.h", "atkselection.h", "atksocket.h", "atkstate.h", "atkstateset.h", "atkstreamablecontent.h", "atktable.h", "atktablecell.h", "atktext.h", "atkutil.h", "atkvalue.h", "atkwindow.h", "atk-autocleanups.h", "atk.h"}) do
            os.cp("atk/" .. header, path.join(package:installdir("include"), "atk", header))
        end

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        try
        {
            -- try 代码块
            function ()
                import("package.tools.meson").install(package, configs, {packagedeps = {"glib", "libiconv", "libx11", "libxtst", "libxi", "dbus"}})
            end,
            -- catch 代码块
            catch
            {
                -- 发生异常后，被执行
                function (errors)
                    io.cat(path.join(package:buildir(), "meson-logs/meson-log.txt"))
                end
            }
        }
        local atspi_pkgconfig_dir = package:installdir("lib/pkgconfig/atspi-2.pc")
        io.replace(atspi_pkgconfig_dir, [[-DG_LOG_DOMAIN="dbind"]], [[-DG_LOG_DOMAIN=\"dbind\"]])
    end)

    on_test(function (package)
        assert(package:has_cfuncs("atk_bridge_adaptor_init", {includes = "atk-bridge.h"}))
        assert(package:has_cfuncs("atk_object_initialize", {includes = "atk/atk.h"}))
    end)
