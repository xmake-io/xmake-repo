package("boxfort")
    set_homepage("https://github.com/Snaipe/BoxFort")
    set_description("Convenient & cross-platform sandboxing C library")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/BoxFort.git")

    add_versions("2024.05.02", "1018a44e63b57e9ffc3b8b68b6c8a8aa8f342d2a")

    add_patches("2024.05.02", "patches/arm64-windows.patch", "fbe76fda92e07383e85e663d05bbe0b3e73854070a49bc6e03cd10c4fb03d9cd")
    add_patches("2024.05.02", "patches/mach_vm-ios.patch", "f4ab17645c0dfccc667a7c340e293f19b00f419465946362a1752535050d27d9")

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
