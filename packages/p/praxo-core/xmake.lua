package("praxo-core")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("Embeddable C agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core/archive/refs/tags/c/v$(version).tar.gz")
    add_versions("0.13.0", "ec14a35a635da7569ccc3d3a986cfbcd93d210c2a8e1c74f078654b18c92b136")
    add_patches("0.13.0", "patches/0.13.0/mingw-time.patch", "a568b06946594effec7dca08f440ecdf09a2b788ddc9c79f95a05cc3b45ffe6a")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_links("praxo_core")

    if not is_plat("windows", "mingw") then
        add_syslinks("m")
    end

    if on_check then
        on_check("android", function (package)
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(praxo-core): requires Android API level >= 28 for posix_spawn")
        end)
    end

    on_install(function (package)
        os.cd("language/c")
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("px_plugin_process_start_simple", {includes = "praxo_plugin_process.h"}))
    end)
