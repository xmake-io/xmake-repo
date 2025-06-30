package("libuvc")
    set_homepage("https://github.com/libuvc/libuvc")
    set_description("A cross-platform video device oynchronous I/O.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libuvc/libuvc.git")
    add_versions("2024.03.05", "047920bcdfb1dac42424c90de5cc77dfc9fba04d")

    if is_plat("macosx") then
        add_extsources("brew::libuvc")
    elseif is_plat("linux") then
        add_extsources("apt::libuvc-dev", "pacman::libuvc")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libuvc")
    end

    add_configs("jpeg", {description = "Enable jpeg support.", default = true, type = "boolean"})
    add_configs("winsock2", {description = "Use winsock2.h or winsock.h in windows.", default = true, type = "boolean"})

    add_deps("cmake", "pkgconf")
    add_deps("libusb")

    if is_plat("windows") then
        add_patches("2024.03.05", "patches/2024.03.05/windows.patch", "1a3356ad2a37ac68bd29ea61457de85210740643843f57e030b20fd70efc9597")
        add_deps("pthreads4w")
    else
        add_patches("2024.03.05", "patches/2024.03.05/linux.patch", "6a17c1eb271a6db1a2fd17aa2003159f60b85f02a3443ee5b600472f94786bda")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit", "Security")
    end

    on_load(function (package)
        if package:config("jpeg") then
            package:add("deps", "libjpeg")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", function (package)
        if package:is_plat("windows") and not package:config("winsock2") then
            io.replace("include/libuvc/libuvc.h", "winsock2.h", "winsock.h", {plain = true})
        end
        local configs = {}
        table.insert(configs, "-DBUILD_EXAMPLE=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DCMAKE_BUILD_TARGET=" .. (package:config("shared") and "Shared" or "Static"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uvc_init", {includes = "libuvc/libuvc.h"}))
    end)
