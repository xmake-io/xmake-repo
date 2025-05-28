package("libuvc")
    set_homepage("https://github.com/libuvc/libuvc")
    set_description("A cross-platform video device oynchronous I/O.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libuvc/libuvc.git")
    add_versions("2024.03.05", "047920bcdfb1dac42424c90de5cc77dfc9fba04d")

    add_configs("jpeg", {description = "Enable jpeg support.", default = true, type = "boolean"})

    add_deps("libusb")

    if is_plat("windows") then
        add_patches("v0.0.7", "patches/v0.0.7/windows.patch", "87eae0b3bbc07038654a5ef7f5f7d0213472436e517f9b65963353738bb0a3dc")
        add_deps("pkgconf", "pthreads4w")
    end

    on_load(function (package)
        if package:config("jpeg") then
            package:add("deps", "libjpeg")
        end
    end)

    on_install("windows", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_EXAMPLE=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DCMAKE_BUILD_TARGET=" .. (package:config("shared") and "Shared" or "Static"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uvc_init", {includes = "libuvc/libuvc.h"}))
    end)
