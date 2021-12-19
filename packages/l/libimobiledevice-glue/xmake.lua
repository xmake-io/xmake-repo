package("libimobiledevice-glue")

    set_homepage("https://github.com/libimobiledevice/libimobiledevice-glue")
    set_description("A library with common code used by libraries and tools around the libimobiledevice project")

    add_urls("https://github.com/libimobiledevice/libimobiledevice-glue.git")
    add_versions("2021.11.24", "106cea58ae2d92fc755705a79e1753b3750edd15")

    add_deps("libplist")
    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-debug=" .. (package:config("debug") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("socket_connect", {includes = "libimobiledevice-glue/socket.h"}))
    end)
