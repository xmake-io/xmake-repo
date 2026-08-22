package("boxfort")
    set_homepage("https://github.com/Snaipe/BoxFort")
    set_description("Convenient & cross-platform sandboxing C library")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/BoxFort.git")

    add_versions("2024.05.02", "1018a44e63b57e9ffc3b8b68b6c8a8aa8f342d2a")

    add_patches("2024.05.02", "patches/android-shm.patch", "619a3e56cd6bb040d522acbf610603bf22e68a435742aadc1746793c32d44e99")
    add_patches("2024.05.02", "patches/arm64-windows-setjmp.patch", "ba4c26eee443e60d9592d78f8aca6c1458b0df4a8c37896f475d8c05a1982767")
    add_patches("2024.05.02", "patches/arm64-windows-trampoline.patch", "fb03e5484e4f7b0b8945708483937c79da704c38e7cf0d1acaffb821f5338c60")
    add_patches("2024.05.02", "patches/arm64-windows-use-armas64.patch", "0fbdb9baf62c63311cef7497cf9be1c47c2d21166f7acbe2390a5ab14ae4b059")
    add_patches("2024.05.02", "patches/ios-clear_cache.patch", "76cc5fd990f62d07c15a6aaf79b3add241b130a17f8e8339324db3f05176ef59")
    add_patches("2024.05.02", "patches/ios-mach_vm.patch", "7c4cc96c56e1352a629096a23b012f524941cf69fc796513fa5c736c0d7c5bed")

    add_configs("arena_reopen_shm", {description = "Reopen shared memory file in worker process rather than just inherit a file descriptor", default = false, type = "boolean"})
    add_configs("arena_file_backed", {description = "Use a file in tempfs to store the arena rather than using shm facilities", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("rt", "m")
    end

    add_deps("meson", "ninja")

    on_install("!wasm", function (package)
        if not package:config("shared") then
            package:add("defines", "BXF_STATIC_LIB")
        end

        local configs = {"-Dsamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Darena_reopen_shm=" .. (package:config("arena_reopen_shm") and "true" or "false"))
        table.insert(configs, "-Darena_file_backed=" .. (package:config("arena_file_backed") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bxf_arena_init", {includes = "boxfort.h"}))
    end)
