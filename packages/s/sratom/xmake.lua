package("sratom")
    set_description("Library for serialising LV2 atoms.")
    set_license("ISC")

    add_urls("https://gitlab.com/lv2/sratom/-/archive/v$(version)/sratom-v$(version).tar.gz",
             "https://gitlab.com/lv2/sratom.git")

    add_versions("0.6.22", "4a88bde345370584b279895c2cb8f7f8341d2b31b6ca50e128faea02f02d3e76")

    add_deps("meson", "ninja", "zix", "lv2", "serd", "sord")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    else
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    end

    if is_subhost("windows") then
        add_deps("pkgconf", {host = true})
    else
        add_deps("pkg-config", {host = true})
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SRATOM_STATIC")
        end

        package:add("includedirs", "include/sratom-0")
    end)

    on_install(function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dtests=disabled",
        }
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sratom_new", {includes = "sratom/sratom.h"}))
    end)