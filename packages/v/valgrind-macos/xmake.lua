package("valgrind-macos")
    set_homepage("https://github.com/LouisBrunner/valgrind-macos")
    set_description("A valgrind mirror with latest macOS support")
    set_license("GPL-3.0")

    add_urls("https://github.com/LouisBrunner/valgrind-macos.git")
    add_versions("2026.09.09", "7877928dcc8bfb873325e4f51949f930d77e493e")
    add_patches("2026.09.09", "patches/2026.09.09/disable-tests.patch", "82e122b36d3cbbfff19491d72424b6b1e21147f3eb3d276e11572d82757db141")
    add_patches("2026.09.09", "patches/2026.09.09/arm64-linux.patch", "77693cf0900cb96ce4cfd17bd0a6d6ff5995b09928d5e15919ae45b05b4f5e85")
    add_patches("2026.09.09", "patches/2026.09.09/darwin-libc.patch", "619049b5a7c511d5968a00df7a3071933520c5a5e9112b5f635338e7095ecd35")

    add_deps("autotools")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("macosx", "iphoneos", "bsd", "linux", function (package)
        io.replace("VEX/priv/guest_arm64_helpers.c", "msr DIT, 1", ".inst 0xd503415f", {plain = true})
        io.replace("VEX/priv/guest_arm64_helpers.c", "msr DIT, 0", ".inst 0xd503405f", {plain = true})
        local configs = {}
        if package:is_plat("macosx") then
            table.insert(configs, "--with-darwin-platform=macosx")
        elseif package:is_plat("iphoneos") then
            table.insert(configs, "--with-darwin-platform=iphoneos")
            import("core.tool.toolchain")
            local xcode_sdkver = get_config("xcode_sdkver")
            if not xcode_sdkver then
                local xcode = package:toolchain("xcode") or toolchain.load("xcode", {plat = package:plat(), arch = package:arch()})
                if xcode and xcode.config and xcode:check() then
                    xcode_sdkver = xcode:config("xcode_sdkver")
                end
            end
            if not xcode_sdkver and is_host("macosx") then
                local result = try {function () return os.iorun("xcrun --sdk iphoneos --show-sdk-version") end}
                if result then
                    xcode_sdkver = result:trim()
                end
            end
            table.insert(configs, "--with-darwin-version=" .. xcode_sdkver)
        end
        if package:check_sizeof("void*") == "8" then
            table.insert(configs, "--enable-only64bit")
        elseif package:check_sizeof("void*") == "4" then
            table.insert(configs, "--enable-only32bit")
        end
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
        os.trycp("**.a", package:installdir("lib"))
        os.trycp("**.so", package:installdir("lib"))
        os.trycp("**.dylib", package:installdir("lib"))
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("valgrind --version")
        end
        assert(package:check_csnippets({test = [[
            void test() {
                VALGRIND_DO_LEAK_CHECK;
            }
        ]]}, {includes = "valgrind/memcheck.h"}))
    end)
