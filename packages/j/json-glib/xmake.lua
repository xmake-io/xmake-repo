package("json-glib")

    set_homepage("https://gitlab.gnome.org/GNOME/json-glib")
    set_description("JSON-GLib implements a full suite of JSON-related tools using GLib and GObject.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/GNOME/json-glib/archive/refs/tags/$(version).tar.gz")
    add_versions("1.10.8", "7a114bdac0b2611a7207e981c37fa9b1e70d9cb642470cd9e967b135428cec52")
    add_versions("1.10.6", "d23cbd4094a32cc05cf22cd87a83da1f799e182e286133b49fde3c9241a32006")
    add_versions("1.10.0", "447890f9de2a04c312871768208f6c8aeec4069392af7605bc77e61165dcb374")
    add_versions("1.9.2", "277c3b7fc98712e30115ee3a60c3eac8acc34570cb98d3ff78de85ed804e0c80")

    add_patches("1.9.2", "patches/1.9.2/add_brace_to_json_scanner.patch", "5d77c14d25ad24a911d28d51e9defee9a3c382428dc3e23101f6319fc46b227c")
    add_deps("glib", "meson", "ninja")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    add_includedirs("include", "include/json-glib-1.0")

    on_install("linux", function (package)
        local configs = {"-Ddocumentation=disabled", "-Dtests=false", "-Dgtk_doc=disabled", "-Dman=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libiconv"}})
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                JsonParser *parser = json_parser_new ();
            }
        ]]}, {includes = "json-glib/json-glib.h"}))
    end)
