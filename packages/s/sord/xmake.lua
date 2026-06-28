package("sord")
    set_description("Lightweight C library for storing RDF statements in memory.")
    set_license("ISC")

    add_urls("https://gitlab.com/drobilla/sord/-/archive/v$(version)/sord-v$(version).tar.gz",
             "https://gitlab.com/drobilla/sord.git")

    add_versions("0.16.22", "040fb3f369dd49a7717eb28ca0a66766352e25e760729903fc8a01e117122901")

    add_deps("meson", "ninja", "zix", "serd")

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

    add_configs("tools", { description = "Build command line utilities", default = false, type = "boolean"})
    add_configs("bindings_cpp", { description = "Build C++ bindings", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("tools") then
            package:add("deps", "pcre2")
        end

        if not package:config("shared") then
            package:add("defines", "SERD_STATIC")
        end

        package:add("includedirs", "include/sord-0")
    end)

    on_install(function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dman=disabled",
            "-Dtests=disabled",
        }
        table.insert(configs, "-Dbindings_cpp=" .. (package:config("bindings_cpp") and "enabled" or "disabled"))
        table.insert(configs, "-Dtools=" .. (package:config("tools") and "enabled" or "disabled"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sord_new", {includes = "sord/sord.h"}))
    end)