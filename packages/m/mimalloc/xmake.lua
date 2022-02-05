package("mimalloc")

    set_homepage("https://github.com/microsoft/mimalloc")
    set_description("mimalloc (pronounced 'me-malloc') is a general purpose allocator with excellent performance characteristics.")
    set_license("MIT")

    set_urls("https://github.com/microsoft/mimalloc/archive/v$(version).zip")
    add_versions("2.0.3", "8e5f0b74fdafab09e8853415700a9ade4d62d5f56cd43f54adf02580ceda86c1")
    add_versions("2.0.2", "6ccba822e251b8d10f8a63d5d7767bc0cbfae689756a4047cdf3d1e4a9fd33d0")
    add_versions("2.0.1", "59c1fe79933e0ac9837a9ca4d954e4887dccd80a84281a6f849681b89a8b8876")
    add_versions("1.7.3", "8319eca4a114dce5f897a4cb7d945bce22d915b4b262adb861cd7ac68fa3e848")
    add_versions("1.7.2", "2c432e44803d9f4f017323be705f194db5d1452f9a60e38896605e7cfe8b332f")
    add_versions("1.7.1", "dc3219066b4fd50c7f23d60c13fa15ae269a2b10b7dd45b046d5c52c9addb477")
    add_versions("1.7.0", "13f3c82bca3a95233c5e29adb5675ab2b772f0ade23184d822079578c9d6c698")
    add_versions("1.6.7", "5a12aac020650876615a2ce3dd8adc8b208cdcee4d9e6bcfc33b3fbe307f0dbf")

    add_configs("secure", {description = "Use a secured version of mimalloc", default = false, type = "boolean"})
    add_configs("rltgenrandom", {description = "Use a RtlGenRandom instead of BCrypt", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("advapi32", "bcrypt")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("atomic")
    end

    on_install("macosx", "windows", "linux", "android", function (package)
        local configs = {"-DMI_OVERRIDE=OFF"}
        table.insert(configs, "-DMI_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DMI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMI_SECURE=" .. (package:config("secure") and "ON" or "OFF"))
        table.insert(configs, "-DMI_BUILD_TESTS=OFF")
        table.insert(configs, "-DMI_BUILD_OBJECT=OFF")
        --x64:mimalloc-redirect.lib/dll x86:mimalloc-redirect32.lib/dll
        if package:version():le("2.0.1") and package:config("shared") and package:is_plat("windows") and package:is_arch("x86") then
            io.replace("CMakeLists.txt", "-redirect.", "-redirect32.", {plain = true})
        end
        local cxflags
        if package:config("rltgenrandom") then
            if xmake:version():ge("2.5.1") then
                cxflags = "-DMI_USE_RTLGENRANDOM"
            else
                -- it will be deprecated after xmake/v2.5.1
                package:configs().cxflags = "-DMI_USE_RTLGENRANDOM"
            end
        end
        import("package.tools.cmake").build(package, configs, {buildir = "build", cxflags = cxflags})

        if package:is_plat("windows") then
            os.trycp("build/**.dll", package:installdir("bin"))
            os.trycp("build/**.lib", package:installdir("lib"))
        else
            os.trycp("build/*.so", package:installdir("lib"))
            os.trycp("build/*.a", package:installdir("lib"))
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mi_malloc", {includes = "mimalloc.h"}))
    end)
