package("sokol")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/floooh/sokol")
    set_description("Simple STB-style cross-platform libraries for C and C++, written in C.")
    set_license("zlib")

    add_urls("https://github.com/floooh/sokol.git")
    add_versions("2022.02.10", "e8931e4399a0eb4bf026120d7bdb89825815af9e")
    add_versions("2023.01.27", "dc6814bdecd277366a650b6b0b744b52bb9131e5")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
        os.cp("util/*.h", package:installdir("include", "util"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sargs_setup", {includes = "sokol_args.h", defines = "SOKOL_IMPL"}))
    end)
