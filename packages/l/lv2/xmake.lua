package("lv2")
    set_kind("library", {headeronly = true})
    set_homepage("https://lv2plug.in")
    set_description("The LV2 audio plugin specification")
    set_license("0BSD", "Apache-2.0", "CC-BY-1.0", "CC-BY-4.0", "ISC", "MIT", "W3C-19980720", "W3C-20150513")

    add_urls("https://gitlab.com/lv2/lv2/-/archive/$(version).tar.gz",
             "https://gitlab.com/lv2/lv2.git")

    add_versions("v1.18.10", "15038fabd0313f281a5611f41502e3649274082b74c879bcc4a4bc5a2e79e85b")

    add_deps("meson", "ninja")
	
    add_configs("old_headers", { description = "Install backwards compatible headers at URI-style paths", default = true, type = "boolean"})

    on_install(function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dplugins=disabled",
            "-Dtests=disabled",
        }
		table.insert(configs, "-Dold_headers=" .. (package:config("old_headers") and "true" or "false"))
		import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)		
        assert(package:has_cincludes("lv2/core/lv2.h"))
    end)