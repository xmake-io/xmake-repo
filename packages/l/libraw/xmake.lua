package("libraw")
    set_homepage("http://www.libraw.org")
    set_description("LibRaw is a library for reading RAW files from digital cameras.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/LibRaw/LibRaw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LibRaw/LibRaw.git")

    add_versions("0.22.0", "5a11327a9cef2496d6a4335e8da30a1604460b6c545a30fe7588cf4c00a0fcae")
    add_versions("0.21.5", "4b7f183a68f6e46e579e80ba32ab121687e75bd30a2e5566f34c36a6bcba1679")
    add_versions("0.21.4", "8baeb5253c746441fadad62e9c5c43ff4e414e41b0c45d6dcabccb542b2dff4b")
    add_versions("0.20.2", "dc1b486c2003435733043e4e05273477326e51c3ea554c6864a4eafaff1004a6")
    add_versions("0.19.5", "9a2a40418e4fb0ab908f6d384ff6f9075f4431f8e3d79a0e44e5a6ea9e75abdc")

    add_configs("thread_safe", {description = "Build raw_r library with -pthread enabled", default = false, type = "boolean"})
    add_configs("libjpeg", {description = "Build with libjpeg.", default = false, type = "boolean"})
    add_configs("lcms", {description = "Build with LCMS.", default = false, type = "boolean"})
    add_configs("jasper", {description = "Build with Jasper.", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    if on_check then
        on_check("android", function (package)
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            if package:is_arch("armeabi-v7a") then
                assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(libraw) require ndk version >= 24")
            end
        end)
    end

    on_load(function (package)
        if package:config("libjpeg") then
            package:add("deps", "libjpeg")
            package:add("defines", "USE_JPEG", "USE_JPEG8")
        end
        if package:config("lcms") then
            package:add("deps", "lcms")
            package:add("defines", "USE_LCMS2")
        end
        if package:config("jasper") then
            package:add("deps", "jasper")
            package:add("defines", "USE_JASPER")
        end

        if package:is_plat("windows") then
            package:add("defines", "WIN32")
        end
        if not package:config("shared") then
            package:add("defines", "LIBRAW_NODLL")
        end
    end)

    on_install(function(package)
        local configs = {}
        configs.ver = package:version_str()
        for _, config in ipairs({"thread_safe", "libjpeg", "lcms", "jasper"}) do
            configs[config] = package:config(config)
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("libraw_version", {includes = "libraw/libraw.h"}))
    end)
