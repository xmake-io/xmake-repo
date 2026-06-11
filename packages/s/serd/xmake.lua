package("serd")
    set_description("A lightweight C library for reading and writing RDF")
    set_license("ISC")

    add_urls("https://gitlab.com/drobilla/serd/-/archive/$(version).tar.gz",
             "https://gitlab.com/drobilla/serd.git")

    add_versions("v0.32.8", "43dabd7e9a56fedbc85d9e0607fcceeb0ca4ac2b7a3a9b44987e31f31e401612")

    add_deps("meson", "ninja")

    on_load(function (package)
        local version = package:version()
        local abi = version and (version:lt("1") and "0" or "1") or "0"

        package:add("includedirs",
            "include/serd-" .. abi)

        if not package:config("shared") then
            package:add("defines", "SERD_STATIC")
        end

        if abi == "1" then
            package:add("deps", "zix")
        end
    end)

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    else
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})
    end
    add_configs("tools", { description = "Build command line utilities", default = true, type = "boolean"})
    add_configs("bindings_cpp", {description = "Build C++ bindings", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {
            "-Ddocs=disabled",
            "-Dtests=disabled",
			"-Dman=disabled"
        }
        table.insert(configs, "-Dstatic=" .. (package:config("shared") and "false" or "true"))
        table.insert(configs, "-Dtools=" .. (package:config("tools") and "enabled" or "disabled"))

        local version = package:version()
        local abi = version and (version:lt("1") and "0" or "1") or "0"
        if abi == "1" then
            table.insert(configs, "-Dbindings_cpp=" .. (package:config("bindings_cpp") and "enabled" or "disabled"))
        end

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)		
        assert(package:has_cfuncs("serd_reader_new", {includes = "serd/serd.h"}))
    end)
