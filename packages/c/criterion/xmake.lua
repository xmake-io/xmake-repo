package("criterion")

    set_homepage("https://github.com/Snaipe/Criterion")
    set_description("A cross-platform C and C++ unit testing framework for the 21st century")
    set_license("MIT")

    add_urls("https://github.com/Snaipe/Criterion.git")
    add_versions("v2.4.2", "9c01cbe75002ad8640e0f411f453fbcd0567ff79")
    add_versions("v2.4.1", "56f8f1a4d06eb144d1b7c6a26619ab6adff9fdc8")
    add_versions("v2.4.0", "0f65b45162689752003f277bca30a427b9ffbc5a")

    add_deps("meson", "ninja")
    on_install(function (package)
        import("package.tools.meson").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("criterion_initialize", {includes = "criterion/criterion.h"}))
    end)
