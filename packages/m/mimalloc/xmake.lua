package("mimalloc")
    set_homepage("https://github.com/microsoft/mimalloc")
    set_description("mimalloc (pronounced 'me-malloc') is a general purpose allocator with excellent performance characteristics.")
    set_license("MIT")

    set_urls("https://github.com/microsoft/mimalloc/archive/refs/tags/$(version).zip",
             "https://github.com/microsoft/mimalloc.git")

    add_versions("v3.2.8", "63302742e911c8724c2bcc192aea51fc8921c7916ca8a68b037280d72126dfb5")
    add_versions("v3.1.5", "3cf724ec469198f23505d157893331f9d062e982c38b2c92a7fb789d7ddb67d9")
    add_versions("v3.0.3", "08a917e331164cd77052377f1e6d86de7febc8663dc117648319e662c0d4e6a4")

    add_versions("v2.2.4", "664667a48c9f101d979bbe4e41ee631da49d2024e30d66b7779b6ba4279af367")
    add_versions("v2.1.7", "fa61cf01e3dd869b35275bfd8be95bfde77f0b65dfa7e34012c09a66e1ea463f")
    add_versions("v2.1.2", "86281c918921c1007945a8a31e5ad6ae9af77e510abfec20d000dd05d15123c7")
    add_versions("v2.0.7", "ddb32937aabddedd0d3a57bf68158d4e53ecf9e051618df3331a67182b8b0508")
    add_versions("v2.0.6", "23e7443d0b4d7aa945779ea8a806e4e109c0ed62d740953d3656cddea7e04cf8")
    add_versions("v2.0.5", "e8d4e031123e82081325a5131ac57d954f5123b6a13653a6d984cbc3b8488bd9")
    add_versions("v2.0.3", "8e5f0b74fdafab09e8853415700a9ade4d62d5f56cd43f54adf02580ceda86c1")
    add_versions("v2.0.2", "6ccba822e251b8d10f8a63d5d7767bc0cbfae689756a4047cdf3d1e4a9fd33d0")
    add_versions("v2.0.1", "59c1fe79933e0ac9837a9ca4d954e4887dccd80a84281a6f849681b89a8b8876")

    add_versions("v1.8.7", "c37c099244f1096c40fca6ca9d2d456bb22efb99d64d34a26e39e3291a774ed9")
    add_versions("v1.7.7", "d51a5b8f3bc6800a0b2fc46830ce67b4d31b12f4e4550ff80cf394d5a88fead8")
    add_versions("v1.7.6", "bae56f8ebdcd43da83b52610d7f1c1602ea8d3798d906825defa5c40ad2eb560")
    add_versions("v1.7.3", "8319eca4a114dce5f897a4cb7d945bce22d915b4b262adb861cd7ac68fa3e848")
    add_versions("v1.7.2", "2c432e44803d9f4f017323be705f194db5d1452f9a60e38896605e7cfe8b332f")
    add_versions("v1.7.1", "dc3219066b4fd50c7f23d60c13fa15ae269a2b10b7dd45b046d5c52c9addb477")
    add_versions("v1.7.0", "13f3c82bca3a95233c5e29adb5675ab2b772f0ade23184d822079578c9d6c698")
    add_versions("v1.6.7", "5a12aac020650876615a2ce3dd8adc8b208cdcee4d9e6bcfc33b3fbe307f0dbf")

    add_configs("secure", {description = "Use a secured version of mimalloc", default = false, type = "boolean"})
    add_configs("rltgenrandom", {description = "Use a RtlGenRandom instead of BCrypt", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("etw", {description = "Enable Event tracing for Windows", default = false, type = "boolean"})
    end

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("advapi32", "bcrypt")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("atomic")
    end

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "MI_SHARED_LIB")
        end

        if package:is_plat("wasm") then
            package:add("ldflags", "-sMALLOC=emmalloc")
        end

        local configs = {
            "-DMI_OVERRIDE=OFF",
            "-DMI_BUILD_TESTS=OFF",
            "-DMI_BUILD_OBJECT=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMI_DEBUG_FULL=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DMI_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DMI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DMI_SECURE=" .. (package:config("secure") and "ON" or "OFF"))
        table.insert(configs, "-DMI_TRACK_ETW=" .. (package:config("etw") and "ON" or "OFF"))

        --x64:mimalloc-redirect.lib/dll x86:mimalloc-redirect32.lib/dll
        if package:version():le("2.0.1") and package:config("shared") and package:is_plat("windows") and package:is_arch("x86") then
            io.replace("CMakeLists.txt", "-redirect.", "-redirect32.", {plain = true})
        end
        if package:version():ge("2.2.4") and package:config("shared") and package:is_plat("windows", "mingw") and not package:is_arch64() then
            io.replace("CMakeLists.txt", "-redirect${MIMALLOC_REDIRECT_SUFFIX}", "-redirect32", {plain = true})
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

        if package:gitref() or package:version():ge("2.1.2") then
            table.insert(configs, "-DMI_INSTALL_TOPLEVEL=ON")
            import("package.tools.cmake").install(package, configs, {cxflags = cxflags})

            if package:is_plat("windows") and package:is_debug() then
                local dir = package:installdir(package:config("shared") and "bin" or "lib")
                os.cp(path.join(package:buildir(), "mimalloc-debug.pdb"), dir)
            end
        else
            import("package.tools.cmake").build(package, configs, {buildir = "build", cxflags = cxflags})

            if package:is_plat("windows") then
                os.trycp("build/**.dll", package:installdir("bin"))
                os.trycp("build/**.lib", package:installdir("lib"))
            elseif package:is_plat("mingw") then
                os.trycp("build/**.dll", package:installdir("bin"))
                os.trycp("build/**.a", package:installdir("lib"))
            elseif package:is_plat("macosx") then
                os.trycp("build/*.dylib", package:installdir("bin"))
                os.trycp("build/*.dylib", package:installdir("lib"))
                os.trycp("build/*.a", package:installdir("lib"))               
            else
                os.trycp("build/*.so", package:installdir("bin"))
                os.trycp("build/*.so", package:installdir("lib"))
                os.trycp("build/*.a", package:installdir("lib"))
            end
            os.cp("include", package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mi_malloc", {includes = "mimalloc.h"}))
    end)
