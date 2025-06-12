package("breeze-js")
    set_description("A lightweight and modern JavaScript runtime built on QuickJS for desktop applications.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/breeze-shell/breeze-js.git")

    add_versions("latest", "ad906133ef4a940bed72909ddc2da9314c1c8846") -- use master temporarily to make fixing issues easier

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("windows", function (package)
        import("package.tools.xmake").install(package, {}, {target = "breeze-js-runtime"})
    end)
