package("mmloader")
    set_homepage("http://tishion.github.io/mmLoader/")
    set_description("A library for loading dll module bypassing windows PE loader from memory (x86/x64)")
    set_license("MIT")

    add_urls("https://github.com/tishion/mmLoader.git")

    add_versions("2024.03.20", "ab1811869b987fb8c35d6d0fb695c50bf84c4df4")

    add_configs("shellcode", {description = "Generate the shellcode header files", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            import("core.base.semver")

            local vs_sdkver = package:toolchain("msvc"):config("vs_sdkver")
            assert(vs_sdkver and not semver.match(vs_sdkver):eq("10.0.19041"), "package(mmloader) require vs_sdkver != 10.0.19041.0")
        end)
    end

    on_install("windows|x64", "windows|x86", function (package)
        local configs = {"-DBUILD_MMLOADER_DEMO=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHELLCODE_GEN=" .. (package:config("shellcode") and "ON" or "OFF"))
        if package:is_arch("x86") then
            table.insert(configs, "-DCMAKE_VS_PLATFORM_NAME=Win32")
        elseif package:is_arch("x64") then
            table.insert(configs, "-DCMAKE_VS_PLATFORM_NAME=x64")
        end

        local opt = {}
        if package:is_debug() then
            opt.cxflags = "-D_DEBUG"
            os.mkdir(path.join(package:buildir(), "tools/shellcode-generator/pdb"))
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_debug() then
            os.vcp("output/**.pdb", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("LoadMemModule", {includes = "mmLoader/mmLoader.h"}))
    end)
