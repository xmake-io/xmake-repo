package("valgrind-macos")
    set_kind("binary")
    set_homepage("https://github.com/LouisBrunner/valgrind-macos")
    set_description("A valgrind mirror with latest macOS support")
    set_license("GPL-3.0")

    add_urls("https://github.com/LouisBrunner/valgrind-macos.git")
    add_versions("2026.09.09", "7877928dcc8bfb873325e4f51949f930d77e493e")
    add_patches("2026.09.09", "patches/2026.09.09/disable-tests.patch", "82e122b36d3cbbfff19491d72424b6b1e21147f3eb3d276e11572d82757db141")
    add_patches("2026.09.09", "patches/2026.09.09/arm64-linux.patch", "77693cf0900cb96ce4cfd17bd0a6d6ff5995b09928d5e15919ae45b05b4f5e85")

    add_deps("autotools")

    on_install("@macosx", "@bsd", "@linux", function (package)
        io.replace("VEX/priv/guest_arm64_helpers.c", "msr DIT, 1", ".inst 0xd503415f", {plain = true})
        io.replace("VEX/priv/guest_arm64_helpers.c", "msr DIT, 0", ".inst 0xd503405f", {plain = true})
        local configs = {}
        if package:is_plat("macosx") then
            table.insert(configs, "--with-darwin-platform=macosx")
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
    end)

    on_test(function (package)
        if not (package:is_plat("linux") and package:is_arch("arm64")) then
            os.vrun("valgrind --version")
        end
    end)
