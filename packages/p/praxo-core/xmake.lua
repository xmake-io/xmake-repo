package("praxo-core")
    set_homepage("https://github.com/axisvela/praxo-core")
    set_description("Embeddable C agent runtime with policy, tools, streaming, and plugin hosts")
    set_license("MIT")

    add_urls("https://github.com/axisvela/praxo-core/archive/refs/tags/c/v$(version).tar.gz")
    add_versions("0.13.0", "ec14a35a635da7569ccc3d3a986cfbcd93d210c2a8e1c74f078654b18c92b136")

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
        if package:is_plat("mingw") then
            -- Older MinGW runtimes may not provide the C11 timespec_get API.
            io.replace("src/harmovela.c", [[    struct timespec now;
    if (timespec_get(&now, TIME_UTC) != TIME_UTC) {
        return (long long)time(NULL) * 1000000000LL;
    }
    return (long long)now.tv_sec * 1000000000LL + (long long)now.tv_nsec;]], [[#if defined(TIME_UTC)
    struct timespec now;
    if (timespec_get(&now, TIME_UTC) != TIME_UTC) {
        return (long long)time(NULL) * 1000000000LL;
    }
    return (long long)now.tv_sec * 1000000000LL + (long long)now.tv_nsec;
#else
    return (long long)time(NULL) * 1000000000LL;
#endif]], {plain = true})
        end
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("px_plugin_process_start_simple", {includes = "praxo_plugin_process.h"}))
    end)
