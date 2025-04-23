package("boxfort")
    set_homepage("https://github.com/Snaipe/BoxFort")
    set_description("Convenient & cross-platform sandboxing C library")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/BoxFort.git")
    add_versions("2024.05.02", "1018a44e63b57e9ffc3b8b68b6c8a8aa8f342d2a")

    add_configs("arena_reopen_shm", {description = "Reopen shared memory file in worker process rather than just inherit a file descriptor", default = false, type = "boolean"})
    add_configs("arena_file_backed", {description = "Use a file in tempfs to store the arena rather than using shm facilities", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("rt", "m")
    end

    add_deps("meson", "ninja")

    on_install("windows|!arm64", "linux", "macosx", "bsd", "mingw", "msys", "cross", function (package)
        if not package:config("shared") then
            package:add("defines", "BXF_STATIC_LIB")
        end

        local configs = {"-Dsamples=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Darena_reopen_shm=" .. (package:config("arena_reopen_shm") and "true" or "false"))
        table.insert(configs, "-Darena_reopen_shm=" .. (package:config("arena_reopen_shm") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bxf_arena_init", {includes = "boxfort.h"}))
    end)
