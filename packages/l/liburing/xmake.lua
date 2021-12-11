package("liburing")

    set_homepage("https://github.com/axboe/liburing")
    set_description("liburing provides helpers to setup and teardown io_uring instances")

    add_urls("https://github.com/axboe/liburing/archive/refs/tags/liburing-$(version).tar.gz",
             "https://github.com/axboe/liburing.git")
    add_versions("2.1", "f1e0500cb3934b0b61c5020c3999a973c9c93b618faff1eba75aadc95bb03e07")

    -- liburing doesn't support building as a shared lib
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install("linux", function (package)
        local configs = {}
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("io_uring_submit", {includes = "liburing.h"}))
    end)
